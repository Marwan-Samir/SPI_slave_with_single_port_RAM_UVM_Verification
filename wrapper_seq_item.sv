package wrapper_seq_item_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

    typedef enum bit [1:0] { WRITE_ONLY , READ_ONLY , READ_WRITE} seq_mode_e;
    typedef enum bit [2:0] { WRITE_ADDR = 3'b000, WRITE_DATA = 3'b001, READ_ADDR = 3'b110, READ_DATA = 3'b111 } cmd_e;

    class wrapper_seq_item extends uvm_sequence_item;
    `uvm_object_utils(wrapper_seq_item)
        
        rand  logic SS_n;  
        rand  logic rst_n;
        rand  cmd_e command;
        rand  seq_mode_e seq_mode;
        rand  bit MOSI_arr[10:0];
        bit   MOSI_arr_drv[10:0];
        logic MOSI;
        logic MISO;
        cmd_e last_command;
        logic MISO_ref;
    
        int read_counter    = 0;
        int normal_counter  = 0;
        int ss_counter      = 0;
        bit read_data_falg  = 0;

        function new(string name = "wrapper_seq_item");
            super.new(name);
        endfunction


        constraint c_reset { rst_n dist {0 := 2 , 1 := 98}; }

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
            last_command = command;
            {MOSI_arr[0], MOSI_arr[1], MOSI_arr[2]} = command;

            if (ss_counter == 0)
                SS_n = 1;
            else 
                SS_n = 0;

            if ((normal_counter == 0) && (read_counter == 0) && (ss_counter == 0)) begin
                MOSI_arr_drv = MOSI_arr;
            end

            read_data_falg = (({MOSI_arr_drv[0], MOSI_arr_drv[1], MOSI_arr_drv[2]}) == READ_DATA);

            if (read_data_falg) begin
                if (ss_counter < 23)
                    ss_counter++;
                else
                    ss_counter = 0;
            end 
            else begin
                if (ss_counter < 13)
                    ss_counter++;
                else
                    ss_counter = 0;
            end

            if (read_counter < 25 && !SS_n && read_data_falg && ss_counter > 2) begin
                if (read_counter < 11)
                    MOSI = MOSI_arr_drv[read_counter++];
                else
                    read_counter++;
            end 
            else begin
                read_counter   = 0;
                read_data_falg = 0;
            end

            if (normal_counter < 15 && !SS_n && !read_data_falg && ss_counter > 2) begin
                if (normal_counter < 11)
                    MOSI = MOSI_arr_drv[normal_counter++];
                else
                    normal_counter++;
            end 
            else
                normal_counter = 0;

        endfunction


        function string convert2string();
            return $sformatf(
                "%s reset = %0b, SS_n = %0b, MOSI = %0b, MISO = %0b, command = 0b%0b , MISO_ref = %0b",
                super.convert2string(),
                rst_n, SS_n, MOSI, MISO, command, MISO_ref
            );
        endfunction


        function string convert2string_stimulus();
            return $sformatf(
                " reset = %0b, SS_n = %0b, MOSI = %0b, command = %0b,  MISO_ref = %0b",
                rst_n, SS_n, MOSI, command, MISO_ref
            );
        endfunction
    endclass
endpackage
