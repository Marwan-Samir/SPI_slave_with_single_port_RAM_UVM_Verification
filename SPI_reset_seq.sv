package spi_reset_seq_pkg;

// importing needed pkgs and macros
    import uvm_pkg::*;
    import spi_seq_item_pkg::*;
    `include "uvm_macros.svh"

    // creating the class
    class spi_reset_seq extends uvm_sequence #(spi_seq_item);
        `uvm_object_utils(spi_reset_seq)

        // handling the seq_item
        spi_seq_item seq_item;

        // constructor
        function new(string name = "spi_reset_seq");
            super.new(name);
        endfunction

        // generating randomized stimulus inputs and outputs
        task body;
            seq_item = spi_seq_item::type_id::create("seq_item");
                start_item(seq_item);
                seq_item.rst_n = 0;
                seq_item.SS_n = 0;
                seq_item.MOSI = 0;
                seq_item.tx_valid = 0;
                seq_item.tx_data = 0;
                finish_item(seq_item);
        endtask
       
    endclass
endpackage