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