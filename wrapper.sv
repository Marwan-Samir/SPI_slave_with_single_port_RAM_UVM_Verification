module WRAPPER (clk, rst_n, MOSI, MISO, SS_n);


  input  bit   clk;
  input  logic rst_n;
  input  logic MOSI;
  output logic MISO;
  input  logic SS_n;

  logic tx_valid;
  logic rx_valid; 
  logic [9:0] rx_data; 
  logic [7:0] tx_data;


  SPI_SLAVE        SLAVE_instance (
    .clk           (clk),
    .MOSI          (MOSI),
    .MISO          (MISO),
    .SS_n          (SS_n),
    .rst_n         (rst_n),
    .rx_data       (rx_data),
    .rx_valid      (rx_valid),
    .tx_data       (tx_data),
    .tx_valid      (tx_valid)
  );


  RAM              RAM_instance (
  	.clk           (clk),
    .rst_n         (rst_n),
    .tx_valid      (tx_valid),
    .dout          (tx_data),
    .din           (rx_data),
    .rx_valid      (rx_valid)
  );


  `ifdef SIM

  property reset_output_low;
      @(posedge clk)
          (!rst_n) |=> (MISO== 0);
  endproperty
  assert property(reset_output_low)
      else $error("ERROR : reset operation");
  cover property(reset_output_low);


  property MISO_stable;
      @(posedge clk) disable iff (!rst_n) 
        (!tx_valid) |=> $stable(MISO)[->1];
  endproperty
  assert property(MISO_stable)
      else $error("ERROR : MISO stability");
  cover property(MISO_stable);



  `endif
  
endmodule