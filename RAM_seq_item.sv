package ram_seq_item_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

typedef enum bit [1:0] { WRITE_ADDR, WRITE_DATA, READ_ADDR, READ_DATA } cmd_e ;
typedef enum bit [1:0] { WRITE_ONLY , READ_ONLY , READ_WRITE} seq_mode_e ;

class ram_seq_item extends uvm_sequence_item;
    
    `uvm_object_utils(ram_seq_item)

    rand logic rst_n;
    rand logic rx_valid;
    rand cmd_e command;
    rand logic [7:0] data;

    logic tx_valid ;
    logic [7:0] dout ;

    logic tx_valid_ref ;
    logic [7:0] dout_ref ;

    rand seq_mode_e seq_mode ; 
    cmd_e last_command ; 


    function new(string name = "ram_seq_item");
        super.new(name);
    endfunction


    constraint c_reset { rst_n dist {0 := 5 , 1 := 95}; }
    constraint c_rx_valid { rx_valid dist {0 := 5 , 1:= 95}; }

    constraint c_seq {
        if (seq_mode == WRITE_ONLY) 
        {
            if (last_command == WRITE_ADDR)
                command inside {WRITE_ADDR, WRITE_DATA};
            else
                command == WRITE_ADDR;
        }
        else if (seq_mode == READ_ONLY) 
        {
            if (last_command == READ_ADDR)
                command == READ_DATA ;
            else if (last_command == READ_DATA)
                command == READ_ADDR;
        }
        else if (seq_mode == READ_WRITE)
        {
            if (last_command == WRITE_ADDR)
                command inside {WRITE_ADDR, WRITE_DATA};
            else if (last_command == WRITE_DATA)
                command dist {READ_ADDR := 60 , WRITE_ADDR := 40};
            else if (last_command == READ_ADDR)
                command inside {READ_ADDR, READ_DATA};                   
            else if (last_command == READ_DATA)
                command dist {WRITE_ADDR := 60 , READ_ADDR := 40};
        }
    }
        

    function void post_randomize();
        last_command = command ;
    endfunction

    function string convert2string();
        return $sformatf("%s  rx_valid = 0b%0b , command = 0b%0b  , data = 0b%0b " ,
                        super.convert2string() ,  rx_valid, command, data ) ;
    endfunction

    function string convert2string_stimulus();
        return $sformatf(" rx_valid = 0b%0b , command = 0b%0b  , data = 0b%0b " ,
                            rx_valid, command, data ) ;
    endfunction

endclass

endpackage
