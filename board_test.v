module board_test #(parameter N=10, parameter T=50) (
    input clk,
    output [3:0] led
);
    localparam L = 3*N + 2;

// reset when power on
    reg [4:0] por = 0;
    always @(posedge clk) if (!(&por)) por <= por +1;
    wire rst = !(&por);

// 27 bit counter
    reg [26:0] count = 0;
    always @(posedge clk) count <= count + 1;
    assign led[0] = count[26];

// ROMs
    reg [8*N-1:0]  tiles [0:T*N-1];
    reg [8*N-1:0]  iv    [0:T*L-1];
    reg [32*N-1:0] ey    [0:T*L-1];
    reg [7:0]      S     [0:T-1];

    initial begin
        $readmemh("C:/projects/systolic/tiles.hex", tiles);
        $readmemh("C:/projects/systolic/iv.hex", iv);
        $readmemh("C:/projects/systolic/ey.hex", ey);
        $readmemh("C:/projects/systolic/s.hex", S);  
    end

// clocked reads
    reg [$clog2(T*N)-1:0] tile_addr;
    reg [$clog2(T*L)-1:0] iv_addr;
    reg [$clog2(T*L)-1:0] ey_addr;

    reg [8*N-1:0] tile_q;
    always @(posedge clk) tile_q <= tiles[tile_addr];
    reg [8*N-1:0] iv_q;
    always @(posedge clk) iv_q <= iv[iv_addr];
    reg [32*N-1:0] ey_q;
    always @(posedge clk) ey_q <= ey[ey_addr];

// driver FSM, MXU, valid delay, checker
    localparam LOAD = 0, RUN = 1, DONE = 2;
    reg [1:0] state;
    reg [1:0] next_state;
    reg [$clog2(N)-1:0] r;
    reg [$clog2(T)-1:0] b;
    reg [$clog2(L)-1:0] k;

// FSM counter
    always @(posedge clk) begin
        if (rst) begin
            state <= LOAD;
            r <= N - 1;
        end else begin
            state <= next_state;

            case (state)
                LOAD: begin
                    r <= r - 1;
                    if (r == 0) begin
                        b <= 0;
                        k <= 0;
                    end
                end
               
                RUN: begin
                    if (k == L-1) begin
                        k <= 0; 
                        b <= b + 1;
                    end
                    else k <= k + 1;
                end
            endcase
        end
    end

//FSM next_state block
    always @(*) begin
        // Preventing accidental latch creation
        next_state = state;

        case (state)
            LOAD: begin
                if (r == 0) next_state = RUN;
            end

            RUN: begin
                if (b == T-1 && k == L-1) next_state = DONE;
            end

            DONE: next_state = DONE;
        endcase
    end

//FSM output
    reg shift_c, sw_c, valid_c;
    reg shift_d, sw_d, valid_d;

    always @(*) begin
        tile_addr = 0; iv_addr = 0; shift_c = 0; sw_c = 0; valid_c = 0;

        case (state)
            LOAD: begin
                tile_addr = r;
                shift_c = 1;
            end
            RUN: begin
                valid_c = 1;
                iv_addr = b*L + k; sw_c = (k == 0);
                    if (b < T-1 && k >= S[b] && k < S[b] + N) begin
                        shift_c = 1; tile_addr = (b+1)*N + (N-1-(k-S[b]));
                    end 
            end
        endcase
    end

    always @(posedge clk) begin
        if (rst) begin 
            shift_d <= 0; sw_d <= 0; valid_d <= 0;
        end else begin
            shift_d <= shift_c; sw_d <= sw_c; valid_d <= valid_c;
        end
    end

//MXU
    wire [32*N-1:0] y;
    MXU #(.N(N)) mxu (.clk(clk), .rst(rst), .shift(shift_d), .sw_in(sw_d),
        .x(valid_d ? iv_q : 0), .w_top(tile_q), .y(y));

// valid delay
    wire valid_out;
    delay #(.W(1), .D(2*N-1)) vdel (.clk(clk), .rst(rst), .in(valid_d), .out(valid_out));

// checker
    reg [$clog2(T*L):0] v;
    reg [32*N-1:0] y_d;
    reg vo_d;
    reg [15:0] errors;
    reg done;

    always @(*) ey_addr = v;

    always @(posedge clk) begin
        if (rst) begin
            v <= 0; vo_d <= 0; errors <= 0; done <= 0;
        end else begin
            vo_d <= valid_out;
            y_d  <= y;
            if (valid_out) v <= v + 1;
            if (vo_d && y_d != ey_q) errors <= errors + 1;
            if (vo_d && v == T*L) done <= 1;
        end
    end

// LEDs: 0 heartbeat, 1 done, 2 PASS, 3 FAIL
    assign led[1] = done;
    assign led[2] = done && (errors == 0);
    assign led[3] = done && (errors != 0);

endmodule