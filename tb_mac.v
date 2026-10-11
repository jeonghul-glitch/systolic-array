module tb_mac;
    reg clk = 0, rst, load_w;
    reg signed [7:0] w_in, a_in;
    reg signed [31:0] psum_in; 
    wire signed [7:0] a_out;
    wire signed [31:0] psum_out;
    integer errors = 0;

    mac dut (.clk(clk), .rst(rst), .load_w(load_w), .w_in(w_in), .a_in(a_in), 
             .psum_in(psum_in), .a_out(a_out), .psum_out(psum_out));
    
    always #5 clk = ~clk;

    initial begin
        rst = 1; load_w = 0; a_in = 0; psum_in = 0;
        #10 rst = 0; load_w = 1; w_in = 10;
        #10 load_w = 0; a_in = -1; psum_in = 0;
        #10 a_in = -10; psum_in = 0;
        #10 if (psum_out !== -100) begin
            $display("FAIL sign: got %0d", psum_out);
            errors = errors + 1;
        end if (a_out !== -10) begin
            $display("FAIL a_out: got %0d", a_out);
            errors = errors + 1;
        end

        #10 rst = 0; load_w = 1; w_in = -128;
        #10 load_w = 0; a_in = -128; psum_in = 0; 
        #10 a_in = 127; psum_in = 0;
        #10 if (psum_out !== -16256) begin
            $display("FAIL sign: got %0d", psum_out);
            errors = errors + 1;
        end if (a_out !== 127) begin
            $display("FAIL a_out: got %0d", a_out);
            errors = errors + 1;
        end

        #10 rst = 0; load_w = 1; w_in = -3;
        #10 load_w = 0; a_in = 5; psum_in = 100; 
        #10 if (psum_out !== 85) begin
            $display("FAIL sign: got %0d", psum_out);
            errors = errors + 1;
        end if (a_out !== 5) begin
            $display("FAIL a_out: got %0d", a_out);
            errors = errors + 1;
        end

        $display("%0d errors",errors);
        $finish;
    end
endmodule