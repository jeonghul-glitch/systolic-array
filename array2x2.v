module array2x2 (
    input clk, rst, load_w,
    input signed [7:0] a_in0, a_in1, 
    input signed [7:0] w00, w01, w10, w11,
    output signed [31:0] psum_out10, psum_out11
);

    wire signed [7:0] a00, a10;
    wire signed [31:0] p00, p01;

    mac c00 (.clk(clk), .rst(rst), .load_w(load_w), .psum_in(32d'0), .a_in(a_in0), .w_in(w00), .a_out(a00), .psum_out(p00));
    mac c01 (.clk(clk), .rst(rst), .load_w(load_w), .psum_in(32d'0), .a_in(a00), .w_in(w01), .a_out(), .psum_out(p01));
    mac c10 (.clk(clk), .rst(rst), .load_w(load_w), .psum_in(p00), .a_in(a_in1), .w_in(w10), .a_out(a10), .psum_out(psum_out10));
    mac c11 (.clk(clk), .rst(rst), .load_w(load_w), .psum_in(p01), .a_in(a10), .w_in(w11), .a_out(), .psum_out(psum_out11));

endmodule