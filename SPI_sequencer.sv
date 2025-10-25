package spi_sequencer_pkg;
    // importing needed pkgs and macros
    import uvm_pkg::*;
    import spi_seq_item_pkg::*;
    `include "uvm_macros.svh"

    // creating the class
    class spi_sequencer extends uvm_sequencer #(spi_seq_item);
        `uvm_component_utils(spi_sequencer)

        // constructor
        function new(string name = "spi_sequencer", uvm_component parent = null);
            super.new(name, parent);
        endfunction
    endclass
endpackage