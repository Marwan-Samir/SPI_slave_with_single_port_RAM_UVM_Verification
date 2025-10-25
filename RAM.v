module RAM (din,clk,rst_n,rx_valid,dout,tx_valid);

input      [9:0] din;
input            clk, rst_n, rx_valid;

output reg [7:0] dout;
output reg       tx_valid;

reg [7:0] mem  [255:0];  //mem not MEM//

reg [7:0] Rd_Addr, Wr_Addr;

always @(posedge clk) begin
    if (~rst_n) begin
        dout <= 0;
        tx_valid <= 0;
        Rd_Addr <= 0;
        Wr_Addr <= 0;
    end
    else  begin   //begin..end//                                   
        if (rx_valid) begin
            tx_valid <= 0 ; 
            case (din[9:8])
                2'b00 : begin
                    Wr_Addr <= din[7:0];
                    tx_valid <= 0 ;
                end
                2'b01 :begin
                    mem [Wr_Addr] <= din[7:0];
                    tx_valid <= 0 ;
                end 
                2'b10 :begin
                    Rd_Addr <= din[7:0];   
                    tx_valid <= 0 ;             
                end 
                2'b11 : begin
                    dout <= mem [Rd_Addr]; //*****fixed this bug here, from write address to read address*****//
                    tx_valid <= 1 ;     //**put the tx_valid in case statement**//
                end
                default : dout<= 0 ;
                    
            endcase
        end
    end
end

endmodule
