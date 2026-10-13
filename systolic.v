module systolic #(parameter N = 4) (
    input clk, rst, load_w,
    input [8*N-1:0] x,
    input [8*N*N-1:0] w_in,
    output [32*N-1:0] y
);

    wire [8*N-1:0] a_skewed; 
    wire [32*N-1:0] y_array;

    genvar i, j;

    generate
        for (i = 0; i < N; i = i + 1) begin : in_skew
            delay #(.W(8), .D(i)) d (.clk(clk), .rst(rst), .in(x[8*i +: 8]),
                   .out(a_skewed[8*i +: 8]));
        end
        for (j = 0; j < N; j = j + 1) begin : out_deskew
            delay #(.W(32), .D(N-1-j)) d (.clk(clk), .rst(rst), .in(y_array[32*j +: 32]),
                    .out(y[32*j +: 32]));
        end
    endgenerate

    array #(.N(N)) core (.clk(clk), .rst(rst), .load_w(load_w), .a_in(a_skewed), .w_in(w_in),
            .y(y_array));

endmodule        
