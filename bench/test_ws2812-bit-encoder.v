`timescale 1 ns/ 1 ps

module test_ws2812_bit_encoder;

reg clk;
wire cmd_req;
wire data_req;
reg databit;
wire data_out;


initial begin
    $dumpfile("test_ws2812_bit_encoder.vcd");
    $dumpvars(0, test_ws2812_bit_encoder);
    
    clk = 0;
    databit = 0;

    #5000 databit = 1;

    #10000 $finish;
end

always #50 clk <= !clk;

ws2812_unipolar_rz_encoder enc(
    databit,
    clk,
    2'b01,//CMD_TX,
    cmd_req,
    data_req,
    data_out
);

endmodule