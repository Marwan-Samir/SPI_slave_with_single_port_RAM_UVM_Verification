package spi_main_seq_pkg;

// importing needed pkgs and macros
    import uvm_pkg::*;
    import spi_seq_item_pkg::*;
    `include "uvm_macros.svh"

    // creating the class
    class spi_main_seq extends uvm_sequence #(spi_seq_item);
        `uvm_object_utils(spi_main_seq)

        // handling the seq_item
        spi_seq_item seq_item;

        // constructor
        function new(string name = "spi_main_seq");
            super.new(name);
        endfunction

        //generating randomized stimulus inputs and outputs
        task body;
            seq_item = spi_seq_item::type_id::create("seq_item");

            repeat(10000) begin
                start_item(seq_item);
                assert(seq_item.randomize());
                finish_item(seq_item);
            end
        endtask
       
    endclass
endpackage