package ram_coverage_pkg;

import ram_seq_item_pkg::*;
import uvm_pkg::*;
`include "uvm_macros.svh"

class ram_coverage extends uvm_component;
    `uvm_component_utils(ram_coverage)
    uvm_analysis_export #(ram_seq_item) cov_export;
    uvm_tlm_analysis_fifo #(ram_seq_item) cov_fifo;
    ram_seq_item seq_item_cov;

    // covergroup declaration
    covergroup cvr_gp;

        command_cp: coverpoint seq_item_cov.command {
            bins write_address = {WRITE_ADDR};
            bins write_data = {WRITE_DATA};
            bins read_address = {READ_ADDR};
            bins read_data = {READ_DATA};
            bins write_data_after_address = ( WRITE_ADDR => WRITE_DATA );
            bins read_data_after_address = ( READ_ADDR => READ_DATA );
            bins transition = (WRITE_ADDR => WRITE_DATA => READ_ADDR => READ_DATA );
        }

        rx_valid_cp: coverpoint seq_item_cov.rx_valid ;

        tx_valid_cp: coverpoint seq_item_cov.tx_valid ;


        rx_valid_with_commands : cross command_cp , rx_valid_cp {
            ignore_bins rx_valid_zero = binsof (rx_valid_cp) intersect {0} ;
        }

        tx_valid_with_read_data : cross command_cp, tx_valid_cp {
            option.cross_auto_bin_max = 0 ;
            bins tx_valid_rd = binsof(command_cp.read_data) && binsof(tx_valid_cp) intersect {1};
        }
 
    endgroup

    function new(string name = "ram_coverage", uvm_component parent = null) ;
        super.new(name, parent);
        cvr_gp = new();
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        cov_export = new("cov_export", this);
        cov_fifo = new("cov_fifo", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        cov_export.connect(cov_fifo.analysis_export);
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        forever begin
            cov_fifo.get(seq_item_cov);
            cvr_gp.sample();
        end
    endtask

endclass

endpackage