package spi_monitor_pkg;
// importing needed pkgs and macros
    import uvm_pkg::*;
    import spi_seq_item_pkg::*;
    `include "uvm_macros.svh"

    // creating the class
    class spi_monitor extends uvm_component;
        `uvm_component_utils(spi_monitor)

        // analysis port of agent
        uvm_analysis_port #(spi_seq_item) mon_aport;

        // giving handles
        virtual SPI_IF SPI_vif;
        virtual SPI_GM_IF SPI_GM_vif;
        spi_seq_item res_seq_item;

        // constructor
        function new(string name = "spi_monitor", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        //build phase
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            mon_aport = new("mon_aport", this);
        endfunction
        
        //run phase
        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            forever begin
               res_seq_item = spi_seq_item::type_id::create("res_seq_item",this);
               @(negedge SPI_vif.clk);
               res_seq_item.rst_n= SPI_vif.rst_n;
                res_seq_item.SS_n= SPI_vif.SS_n;
                res_seq_item.MOSI = SPI_vif.MOSI;
                res_seq_item.tx_valid = SPI_vif.tx_valid;
                res_seq_item.tx_data = SPI_vif.tx_data; 
               res_seq_item.MISO = SPI_vif.MISO; 
               res_seq_item.rx_valid = SPI_vif.rx_valid; 
               res_seq_item.rx_data = SPI_vif.rx_data;  

                if (SPI_GM_vif != null) begin
                    res_seq_item.MISO_ref = SPI_GM_vif.MISO;
                    res_seq_item.rx_valid_ref = SPI_GM_vif.rx_valid;
                    res_seq_item.rx_data_ref = SPI_GM_vif.rx_data;
                end

               mon_aport.write (res_seq_item);
               `uvm_info("run_phase", res_seq_item.convert2string(),UVM_HIGH)
            end
        endtask

    endclass
endpackage