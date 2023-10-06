module ws2812_unipolar_rz_encoder (
    input wire databit,
	input wire clk,
    input wire[1:0] command,
	output reg cmd_request,
    output reg data_request,
	output reg encoded_output
);

parameter CLK_FREQ_KHZ      = 10000;
parameter T_HI_TRUE_NS      = 700;
parameter T_HI_FALSE_NS     = 300;
parameter T_PERIOD_NS       = 1100;
parameter T_RESET_NS        = 80000;

localparam CLK_PERIOD_NS    = (1000 * 1000 * 1000) / (CLK_FREQ_KHZ * 1000);
localparam T_HI_TRUE_TICKS  = T_HI_TRUE_NS / CLK_PERIOD_NS;
localparam T_HI_FALSE_TICKS = T_HI_FALSE_NS / CLK_PERIOD_NS;
localparam T_PERIOD_TICKS   = T_PERIOD_NS / CLK_PERIOD_NS;
localparam T_RESET_TICKS    = T_RESET_NS / CLK_PERIOD_NS;
localparam COUNTER_SIZE     = $clog2(T_RESET_TICKS + 1);


localparam CMD_IDLE   = 2'b00;
localparam CMD_TX     = 2'b01;
localparam CMD_RESET  = 2'b10;


localparam STATE_CMD_FETCH_START        = 3'd0;
localparam STATE_CMD_FETCH_END          = 3'd1;
localparam STATE_TX_PREP                = 3'd2;
localparam STATE_TX                     = 3'd3;
localparam STATE_TX_DATA_PREFETCH_START = 3'd4;
localparam STATE_TX_DATA_PREFETCH_END   = 3'd5;
localparam STATE_RESET_PREP             = 3'd6;
localparam STATE_RESET                  = 3'd7;


reg[2:0] current_state;
reg[COUNTER_SIZE-1:0] cycle_counter;
reg tx_data;

wire encoded_bit_logic = ((cycle_counter < T_HI_TRUE_TICKS) && (tx_data == 1'b1)) ||
                         ((cycle_counter < T_HI_FALSE_TICKS) && (tx_data == 1'b0));

always @(posedge clk) begin
    case (current_state)
        STATE_CMD_FETCH_START: begin
            data_request <= 1'b0;
            encoded_output <= 1'b0;
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
            tx_data <= databit;
            cycle_counter <= 0;
            current_state <= STATE_TX;
        end 

        STATE_TX: begin
            encoded_output <= encoded_bit_logic;
            cycle_counter <= cycle_counter + 1'd1;
            if (cycle_counter == (T_PERIOD_TICKS - 4)) current_state <= STATE_TX_DATA_PREFETCH_START;
        end 

        STATE_TX_DATA_PREFETCH_START: begin
            encoded_output <= encoded_bit_logic;
            cycle_counter <= cycle_counter + 1'd1;
            data_request <= 1'b1;
            current_state <= STATE_TX_DATA_PREFETCH_END;
        end 

        STATE_TX_DATA_PREFETCH_END: begin
            encoded_output <= encoded_bit_logic;
            cycle_counter <= cycle_counter + 1'd1;
            data_request <= 1'b0;

            if (command == CMD_TX) current_state <= STATE_TX_PREP;
            else current_state <= STATE_CMD_FETCH_START;
        end

        STATE_RESET_PREP: begin
            tx_data <= 0;
            cycle_counter <= 0;
            current_state <= STATE_RESET;
        end 

        STATE_RESET: begin
            cycle_counter <= cycle_counter + 1'd1;
            if (cycle_counter >= T_RESET_TICKS) current_state <= STATE_CMD_FETCH_START;
        end 

        default: current_state <= STATE_CMD_FETCH_START;
    endcase
end

    
endmodule