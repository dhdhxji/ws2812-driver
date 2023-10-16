module ws2812_on_chip_ram (
    clk,
    addr,
    write_data,
    read_data,
    we,
    clear

    // TODO: Implement chip select when real hardware memory will be used to 
    // avoid unexpected R/W operations
    //input wire cs,
    
    // TODO: For cases where slow RAM used, to indicate that operation is 
    // completed
    //output wire done
);

parameter ADDR_BUS_WIDTH_BITS   = 8;
parameter WORD_SIZE_BITS        = 8;
parameter MEM_SIZE_WORDS        = 3*5;

input wire clk;
input wire[ADDR_BUS_WIDTH_BITS-1:0] addr;
input wire[WORD_SIZE_BITS-1:0] write_data;
output wire[WORD_SIZE_BITS-1:0] read_data;

input wire we;
input wire clear;


reg[WORD_SIZE_BITS-1:0] data[MEM_SIZE_WORDS-1];
reg[WORD_SIZE_BITS-1:0] output_buffer;

assign read_data = output_buffer;

integer i;
always @(posedge clk) begin
    case (we)
        1'b0: output_buffer <= data[addr];
        1'b1: data[addr] <= write_data;
        default: ;
    endcase

    case (clear)
        1'b0: ;
        1'b1: begin
            for (i = 0; i < MEM_SIZE_WORDS; i = i+1) data[i] <= 1'b0;
        end
        default: ;
    endcase
end
    
endmodule