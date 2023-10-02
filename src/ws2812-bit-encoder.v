module ws2812_bit_encoder (
    input wire databit,
	input wire clk_3p33mhz,
    input wire[1:0] command,
	output reg cmd_wait,
	output reg data_output,
);

localparam CMD_START_IDLE   = 0'b00;
localparam CMD_TX           = 0'b01;
localparam CMD_RESET        = 0'b10; 

reg[1:0] current_state;

always @(clk_3p33mhz) begin
    case (current_state)
        CMD_START_IDLE: current_state <= command;
        CMD_TX:    
        CMD_RESET:
        default:
    endcase
end

    
endmodule