module ram_sva( clk , rst_n , rx_valid , din , tx_valid , dout );


input clk , rst_n , rx_valid ;
input [9:0] din ;
input tx_valid ;
input [7:0] dout ;


property reset_outputs_low;
    @(posedge clk)
        (!rst_n) |=> (tx_valid == 0 && dout == 0);
endproperty
assert property(reset_outputs_low)
    else $error("ERROR : reset operation");
cover property(reset_outputs_low);

property tx_valid_low ;
    @(posedge clk) disable iff(!rst_n)
        (rx_valid && (din[9:8]== 2'b00 || din[9:8]== 2'b01 || din[9:8]== 2'b10) ) |=> (tx_valid == 0);
endproperty
assert property(tx_valid_low)
    else $error("ERROR : tx valid during input command phase");
cover property(tx_valid_low);


property tx_valid_high ;
    @(posedge clk) disable iff(!rst_n)
        (din[9:8] == 2'b11) |=> $rose(tx_valid)[->1] ##1 $fell(tx_valid)[->1] ;
endproperty
assert property(tx_valid_high)
    else $error("ERROR : tx valid after read data");
cover property(tx_valid_high);


property write_data_after_address ;
    @(posedge clk) disable iff(!rst_n)
        (din[9:8]== 2'b00) |=> (din[9:8]== 2'b01 [->1] );
endproperty
assert property(write_data_after_address)
    else $error("ERROR : write data after address");
cover property(write_data_after_address);


property read_data_after_address ;
    @(posedge clk) disable iff(!rst_n)
        (din[9:8]== 2'b10) |=> (din[9:8]== 2'b11 [->1] );
endproperty
assert property(read_data_after_address)
    else $error("ERROR : read data fter addressa");
cover property(read_data_after_address);

endmodule

