module ws2812_rgb_controller (
    input wire clk,
    input wire[7:0] r,
    input wire[7:0] g,
    input wire[7:0] b,
    input wire[1:0] command,
    output reg cmd_request,
    output reg data_request,
    output wire encoded_output
);

// TODO: Pass clock frequency parameter to the rz encoder
// parameter CLK_FREQ_KHZ      = 10000;

localparam CMD_IDLE         = 2'b00;
localparam CMD_TX           = 2'b01;
localparam CMD_RESET        = 2'b10;


localparam STATE_INIT                   = 4'd0;
localparam STATE_INIT_WAIT              = 4'd1;
localparam STATE_CMD_FETCH_START        = 4'd2;
localparam STATE_CMD_FETCH_END          = 4'd3;
localparam STATE_TX_PREP                = 4'd4;
localparam STATE_TX                     = 4'd5;
localparam STATE_TX_DATA_PREFETCH_START = 4'd6;
localparam STATE_TX_DATA_PREFETCH_END   = 4'd7;
localparam STATE_RESET_PREP             = 4'd8;
localparam STATE_RESET                  = 4'd9;


reg[3:0] current_state;

reg[23:0] rgb_buffer;
reg[4:0] rgb_bits_sent;

reg[1:0] encoder_command;
wire encoder_requests_command;
wire encoder_requests_data;

ws2812_unipolar_rz_encoder encoder(
    rgb_buffer[23],
    clk,
    encoder_command,
    encoder_requests_command,
    encoder_requests_data,
    encoded_output
);

wire[23:0] rgb_message_encoded;
ws2812_rgb_message_encoder rgb_encoder(
    r, g, b,
    rgb_message_encoded
);

always @(posedge clk) begin
    case (current_state)
        STATE_INIT: begin
            rgb_buffer <= 24'd0;
            cmd_request <= 1'b0;
            data_request <= 1'b0;
            encoder_command <= CMD_IDLE;

            current_state <= STATE_INIT_WAIT;
        end

        STATE_INIT_WAIT: begin
            if (encoder_requests_command) current_state <= STATE_CMD_FETCH_START;
        end

        STATE_CMD_FETCH_START: begin
            encoder_command <= CMD_IDLE;
            cmd_request <= 1'b1;
            current_state <= STATE_CMD_FETCH_END;
        end

        STATE_CMD_FETCH_END: begin
            cmd_request <= 1'b0;
            case (command)
                CMD_TX: current_state <= STATE_TX_PREP;
                CMD_RESET: current_state <= STATE_RESET_PREP;
                CMD_IDLE: current_state <= STATE_CMD_FETCH_START; 
                default: current_state <= STATE_CMD_FETCH_START;
            endcase
        end

        STATE_TX_PREP: begin
            encoder_command <= CMD_TX;
            rgb_bits_sent <= 0;
            rgb_buffer <= rgb_message_encoded;
            current_state <= STATE_TX;
        end

        STATE_TX: begin
            if (encoder_requests_data) begin
                rgb_buffer <= rgb_buffer << 1;
                rgb_bits_sent = rgb_bits_sent + 1;

                if (rgb_bits_sent == 24 - 1) begin
                    current_state <= STATE_TX_DATA_PREFETCH_START;
                end
            end
        end

        STATE_TX_DATA_PREFETCH_START: begin
            data_request <= 1'b1;
            current_state <= STATE_TX_DATA_PREFETCH_END;
        end

        STATE_TX_DATA_PREFETCH_END: begin
            data_request <= 1'b0;
            if (command == CMD_TX) current_state <= STATE_TX_PREP;
            else current_state <= STATE_INIT;
        end

        STATE_RESET_PREP: begin
            encoder_command <= CMD_RESET;
            if (encoder_requests_command) current_state <= STATE_RESET;
        end

        STATE_RESET: begin
            encoder_command <= CMD_IDLE;
            if (encoder_requests_command) current_state <= STATE_CMD_FETCH_START;
        end 

        default: current_state <= STATE_INIT;
    endcase
end

endmodule