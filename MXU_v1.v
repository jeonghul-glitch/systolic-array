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

module delay #(parameter W = 8, parameter D = 1) (
    input clk, rst,
    input [W-1:0] in,
    output [W-1:0] out
);
    generate
        if (D == 0) begin : no_delay
            assign out = in;
        end else begin : chain
            reg [W-1:0] r [0:D-1];
            integer k;
            always @(posedge clk) begin
                if (rst)
                    for (k = 0; k < D; k = k+1)
                        r[k] <= 0;
                else begin
                    r[0] <= in;
                    for (k = 1; k < D; k = k + 1)
                        r[k] <= r[k-1];
                end
            end
            assign out = r[D-1];
        end
    endgenerate
endmodule

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