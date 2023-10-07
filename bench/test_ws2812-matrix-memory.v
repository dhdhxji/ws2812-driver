`timescale 1 ns/ 1 ps

module test_ws2812_matrix_memory;

reg clk;
always #50 clk <= !clk;

localparam MATRIX_WIDTH	    = 4;
localparam MATRIX_HEIGHT    = 1;

localparam CMD_IDLE   = 2'b00;
localparam CMD_TX     = 2'b01;
localparam CMD_RESET  = 2'b10;

localparam STATE_INIT_BEGIN			    = 0;
localparam STATE_INIT_END               = 1;
localparam STATE_DISPLAY_PREP           = 2;
localparam STATE_DISPLAY_POS_INCREMENT  = 3;
localparam STATE_DISPLAY_PIXEL_FETCH    = 4;
localparam STATE_DISPLAY                = 5;
localparam STATE_DELAY_PREP             = 6;
localparam STATE_DELAY                  = 7;

wire cmd_req;
wire data_req;
reg[1:0] cmd;
wire data_out;

reg[7:0] r;
reg[7:0] g;
reg[7:0] b;


ws2812_rgb_controller rgb_controller(
    clk,
    r,
    g,
    b,
    cmd,
    cmd_req,
    data_req,
    data_out
);


reg[7:0] fb_row;
reg[7:0] fb_column;
wire[7:0] fb_r_read;
wire[7:0] fb_g_read;
wire[7:0] fb_b_read;

reg[7:0] fb_row_write;
reg[7:0] fb_column_write;
reg[7:0] fb_r_write;
reg[7:0] fb_g_write;
reg[7:0] fb_b_write;
reg fb_write;
reg fb_clear;

ws2812_matrix_memory #(.WIDTH(MATRIX_WIDTH), .HEIGTH(MATRIX_HEIGHT)) framebuffer(
	fb_row,
	fb_column,
	fb_r_read,
	fb_g_read,
	fb_b_read,
	fb_r_write,
	fb_g_write,
	fb_b_write,
	fb_write,
	fb_clear
);


reg[3:0] current_state;
always @(posedge clk) begin
	
	case (current_state)
		STATE_INIT_BEGIN: begin
			fb_row <= 8'd0;
			fb_column <= 8'd0;

			fb_clear <= 1'b1;
			current_state <= STATE_INIT_END;
		end

		STATE_INIT_END: begin
			fb_clear <= 1'b0;

            r <= fb_r_read;
			g <= fb_g_read;
			b <= fb_b_read;

			current_state <= STATE_DISPLAY_PREP;
		end

		STATE_DISPLAY_PREP: begin
			cmd <= CMD_TX;
            if (cmd_req) current_state <= STATE_DISPLAY_POS_INCREMENT;
		end

		STATE_DISPLAY_POS_INCREMENT: begin
            if (fb_column + 1 >= MATRIX_WIDTH) begin
                fb_column <= 1'd0;

                if (fb_row + 1 >= MATRIX_HEIGHT) begin
                    fb_row <= 1'd0;
                    current_state <= STATE_DELAY_PREP;
                end
                else begin
                    fb_row <= fb_row + 1'd1;
                    current_state <= STATE_DISPLAY_PIXEL_FETCH;
                end
            end
            else begin
                fb_column <= fb_column + 1'd1;
                current_state <= STATE_DISPLAY_PIXEL_FETCH;
            end
		end

        STATE_DISPLAY_PIXEL_FETCH: begin
            r <= fb_r_read;
			g <= fb_g_read;
			b <= fb_b_read;

            current_state <= STATE_DISPLAY;
        end

        STATE_DISPLAY: begin
			if (data_req) current_state <= STATE_DISPLAY_POS_INCREMENT;
        end
		
		
		STATE_DELAY_PREP: begin 
			cmd <= CMD_RESET;
			if (cmd_req) current_state <= STATE_DELAY;
		end
		
		STATE_DELAY: begin 
			if (cmd_req) current_state <= STATE_DISPLAY_PREP;
		end
		
		default: current_state <= STATE_INIT_BEGIN;

	endcase

end

initial begin
    $dumpfile("test_ws2812_matrix_memory.vcd");
    $dumpvars(0, test_ws2812_matrix_memory);
    
    //cmd = 2'b01;
    clk = 0;

    #1500000 $finish;
end

endmodule