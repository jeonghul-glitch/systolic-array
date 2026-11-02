module TB_MXU;
    localparam N = 3;
    reg clk = 0, rst, shift, sw_in;
    reg [8*N-1:0] x;
    reg [8*N-1:0] w_top;
    reg [8*N-1:0] tileA [0:N-1];
    reg [8*N-1:0] tileB [0:N-1];
    reg [8*N-1:0] iv [0:17];
    reg [32*N-1:0] ey [0:17];
    wire [32*N-1:0] y;

    integer errors = 0;
    integer i, j, e;

    MXU #(.N(N)) dut (.clk(clk), .rst(rst), .shift(shift), .sw_in(sw_in), .x(x),
        .w_top(w_top), .y(y));

    always #5 clk = ~clk;

    localparam L = 9; // used when switching loops
    localparam S = 4; // used when switching loops

    initial begin
        tileA[0] = {8'd3, 8'd1, 8'd2};  // [2,1,3]
        tileA[1] = {8'd2, 8'd4, 8'd1};  // [1,4,2]
        tileA[2] = {8'd1, 8'd2, 8'd3};  // [3,2,1]

        tileB[0] = {8'd0, 8'd2, -8'd1}; // [-1,2,0]
        tileB[1] = {8'd1, -8'd2, 8'd3}; // [3,-2,1]
        tileB[2] = {-8'd3, 8'd0, 8'd1}; // [1,0,-3]

        iv[0] = {8'd3, 8'd2, 8'd1};     // [1,2,3]
        iv[1] = {8'd1, 8'd0, 8'd2};     // [2,0,1]
        iv[2] = {8'd1, 8'd3, 8'd0};     // [0,3,1]
        iv[3] = {8'd2, 8'd1, 8'd3};     // [3,1,2]
        iv[4] = {8'd1, 8'd1, 8'd1};     // [1,1,1]
        iv[5] = {8'd0, 8'd2, 8'd2};     // [2,2,0]
        iv[6] = {8'd3, 8'd1, 8'd0};     // [0,1,3]
        iv[7] = {8'd2, 8'd0, 8'd3};     // [3,0,2]
        iv[8] = {8'd0, 8'd3, 8'd1};     // [1,3,0]
        iv[9] = {8'd0, 8'd1, 8'd2};     // [2,1,0]
        iv[10] = {8'd1, 8'd2, 8'd1};    // [1,2,1]
        iv[11] = {8'd3, 8'd0, 8'd0};    // [0,0,3]
        iv[12] = {8'd1, 8'd2, 8'd3};    // [3,2,1]
        iv[13] = {8'd2, 8'd0, 8'd1};    // [1,0,2]
        iv[14] = {8'd1, 8'd3, 8'd2};    // [2,3,1]
        iv[15] = {8'd2, 8'd2, 8'd0};    // [0,2,2]
        iv[16] = {8'd3, 8'd1, 8'd1};    // [1,1,3]
        iv[17] = {8'd0, 8'd1, 8'd3};    // [3,1,0]

        ey[0] = {32'd10, 32'd15, 32'd13};       // [13, 15, 10]
        ey[1] = {32'd7, 32'd4, 32'd7};          // [7, 4, 7]
        ey[2] = {32'd7, 32'd14, 32'd6};         // [6, 14, 7]
        ey[3] = {32'd13, 32'd11, 32'd13};       // [13, 11, 13]
        ey[4] = {32'd6, 32'd7, 32'd6};          // [6, 7, 6]
        ey[5] = {32'd10, 32'd10, 32'd6};        // [6, 10, 10]
        ey[6] = {32'd5, 32'd10, 32'd10};        // [10, 10, 5]
        ey[7] = {32'd11, 32'd7, 32'd12};        // [12, 7, 11]
        ey[8] = {32'd9, 32'd13, 32'd5};         // [5, 13, 9]
        ey[9] = {32'd1, 32'd2, 32'd1};          // [1, 2, 1]
        ey[10] = {-32'sd1, -32'sd2, 32'd6};     // [6, -2, -1]
        ey[11] = {-32'sd9, 32'd0, 32'd3};       // [3, 0, -9]
        ey[12] = {-32'sd1, 32'd2, 32'd4};       // [4, 2, -1]
        ey[13] = {-32'sd6, 32'd2, 32'd1};       // [1, 2, -6]
        ey[14] = {32'd0, -32'sd2, 32'd8};       // [8, -2, 0]
        ey[15] = {-32'sd4, -32'sd4, 32'd8};     // [8, -4, -4]
        ey[16] = {-32'sd8, 32'd0, 32'd5};       // [5, 0, -8]
        ey[17] = {32'd1, 32'd4, 32'd0};         // [0, 4, 1]

        rst = 1; shift = 0; sw_in = 0; x = 0; w_top = 0;
        #10 rst = 0; shift = 1; w_top = tileA[2];
        #10 w_top = tileA[1];
        #10 w_top = tileA[0];
        #10 shift = 0; x = iv[0]; sw_in = 1;
        #10 x = iv[1]; sw_in = 0;
        #10 x = iv[2];
        #10 x = iv[3]; 
        #10 x = iv[4]; shift = 1; w_top = tileB[2];
        #10 x = iv[5]; w_top = tileB[1];
        #10 x = iv[6]; w_top = tileB[0];
        #10 x = iv[7]; shift = 0;
        #10 x = iv[8]; 
        #10 x = iv[9]; sw_in = 1; 
        #10 x = iv[10]; sw_in = 0; 
        #10 x = iv[11];
        #10 x = iv[12]; 
        #10 x = iv[13];
        #10 x = iv[14];
        #10 x = iv[15];
        #10 x = iv[16];
        #10 x = iv[17];
        #10 x = 0;
    end

    initial begin
        #90;
        for (e = 0; e < 18; e = e + 1) begin
            for (j = 0; j < N; j = j + 1) begin
                if (y[32*j +: 32] !== ey[e][32*j +: 32]) begin
                    $display("FAIL vector %0d col %0d: got %0d, expected %0d", e, j, 
                            $signed(y[32*j +: 32]), $signed(ey[e][32*j +: 32]));
                    errors = errors + 1;
                end
            end
        #10;
        end

        $display("%0d errors", errors);
        $finish;
    end

endmodule