package spi_coverage_pkg;
    // importing needed pkgs and macros
    import uvm_pkg::*;
    import spi_seq_item_pkg::*;
    `include "uvm_macros.svh"

    // creating the class
    class spi_coverage extends uvm_component;
        `uvm_component_utils(spi_coverage)

        // analysis port of agent
        uvm_analysis_port #(spi_seq_item) cov_exp;
        uvm_tlm_analysis_fifo #(spi_seq_item) cov_fifo;

        // giving handles
        spi_seq_item cov_seq_item;

        // adding cover groups
        covergroup cvr_gp;

            // ---- rx_data coverpoints ----
            rx_data_cp: coverpoint cov_seq_item.rx_data[9:8]{
                bins all_vals[] = {2'b00,2'b01,2'b10,2'b11};
                bins wradd_2_wrdata = (2'b00 => 2'b01);
                bins rdaddr_2_rddata = (2'b10 => 2'b11);
                bins rddata_2_wradd = (2'b11 => 2'b00);
            }

            // ---- ss_n coverpoints ----
            ss_n_cp: coverpoint cov_seq_item.SS_n{
                bins normal_trans  = (1 => 0 [*13] => 1);
                bins readdata_trans = (1 => 0 [*23] => 1);
            }
            SS_N_cp:coverpoint cov_seq_item.SS_n{
                bins normal  = (1 => 0 [*4]);
            }

            MOSI_cp : coverpoint cov_seq_item.MOSI {
                bins write_addr  = (0 => 0 => 0);   
                bins write_data  = (0 => 0 => 1);
                bins read_addr   = (1 => 1 => 0);
                bins read_data   = (1 => 1 => 1);
                bins others = default;
            }

            // ---- Crosses ----
            SS_MOSI_c : cross SS_N_cp, MOSI_cp;

    
        endgroup : cvr_gp;

        // constructor
        function new(string name = "spi_coverage", uvm_component parent = null);
            super.new(name, parent);
            cvr_gp = new();
        endfunction

        //build phase
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            cov_exp = new("cov_exp", this);
            cov_fifo =  new("cov_fifo", this);
        endfunction

        // connect phase
        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            cov_exp.connect(cov_fifo.analysis_export);
        endfunction

        //run phase
        task run_phase (uvm_phase phase);
            super.run_phase(phase); 
            forever begin
                cov_fifo.get(cov_seq_item);
                cvr_gp.sample();
            end   
        endtask

    endclass
endpackage