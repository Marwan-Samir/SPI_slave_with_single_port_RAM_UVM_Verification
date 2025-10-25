module ram_ref ( clk , rst_n , rx_valid , din , tx_valid , dout );

parameter MEM_DEPTH = 256 ;
parameter ADDR_SIZE = 8 ;

input clk , rst_n , rx_valid ;
input [9:0] din ;
output reg tx_valid ;
output reg [7:0] dout ;

reg [7:0] mem [MEM_DEPTH-1:0] ;

reg [ADDR_SIZE-1:0] addr_wr , addr_rd ;

wire [1:0] command = din [9:8] ;
wire [7:0] data = din [7:0] ;


always @( posedge clk ) begin
    if (!rst_n) begin
        addr_wr <= 0 ;
        addr_rd <= 0 ;
        dout <= 0 ;
        tx_valid <= 0 ; 
    end
    else begin
        if (rx_valid) begin
            tx_valid <= 0 ;
            case (command)
                2'b00: addr_wr <= data ;
                2'b01: mem[addr_wr] <= data ;
                2'b10: addr_rd <= data ;
                default : begin
                    dout <= mem[addr_rd] ;
                    tx_valid <= 1 ;
                end      
            endcase
        end
    end
end

endmodule
