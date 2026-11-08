(* use_dsp = "yes" *)

module mac(
    input clk,rst,shift,sw_in,
    input signed [7:0] a_in, w_in,
    input signed [31:0] psum_in,
    output signed [7:0] w_out,
    output reg sw_out,
    output reg signed [7:0] a_out,
    output reg signed [31:0] psum_out
);
    reg signed [7:0] w_next, w_act;
    wire signed [7:0] w_use;

    assign w_use = sw_in ? w_next : w_act;

    always @(posedge clk) begin
        if (rst) begin
            w_next <= 0;
            w_act <= 0;
            sw_out <= 0;
            a_out <= 0;
            psum_out <= 0;
        end
        else begin
            w_next <= shift ? w_in : w_next;
            w_act <= sw_in ? w_next : w_act;
            psum_out <= psum_in + w_use * a_in;
            a_out <= a_in;
            sw_out <= sw_in;
        end
    end

    assign w_out = w_next;
endmodule

module array #(parameter N = 10) (
    input clk, rst, shift,
    input [N-1:0] sw_in,
    input [8*N-1:0] a_in,
    input [8*N-1:0] w_top,
    output [32*N-1:0] y_array
);
    wire signed [7:0] a_wire [0:N-1][0:N]; 
    wire signed [7:0] w_w [0:N][0:N-1];
    wire signed [31:0] p_wire [0:N][0:N-1];
    wire s_w [0:N-1][0:N];

    genvar i, j;
    generate 
        for (i = 0; i < N; i = i + 1) begin : row
            assign a_wire[i][0] = a_in[8*i +: 8];
            assign s_w[i][0] = sw_in[i];
            for (j = 0; j < N; j = j + 1) begin : col
                mac c (.clk(clk), .rst(rst), .shift(shift), .sw_in(s_w[i][j]), 
                .a_in(a_wire[i][j]), .w_in(w_w[i][j]), .psum_in(p_wire[i][j]),
                .sw_out(s_w[i][j+1]), .a_out(a_wire[i][j+1]), .psum_out(p_wire[i+1][j]),
                .w_out(w_w[i+1][j]) );
            end
        end
        for (j = 0; j < N; j = j + 1) begin : edges
            assign p_wire[0][j] = 0;
            assign w_w[0][j] = w_top[8*j +: 8];
            assign y_array[32*j +: 32] = p_wire[N][j];
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
        end
        else begin : chain
            reg [W-1:0] r [0:D-1];
            integer k;
            always @(posedge clk) begin
                if (rst)
                    for (k = 0; k < D; k = k + 1)
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

module MXU #(parameter N = 10) (
    input clk, rst, shift, sw_in,
    input [8*N-1:0] x,
    input [8*N-1:0] w_top,
    output [32*N-1:0] y
);
    wire [8*N-1:0] a_skewed;
    wire [32*N-1:0] y_array;
    wire [N-1:0] sw_skewed;

    genvar i, j;

    generate
        for (i = 0; i < N; i = i + 1) begin : in_skew
            delay #(.W(9), .D(i)) d (.clk(clk), .rst(rst), .in({sw_in, x[8*i +: 8]}),
            .out({sw_skewed[i], a_skewed[8*i +: 8]}));
        end
        for (j = 0; j < N; j = j + 1) begin : out_deskew
            delay #(.W(32), .D(N-1-j)) d (.clk(clk), .rst(rst), .in(y_array[32*j +: 32]),
            .out(y[32*j +: 32]) );
        end
    endgenerate

    array #(.N(N)) core (.clk(clk), .rst(rst), .shift(shift), .sw_in(sw_skewed),
    .a_in(a_skewed), .w_top(w_top), .y_array(y_array));
endmodule