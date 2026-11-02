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
        $readmemh("tileA.hex", tileA);
        $readmemh("tileB.hex", tileB);
        $readmemh("iv.hex", iv);
        $readmemh("ey.hex", ey);  
          
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