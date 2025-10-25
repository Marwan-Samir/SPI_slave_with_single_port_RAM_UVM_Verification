module wrapper_ref (clk, rst_n_ref,MOSI_ref, MISO_ref, SS_n_ref);


  input  bit   clk;
  input  logic rst_n_ref;
  input  logic MOSI_ref;
  output logic MISO_ref;
  input  logic SS_n_ref;


  wire  tx_valid_ref; 
  logic rx_valid_ref; 
  logic [9:0] rx_data_ref; 
  logic [7:0] tx_data_ref;

  SPI_REF          SLAVE_ref_instance (
   .clk            (clk),
   .MISO           (MISO_ref),
   .MOSI           (MOSI_ref),
   .SS_n           (SS_n_ref),
   .rst_n          (rst_n_ref),
   .tx_data        (tx_data_ref),
   .tx_valid       (tx_valid_ref),
   .rx_data        (rx_data_ref),
   .rx_valid       (rx_valid_ref)
  );


  ram_ref          RAM_ref_instance   (
  	.clk           (clk),
    .rst_n         (rst_n_ref),
    .din           (rx_data_ref),
    .tx_valid      (tx_valid_ref),
    .dout          (tx_data_ref),
    .rx_valid      (rx_valid_ref)
  );
endmodule 