// module ws2812_rgb_encoder (
//     wire clk,
//     wire[7:0] r,
//     wire[7:0] g,
//     wire[7:0] b,
//     wire[1:0] command,
//     wire cmd_wait,
//     reg data_out,
// );

// parameter CLK_FREQ_KHZ      = 10000;

// localparam CMD_IDLE   = 2'b00;
// localparam CMD_TX     = 2'b01;
// localparam CMD_RESET  = 2'b10;

// reg[1:0] current_state;
// reg[23:0] color_buffer;



// ws2812_unipolar_rz_encoder #(CLK_FREQ_KHZ = CLK_FREQ_KHZ) encoder(

// );

// always @(posedge clk) begin
//     case (current_state)
//         CMD_IDLE: begin
//             current_state <= command;
//             tx_data <= databit;
//             cycle_counter <= 0;
//             data_output <= 0;

//             cmd_wait <= 1'b1;
//         end
        
//         CMD_TX: begin
//             data_output = ((cycle_counter < T_HI_TRUE_TICKS) && (tx_data == 1'b1)) ||
//                           ((cycle_counter < T_HI_FALSE_TICKS) && (tx_data == 1'b0));
            
//             if (cycle_counter >= T_PERIOD_TICKS-1) begin
//                 cycle_counter = 0;
//                 tx_data = databit;

//                 if (command != CMD_TX) current_state <= CMD_IDLE;
//             end else 
//                 cycle_counter = cycle_counter + 1;
//         end  
        
//         CMD_RESET: begin end
//         default: current_state <= CMD_IDLE;
//     endcase
// end
    
// endmodule