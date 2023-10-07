module ws2812_matrix_memory (
    input wire[7:0] row,
    input wire[7:0] column,
    output wire[7:0] r_read,
    output wire[7:0] g_read,
    output wire[7:0] b_read,
    
    input wire[7:0] r_write,
    input wire[7:0] g_write,
    input wire[7:0] b_write,
    input wire write,
    input wire clear
);

parameter WIDTH     = 32;
parameter HEIGTH    = 16;

reg[7:0] framebuffer[WIDTH-1:0][HEIGTH-1:0][2:0];

assign r_read = framebuffer[column][row][0];
assign g_read = framebuffer[column][row][1];
assign b_read = framebuffer[column][row][2];

integer x, y;
always @(posedge write, posedge clear) begin
    if (write) begin
        framebuffer[column][row][0] <= r_write;
        framebuffer[column][row][1] <= g_write;
        framebuffer[column][row][2] <= b_write;
    end
    else if (clear) begin
        for (x = 0; x < WIDTH; x = x+1) begin
            for (y = 0; y < HEIGTH; y = y+1) begin
                framebuffer[x][y][0] <= 8'd255;
                framebuffer[x][y][1] <= 8'd0;
                framebuffer[x][y][2] <= 8'd0;
            end
        end
    end
end
    
endmodule