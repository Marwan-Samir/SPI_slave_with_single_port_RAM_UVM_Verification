interface SPI_GM_IF #(
  parameter IDLE = 3'b000,
  parameter CHK_CMD = 3'b001,
  parameter WRITE = 3'b010,
  parameter READ_ADDRESS = 3'b011,
  parameter READ_DATA = 3'b100

) (input bit clk);

  logic rst_n, SS_n, MOSI, MISO, rx_valid, tx_valid ;
  logic [9:0] rx_data;
  logic [7:0] tx_data;

endinterface