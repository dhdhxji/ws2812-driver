module ws2812_unipolar_rz_encoder (
    input wire databit,
	input wire clk,
    input wire[1:0] command,
	output reg cmd_wait,
	output reg data_output
);

parameter CLK_FREQ_KHZ      = 10000;
parameter T_HI_TRUE_NS      = 700;
parameter T_HI_FALSE_NS     = 300;
parameter T_PERIOD_NS       = 1100;
parameter T_RESET_NS        = 80000;

localparam CLK_PERIOD_NS    = (1000 * 1000 * 1000) / (CLK_FREQ_KHZ * 1000);
localparam T_HI_TRUE_TICKS  = $rtoi($ceil(T_HI_TRUE_NS / CLK_PERIOD_NS));
localparam T_HI_FALSE_TICKS = $rtoi($ceil(T_HI_FALSE_NS / CLK_PERIOD_NS));
localparam T_PERIOD_TICKS   = $rtoi(T_PERIOD_NS / CLK_PERIOD_NS);
localparam COUNTER_SIZE     = $rtoi($ceil($clog2(T_PERIOD_TICKS + 1)));


localparam CMD_IDLE   = 2'b00;
localparam CMD_TX     = 2'b01;
localparam CMD_RESET  = 2'b10;

reg[1:0] current_state;
reg[COUNTER_SIZE-1:0] cycle_counter;
reg tx_data;

always @(posedge clk) begin
    case (current_state)
        CMD_IDLE: begin
            current_state <= command;
            tx_data <= databit;
            cycle_counter <= 0;
            data_output <= 0;

            cmd_wait <= 1'b1;
        end
        
        CMD_TX: begin
            data_output = ((cycle_counter < T_HI_TRUE_TICKS) && (tx_data == 1'b1)) ||
                          ((cycle_counter < T_HI_FALSE_TICKS) && (tx_data == 1'b0));
            
            if (cycle_counter >= T_PERIOD_TICKS-1) begin
                cycle_counter = 0;
                tx_data = databit;

                if (command != CMD_TX) current_state <= CMD_IDLE;
            end else 
                cycle_counter = cycle_counter + 1;
        end  
        
        CMD_RESET: begin end
        default: current_state <= CMD_IDLE;
    endcase
end

    
endmodule