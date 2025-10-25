package spi_config_pkg;
import uvm_pkg::*;
`include "uvm_macros.svh"

    class spi_config extends uvm_object;
       `uvm_object_utils(spi_config)

        virtual SPI_IF SPI_vif;
        virtual SPI_GM_IF SPI_GM_vif;
        uvm_active_passive_enum is_active;
        
        function new(string name = "spi_config");
            super.new(name);
            is_active = UVM_ACTIVE;
        endfunction
 
    endclass
endpackage

