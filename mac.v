module mac(
    input clk, rst, load_w,
    input signed [7:0] w_in, a_in,
    input signed [31:0] psum_in,
    output reg signed [7:0] a_out,
    output reg signed [31:0] psum_out
);
    reg signed [7:0] w;

    always @(posedge clk) begin
        if (rst) begin
           w <= 0; a_out <= 0; psum_out <= 0;
        end
        else begin
            w <= load_w ? w_in : w;
            psum_out <= psum_in + w * a_in;
            a_out <= a_in;
        end
    end

endmodule