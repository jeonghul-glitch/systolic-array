module array #(parameter N = 4) (
    input clk, rst, load_w,
    input [8*N-1:0] a_in,
    input [8*N*N-1:0] w_in,
    output [32*N-1:0] y
);

    wire signed [7:0] a_wire [0:N-1][0:N];
    wire signed [31:0] p_wire [0:N][0:N-1];

    genvar i, j;
    generate
        for (i = 0; i < N; i = i + 1) begin : row
            assign a_wire[i][0] = a_in[8*i +:8];
            for (j = 0; j < N; j = j + 1) begin : col
            mac c (.clk(clk), .rst(rst), .load_w(load_w), .w_in(w_in[8*(i*N + j) +:8]), 
                   .a_in(a_wire[i][j]), .psum_in(p_wire[i][j]), .a_out(a_wire[i][j+1]), 
                   .psum_out(p_wire[i+1][j]) );
            end
        end
        for (j = 0; j < N; j = j + 1) begin : edges
        assign p_wire[0][j] = 0;
        assign y[32*j +: 32] = p_wire[N][j];
        end
    endgenerate
endmodule