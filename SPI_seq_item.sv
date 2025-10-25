package spi_seq_item_pkg;

// Importing needed packages and macros
import uvm_pkg::*;
`include "uvm_macros.svh"

// Creating the class
class spi_seq_item extends uvm_sequence_item;
    `uvm_object_utils(spi_seq_item)

    // Constructor
    function new(string name = "spi_seq_item");
        super.new(name);
    endfunction

    // Randomizing stimulus inputs and outputs
    rand logic rst_n, SS_n, tx_valid;
    rand logic [7:0] tx_data;
    logic MOSI;
    // outputs
    logic MISO, rx_valid; 
    logic [9:0] rx_data;
    // reference outputs
    logic MISO_ref, rx_valid_ref; 
    logic [9:0] rx_data_ref;
    // for constraints 
    typedef enum bit [2:0] { WRITE_ADDR = 3'b000, WRITE_DATA = 3'b001, READ_ADDR = 3'b110, READ_DATA = 3'b111 } cmd_e;
    rand cmd_e cmd;
    rand bit MOSI_arr[10:0];
    bit MOSI_arr_drv[10:0];
    int read_counter = 0, normal_counter = 0, ss_counter = 0;
    bit read_data_falg = 0;
   
    // Constraints
    // Reset constraint
    constraint rst_c {
        rst_n dist {0 := 2, 1 := 98};
    }

    function void post_randomize();
    
        {MOSI_arr[0], MOSI_arr[1], MOSI_arr[2]} = cmd;

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
            read_counter = 0;
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

        tx_valid = (({MOSI_arr_drv[0], MOSI_arr_drv[1], MOSI_arr_drv[2]}) == READ_DATA);
    endfunction

    // Convert to string (full)
    function string convert2string();
        return $sformatf(
            "%s reset = %0b, SS_n = %0b, MOSI = %0b, MISO = %0b, rx_valid = %0b, tx_valid = %0b,rx_data = %0b, tx_data = %0b",
            super.convert2string(),
            rst_n, SS_n, MOSI, MISO, rx_valid, tx_valid, rx_data, tx_data
        );
    endfunction

    // Convert to string (stimulus only)
    function string convert2string_stimulus();
        return $sformatf(
            " reset = %0b, SS_n = %0b, MOSI = %0b, tx_valid = %0b, tx_data = %0b",
            rst_n, SS_n, MOSI, tx_valid, tx_data
        );
    endfunction

endclass

endpackage
