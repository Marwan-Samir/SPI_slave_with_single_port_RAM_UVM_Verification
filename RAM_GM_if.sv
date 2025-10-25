interface ram_GM_if (clk);

input clk ;
logic rst_n , rx_valid , tx_valid ;
logic [9:0] din ;
logic [7:0] dout ;

endinterface : ram_GM_if
