package ram_read_write_seq_pkg;

import ram_seq_item_pkg::*;  
import uvm_pkg::*;
`include "uvm_macros.svh"

class ram_read_write_seq extends uvm_sequence #(ram_seq_item);

    `uvm_object_utils(ram_read_write_seq)

    ram_seq_item seq_item ;

    function new(string name = "ram_read_write_seq");
        super.new(name);
    endfunction

    task body;

        seq_item = ram_seq_item::type_id::create("seq_item");
        repeat (5000) begin

            start_item(seq_item);

            assert(seq_item.randomize() with { seq_mode == READ_WRITE ;} ) ;

            finish_item(seq_item);
      end

    endtask

endclass

endpackage
