module ws2812_bit_encoder (
    input wire databit,
	input wire clk_3p33mhz,
    input wire[1:0] command,
	output reg cmd_wait,
	output reg data_output
);

localparam CMD_IDLE   = 2'b00;
localparam CMD_TX     = 2'b01;
localparam CMD_RESET  = 2'b10; 

reg[1:0] current_state;
reg[3:0] cycle_counter;
reg tx_data;

always @(posedge clk_3p33mhz) begin
    case (current_state)
        CMD_IDLE: begin
            current_state <= command;
            tx_data <=databit;
        end
        
        CMD_TX: begin
            case(cycle_counter)
                2'b00: begin
                    data_output <= 1;
                    cycle_counter <= cycle_counter + 1;
                end
                2'b01: begin
                    data_output <= tx_data;
                    cycle_counter <= cycle_counter + 1;
                end
                default: begin
                    cycle_counter <= 0;
                    data_output <= 0;
                    if(CMD_TX != command) current_state <= CMD_IDLE;
                    else tx_data <= databit;
                end
            endcase
        end  
        
        CMD_RESET: begin end
        default: current_state <= CMD_IDLE;
    endcase
end

    
endmodule