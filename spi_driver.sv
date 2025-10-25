package spi_driver_pkg;
// importing needed pkgs and macros
import uvm_pkg::*;
import spi_seq_item_pkg::*;
`include "uvm_macros.svh"
    class spi_driver extends uvm_driver #(spi_seq_item);
     `uvm_component_utils(spi_driver)

        //giving handles
        virtual SPI_IF SPI_vif;
        virtual SPI_GM_IF SPI_GM_vif;
        spi_seq_item stim_seq_item;

        //constructor 
        function new(string name = "spi_driver", uvm_component parent = null);
            super.new(name, parent);
        endfunction //new()

        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            forever begin
                stim_seq_item = spi_seq_item::type_id::create("stim_seq_item",this);
                seq_item_port.get_next_item(stim_seq_item);
                SPI_vif.rst_n= stim_seq_item.rst_n;
                SPI_vif.SS_n= stim_seq_item.SS_n;
                SPI_vif.tx_valid  = stim_seq_item.tx_valid;
                SPI_vif.tx_data = stim_seq_item.tx_data;
                SPI_vif.MOSI = stim_seq_item.MOSI;
                if (SPI_GM_vif != null) begin
                    SPI_GM_vif.rst_n= stim_seq_item.rst_n;
                    SPI_GM_vif.SS_n= stim_seq_item.SS_n;
                    SPI_GM_vif.tx_valid  = stim_seq_item.tx_valid;
                    SPI_GM_vif.tx_data = stim_seq_item.tx_data;
                    SPI_GM_vif.MOSI = stim_seq_item.MOSI;
                end

                @(negedge SPI_vif.clk);
                seq_item_port.item_done();

                `uvm_info("run_phase", stim_seq_item.convert2string_stimulus(),UVM_HIGH)

            end
        endtask: run_phase
    endclass
endpackage
