package spi_scoreboard_pkg;
    // importing needed pkgs and macros
    import uvm_pkg::*;
    import spi_seq_item_pkg::*;
    `include "uvm_macros.svh"

    // creating the class
    class spi_scoreboard extends uvm_scoreboard;
        `uvm_component_utils(spi_scoreboard)

        // analysis port of scoreboard
        uvm_analysis_export #(spi_seq_item) sb_exp;
        uvm_tlm_analysis_fifo #(spi_seq_item) sb_fifo;
        int correct_count = 0, error_count = 0;
        
        // giving handles
        spi_seq_item seq_item_sb;

        // constructor
        function new(string name = "spi_scoreboard", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        //build phase
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            sb_exp = new("sb_exp", this);
            sb_fifo = new("sb_fifo", this);

        endfunction

        // connect phase
        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            sb_exp.connect(sb_fifo.analysis_export);
        endfunction

        //run phase
        task run_phase (uvm_phase phase);
            super.run_phase(phase);
            forever begin
                sb_fifo.get(seq_item_sb); 
                    if (seq_item_sb.MISO != seq_item_sb.MISO_ref || seq_item_sb.rx_valid != seq_item_sb.rx_valid_ref || seq_item_sb.rx_data != seq_item_sb.rx_data_ref ) begin
                        if (seq_item_sb.MISO != seq_item_sb.MISO_ref) begin
                            `uvm_error("run_phase", $sformatf("MISO mismatch: miso = %0b, miso_ref = %0b", seq_item_sb.MISO, seq_item_sb.MISO_ref ));
                        end
                        if (seq_item_sb.rx_valid != seq_item_sb.rx_valid_ref) begin
                            `uvm_error("run_phase", $sformatf("RX_VALID mismatch: rx_valid = %0b, rx_valid_ref = %0b", seq_item_sb.rx_valid, seq_item_sb.rx_valid_ref ));
                        end
                        if (seq_item_sb.rx_data != seq_item_sb.rx_data_ref) begin
                            `uvm_error("run_phase", $sformatf("RX_DATA mismatch: rx_data = %0b, rx_data_ref = %0b", seq_item_sb.rx_data, seq_item_sb.rx_data_ref ));
                        end 
                        error_count++;
                    end else begin
                        `uvm_info("run_phase", $sformatf("comparison completed"),UVM_HIGH);
                        correct_count++;
                    end 
            end  
        endtask

        //report phase
        function void report_phase (uvm_phase phase);
            super.report_phase(phase) ;
            `uvm_info("report_phase", $sformatf("total correct tranxactions: %0d", correct_count),UVM_MEDIUM);
            `uvm_info("report_phase", $sformatf("total failed tranxactions: %0d", error_count),UVM_MEDIUM);
        endfunction

    endclass
endpackage