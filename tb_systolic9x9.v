module tb_systolic9x9;
    localparam N = 9;
    reg clk = 0, rst, load_w;
    reg [8*N-1:0] x;
    reg [8*N*N-1:0] w_in;
    wire [32*N-1:0] y;

    integer errors = 0;
    integer i, j;

    systolic #(.N(N)) dut (.clk(clk), .rst(rst), .load_w(load_w), .x(x), .w_in(w_in),
               .y(y));
    
    always #5 clk = ~clk;

    initial begin
        rst = 1; load_w = 0; x = 0; w_in = 0;

        #10 rst = 0; load_w = 1; 
        for (i = 0; i < N; i = i + 1)
            for (j = 0; j < N; j = j + 1;)
                w_in[8*(i*N + j) +: 8] = j + 1

        #10 load_w = 0;
        for (i = 0; i < N; i = i + 1)
            x[8*i +: 8] = i + 1;

        #10 x = 0;

        #(20*(N-1));

        for (j = 0; j < N; j = j + 1)
            if (y[32*j +: 32] !== 45*(j + 1)) begin
                $display("FAIL y%0d: got %0d, expected %0d", $signed(y[32*j +: 32]), 45*(j + 1));
                errors = errors + 1;
            end

        $display("%0d errors",errors);
        $finish;
    end
endmodule