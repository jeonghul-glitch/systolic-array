module TB_board_test;
    reg clk = 0;
    always #5 clk = ~clk;

    wire [3:0] led;

    board_test #(.N(10), .T(50)) dut (.clk(clk), .led(led));

    initial begin
        #1 $display("%h", dut.tiles[0]); $display("%h", dut.ey[0]);
        #700 $display("%h", dut.y);
        #400 $display("%h", dut.y);
        #300 $display("%h", dut.y);
        wait (dut.done);
        #20 $display("%0d errors, %0d vectors, led = %b", dut.errors, dut.v, led);
        $finish;
    end

    initial begin
        #100000 $display("TIMEOUT: done never went high");
        $finish;
    end
endmodule

