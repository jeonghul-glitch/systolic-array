module tb_arrayNxN;
    localparam N = 2;
    reg clk = 0, rst, load_w;
    reg [8*N-1:0] a_in;
    reg [8*N*N-1:0] w_in;
    wire [32*N-1:0] y;

    integer errors = 0;

    array #(.N(N)) dut (.clk(clk), .rst(rst), .load_w(load_w), .a_in(a_in), .w_in(w_in),
               .y(y));
    
    always #5 clk = ~clk;

    initial begin
        rst = 1; load_w = 0; a_in = 0; w_in = 0;
        #10 rst = 0; load_w = 1; w_in = {8'd6, 8'd5, 8'd4, 8'd1};
        #10 load_w = 0; a_in = {8'd0, 8'd2};
        #10 a_in = {8'd3, 8'd0};
        #10 a_in = 0;
            if (y[31:0] !== 17) begin
            $display("FAIL y0: got %0d", y[31:0]);
            errors = errors + 1;
        end
        #10 if (y[63:32] !== 26) begin
            $display("FAIL y1: got %0d", y[63:32]);
            errors = errors + 1;
        end

        $display("%0d errors",errors);
        $finish;
    end
endmodule

 