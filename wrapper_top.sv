import uvm_pkg::*;
`include "uvm_macros.svh"
import wrapper_test_pkg::*;

module wrapper_top(clk);

  input bit clk; 
  initial begin    
   forever #1 clk = ~clk;
  end



  wrapper_if            wif        (clk);
  wrapper_ref_if        wrif       (clk);
  ram_GM_if             ramGMif    (clk);
  ram_if                ramif      (clk);
  SPI_IF                if_inst    (clk);
  SPI_GM_IF             gm_if_inst (clk);

  WRAPPER               dut (
    .clk                (clk),
    .MISO               (wif.MISO),
    .rst_n              (wif.rst_n),
    .SS_n               (wif.SS_n),
    .MOSI               (wif.MOSI)
  );

  wrapper_ref           dut_ref (
    .clk                (clk),
    .MISO_ref           (wrif.MISO_ref),
    .rst_n_ref          (wrif.rst_n),
    .SS_n_ref           (wrif.SS_n_ref),
    .MOSI_ref           (wrif.MOSI_ref)
  );

  /*bind WRAPPER wrapper_sva u_wrapper_sva (
    .clk                 (clk),
    .rst_n               (wif.rst_n),
    .MISO                (wif.MISO),
    .rx_data             (wif.rx_data),
    .MOSI                (wif.MOSI),
    .SS_n                (wif.SS_n)
  );

  bind SPI_SLAVE SPI_ASSIRTION assert_inst (
   .clk                   (wif.clk),
   .rst_n                 (wif.rst_n),
   .MOSI                  (wif.MOSI),
   .MISO                  (wif.MISO),
   .rx_valid              (wif.rx_valid_spi),
   .rx_data               (wif.rx_data),
   .SS_n                  (wif.SS_n)
  );
*///already in spi design cause thay depend on internal sigals

  bind RAM ram_sva        ram_sva_inst (
    .clk                  (dut.clk),
    .rst_n                (dut.rst_n),
    .rx_valid             (dut.rx_valid),
    .din                  (dut.rx_data),
    .tx_valid             (dut.tx_valid),
    .dout                 (dut.tx_data)
  );

  assign if_inst.rst_n                = dut.rst_n;
  assign ramif.rst_n                  = dut.rst_n;
  assign gm_if_inst.rst_n             = dut_ref.rst_n_ref;
  assign ramGMif.rst_n                = dut_ref.rst_n_ref;

  assign if_inst.SS_n                 = dut.SS_n;
  assign if_inst.MOSI                 = dut.MOSI;
  assign gm_if_inst.MOSI              = dut_ref.MOSI_ref;
  assign gm_if_inst.SS_n              = dut_ref.SS_n_ref;
  assign if_inst.rx_data              = dut.rx_data;

  assign if_inst.tx_valid             = dut.tx_valid;
  assign if_inst.tx_data              = dut.tx_data;
  assign gm_if_inst.tx_valid          = dut.tx_valid;
  assign gm_if_inst.tx_data           = dut.tx_data;
  assign ramif.rx_valid               = dut.rx_valid;
  assign ramif.din                    = dut.rx_data;
  assign ramGMif.rx_valid             = dut.rx_valid;
  assign ramGMif.din                  = dut.rx_data;
  assign ramif.tx_valid              = dut.tx_valid;



  initial begin
    uvm_config_db#(virtual wrapper_ref_if)::set(null, "uvm_test_top", "wrifv", wrif);
    uvm_config_db#(virtual wrapper_if)::set(null, "uvm_test_top", "wifv", wif);
    uvm_config_db#(virtual ram_if)::set(null, "uvm_test_top", "RAM_IF", ramif);
    uvm_config_db#(virtual ram_GM_if)::set(null, "uvm_test_top", "RAM_GM_IF", ramGMif);
    uvm_config_db#(virtual SPI_IF)::set(null, "uvm_test_top", "spi", if_inst);
    uvm_config_db#(virtual SPI_GM_IF)::set(null, "uvm_test_top", "spi_ref", gm_if_inst);
    run_test("wrapper_test");
  end
endmodule