`timescale 1 ns/ 1 ps

module test_ws2812_rgb_controller;

reg clk;
wire cmd_req;
reg[1:0] cmd;
wire data_out;


initial begin
    $dumpfile("test_ws2812_rgb_controller.vcd");
    $dumpvars(0, test_ws2812_rgb_controller);
    
    cmd = 2'b01;
    clk = 0;

    #5000 cmd = 2'b00;
    #30000 $finish;
end

always #50 clk <= !clk;

ws2812_rgb_controller rgb_controller(
    clk,
    8'd255,
    8'd0,
    8'd128,
    cmd,
    cmd_req,
    data_out
);

endmodule