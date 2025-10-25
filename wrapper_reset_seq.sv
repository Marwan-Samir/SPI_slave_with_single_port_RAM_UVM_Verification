package wrapper_reset_seq_pkg;

import wrapper_seq_item_pkg::*; 
import uvm_pkg::*;
`include "uvm_macros.svh"

    class wrapper_reset_seq extends uvm_sequence #(wrapper_seq_item);
    `uvm_object_utils(wrapper_reset_seq)

        wrapper_seq_item seq_item;

        function new(string name = "wrapper_reset_seq");
            super.new(name);
        endfunction

        task body;
            seq_item = wrapper_seq_item::type_id::create("seq_item");
            start_item (seq_item);
            seq_item.rst_n        = 0;
            seq_item.SS_n         = 0;
            seq_item.MOSI         = 0;
            seq_item.MISO         = 0;
            finish_item(seq_item);
        endtask 
    endclass
endpackage
