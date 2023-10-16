`timescale 1 ns/ 1 ns

module test_ws2812_onboard_ram;

reg clk;
always #50 clk <= !clk;

reg[7:0] addr;
reg [7:0] write_data;
wire [7:0] read_data;

reg we;
reg clear;

ws2812_on_chip_ram mem(
    clk,
    addr,
    write_data,
    read_data,

    we,
    clear
);

initial begin
    $dumpfile("test_ws2812_on_chip_ram.vcd");
    $dumpvars(0, test_ws2812_on_chip_ram);
    
    //cmd = 2'b01;
    clk = 0;
    addr = 7'h5;
    we = 1'b0;
    clear = 1'b1;
    write_data = 'hAB;

    #20 clear = 1'b0;
    #30 we = 1'b1;
    #40 we = 1'b0;

    #1500000 $finish;
end

endmodule