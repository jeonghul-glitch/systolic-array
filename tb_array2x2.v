module tb_array2x2;
    reg clk = 0, rst, load_w;
    reg signed [7:0] a_in0, a_in1;
    reg signed [7:0] w00, w01, w10, w11; 
    wire signed [31:0] psum_out10, psum_out11;
    integer errors = 0;

    array2x2 dut (.clk(clk), .rst(rst), .load_w(load_w), .a_in0(a_in0), .a_in1(a_in1), .w00(w00),
                  .w01(w01), .w10(w10), .w11(w11), .psum_out10(psum_out10), .psum_out11(psum_out11));
    
    always #5 clk = ~clk;

    initial begin
        rst = 1; load_w = 0; a_in0 = 0; a_in1 = 0; w00 = 0; w01 = 0; w10 = 0; w11 = 0;
        #10 rst = 0; load_w = 1; w00 = 1; w01 = 4; w10 = 5; w11 = 6;
        #10 load_w = 0; a_in0 = 2;
        #10 a_in0 = 0; a_in1 = 3;
        #10 a_in1 = 0;
            if (psum_out10 !== 17) begin
            $display("FAIL sign: got %0d", psum_out10);
            errors = errors + 1;
        end
        #10 if (psum_out11 !== 26) begin
            $display("FAIL sign: got %0d", psum_out11);
            errors = errors + 1;
        end

        $display("%0d errors",errors);
        $finish;
    end
endmodule