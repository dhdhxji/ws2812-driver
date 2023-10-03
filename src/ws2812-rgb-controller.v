module ws2812_rgb_controller (
    input wire clk,
    input wire[7:0] r,
    input wire[7:0] g,
    input wire[7:0] b,
    input wire[1:0] command,
    output reg cmd_wait,
    output wire data_output
);

parameter CLK_FREQ_KHZ      = 10000;

localparam CMD_IDLE         = 2'b00;
localparam CMD_TX           = 2'b01;
localparam CMD_RESET        = 2'b10;

reg[1:0] current_state;
reg[23:0] rgb_buffer;
reg[4:0] rgb_bits_sent;

reg[1:0] encoder_command;
wire encoder_waits_command;


ws2812_unipolar_rz_encoder encoder(
    rgb_buffer[0],
    clk,
    encoder_command,
    encoder_waits_command,
    data_output
);

always @(posedge clk) begin
    case (current_state)
        CMD_IDLE: begin
            rgb_buffer[23:16] = g;
            rgb_buffer[15:8] = r;
            rgb_buffer[7:0] = b;
            rgb_bits_sent = 0;

            current_state = command;
            cmd_wait = 1'b1;
        end
        
        CMD_TX: begin
            encoder_command = CMD_TX;

            if (rgb_bits_sent >= 24 - 1) begin
                cmd_wait = 1'b1;
            end 
            else if (command == CMD_TX && (rgb_bits_sent >= 24)) begin
                cmd_wait = 1'b0;
                rgb_buffer[23:16] = g;
                rgb_buffer[15:8] = r;
                rgb_buffer[7:0] = b;
                rgb_bits_sent = 0;
            end
            else cmd_wait = 1'b0;
        end  
        
        CMD_RESET: begin end
        default: current_state <= CMD_IDLE;
    endcase
end

always @(posedge encoder_waits_command) begin
    case (current_state)
        CMD_TX: begin
            rgb_bits_sent = rgb_bits_sent + 1;
            rgb_buffer = rgb_buffer >> 1;
        end
        default: begin end
    endcase
end
    
endmodule