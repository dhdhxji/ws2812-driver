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
wire[4:0] rgb_current_tx_bit_index;
reg rgb_current_tx_bit;
reg[4:0] rgb_bits_sent;

reg[1:0] encoder_command;
wire encoder_waits_command;

assign rgb_current_tx_bit_index = 24 - rgb_bits_sent - 1;

ws2812_unipolar_rz_encoder encoder(
    rgb_current_tx_bit,
    clk,
    encoder_command,
    encoder_waits_command,
    data_output
);

wire[23:0] rgb_message_encoded;
ws2812_rgb_message_encoder rgb_encoder(
    r, g, b,
    rgb_message_encoded
);

always @(posedge clk) begin
    case (current_state)
        CMD_IDLE: begin
            rgb_buffer = rgb_message_encoded;
            rgb_bits_sent = 0;

            current_state = command;
            encoder_command = CMD_IDLE;
            cmd_wait = 1'b1;
        end
        
        CMD_TX: begin
            encoder_command = CMD_TX;
        end
        
        CMD_RESET: begin 
            cmd_wait = 1'b0;
            encoder_command = CMD_RESET;
        end
        default: current_state <= CMD_IDLE;
    endcase
end

always @(posedge encoder_waits_command) begin
    case (current_state)
        CMD_TX: begin
            if (rgb_bits_sent >= 24) begin
                encoder_command = CMD_IDLE;
                current_state = CMD_IDLE;
            end
            else begin
                if (rgb_bits_sent == 0) cmd_wait = 1'b0;

                rgb_current_tx_bit = rgb_buffer[rgb_current_tx_bit_index];
                rgb_bits_sent = rgb_bits_sent + 1;

                // Prefetch next pixel
                if (rgb_bits_sent == (24 - 1)) begin
                    cmd_wait = 1'b1;
                end else if (rgb_bits_sent == (24) && command == CMD_TX) begin
                    cmd_wait = 1'b0;
                    rgb_bits_sent = 0;
                end
            end  
        end
        default: begin end

        CMD_RESET: begin
            current_state = CMD_IDLE;
        end
    endcase
end
    
endmodule