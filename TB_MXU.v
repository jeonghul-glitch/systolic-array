module TB_MXU;
    parameter N = 10, T = 1000;
    localparam L = 3*N + 2;

    reg clk = 0, rst, shift, sw_in;
    reg [8*N-1:0] x;
    reg [8*N-1:0] w_top;

    reg [8*N-1:0]  tiles [0:T*N-1];
    reg [8*N-1:0]  iv    [0:T*L-1];
    reg [32*N-1:0] ey    [0:T*L-1];
    reg [7:0]      S     [0:T-1];

    wire [32*N-1:0] y;

    integer errors = 0;
    integer t, k, r, v, j;

    MXU #(.N(N)) dut (.clk(clk), .rst(rst), .shift(shift), .sw_in(sw_in), .x(x),
        .w_top(w_top), .y(y));

    always #5 clk = ~clk;

    initial begin
        $readmemh("tiles.hex", tiles);
        $readmemh("iv.hex", iv);
        $readmemh("ey.hex", ey);
        $readmemh("s.hex", S);  

        rst = 1; shift = 0; sw_in = 0; x = 0; w_top = 0;
        #10 rst = 0; 
        for (r = N - 1; r >= 0; r = r - 1) begin
            shift = 1; w_top = tiles[r]; #10;
        end
        shift = 0;
        for (t = 0; t < T; t = t + 1) begin
            for (k = 0; k < L; k = k + 1) begin
                x = iv[t*L + k]; sw_in = (k ==0);
                if (t < T-1 && k >= S[t] && k < S[t] + N) begin
                    shift = 1; w_top = tiles[(t+1)*N + (N-1-(k-S[t]))];
                end else
                    shift = 0;
                #10;
            end
        end
        x = 0; sw_in = 0; shift = 0;
    end

    initial begin
        #(30*N);
        for (v = 0; v < T*L; v = v + 1) begin
            for (j = 0; j < N; j = j + 1) begin
                if (y[32*j +: 32] !== ey[v][32*j +: 32]) begin
                    if (errors < 10) $display("FAIL vector %0d col %0d: got %0d, expected %0d", v, j, 
                                     $signed(y[32*j +: 32]), $signed(ey[v][32*j +: 32]));
                    errors = errors + 1;
                end
            end
        #10;
        end

        $display("%0d errors", errors);
        $finish;
    end

endmodule