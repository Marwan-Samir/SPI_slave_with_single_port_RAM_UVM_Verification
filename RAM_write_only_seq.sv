package ram_write_seq_pkg;

import ram_seq_item_pkg::*;  
import uvm_pkg::*;
`include "uvm_macros.svh"

class ram_write_only_seq extends uvm_sequence #(ram_seq_item);

    `uvm_object_utils(ram_write_only_seq)

    ram_seq_item seq_item ;

    function new(string name = "ram_write_only_seq");
        super.new(name);
    endfunction

    task body;

        seq_item = ram_seq_item::type_id::create("seq_item");
        repeat (5000) begin
            
            start_item(seq_item);

            assert(seq_item.randomize() with { seq_mode == WRITE_ONLY ;} ) ;

            finish_item(seq_item);
        
        end

    endtask

endclass

endpackage
