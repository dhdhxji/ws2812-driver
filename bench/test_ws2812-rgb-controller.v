`timescale 1 ns/ 1 ps

module test_ws2812_rgb_controller;

localparam CMD_IDLE   = 2'b00;
localparam CMD_TX     = 2'b01;
localparam CMD_RESET  = 2'b10;

localparam STATE_DISPLAY_PREP       = 0;
localparam STATE_DISPLAY            = 1;
localparam STATE_DELAY_PREP         = 2;
localparam STATE_DELAY              = 3;

reg clk;
wire cmd_req;
wire data_req;
reg[1:0] cmd;
wire data_out;

reg[3:0] current_state;

initial begin
    $dumpfile("test_ws2812_rgb_controller.vcd");
    $dumpvars(0, test_ws2812_rgb_controller);
    
    cmd = 2'b01;
    clk = 0;

    #1500000 $finish;
end

always #50 clk <= !clk;

ws2812_rgb_controller rgb_controller(
    clk,
    8'd255,
    8'd0,
    8'd128,
    cmd,
    cmd_req,
    data_req,
    data_out
);



always @(clk) begin
	
	case (current_state)
		STATE_DISPLAY_PREP: begin
			cmd <= CMD_TX;
			if (cmd_req) current_state <= STATE_DISPLAY;
		end
		
		STATE_DISPLAY: begin 
			cmd <= CMD_IDLE;
			if (cmd_req) current_state <= STATE_DELAY_PREP;
		end
		
		STATE_DELAY_PREP: begin 
			cmd <= CMD_RESET;
			if (cmd_req) current_state <= STATE_DELAY;
		end
		
		STATE_DELAY: begin 
			if (cmd_req) current_state <= STATE_DISPLAY_PREP;
		end
		
		default: current_state <= STATE_DISPLAY_PREP;
	endcase

end

endmodule