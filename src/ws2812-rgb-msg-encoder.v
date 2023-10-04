module ws2812_rgb_message_encoder (
    input wire[7:0] r,
    input wire[7:0] g,
    input wire[7:0] b,
    output wire[23:0] message
);

assign message[23:16] = g;
assign message[15:8] = r;
assign message[7:0] = b;

endmodule