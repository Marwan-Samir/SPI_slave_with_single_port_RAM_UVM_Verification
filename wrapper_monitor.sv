package wrapper_monitor_pkg;

import wrapper_seq_item_pkg::*;
import uvm_pkg::*;
`include "uvm_macros.svh"
    
    class wrapper_monitor extends uvm_monitor;
    `uvm_component_utils(wrapper_monitor)

        virtual wrapper_if      wrapper_monitor_vif;
        virtual wrapper_ref_if  wrapper_ref_monitor_vif;
        wrapper_seq_item        seq_item;
    
        uvm_analysis_port #(wrapper_seq_item) mon_ap;

        function new(string name = "wrapper_monitor", uvm_component parent = null);
            super.new(name, parent);
        endfunction 

        function void build_phase (uvm_phase phase);
            super.build_phase(phase);
            mon_ap = new("mon_ap",this);
        endfunction

        task run_phase (uvm_phase phase);
            super.run_phase(phase);
            forever begin
                seq_item = wrapper_seq_item::type_id::create("seq_item");

                @(negedge wrapper_monitor_vif.clk); 
                seq_item.rst_n        = wrapper_monitor_vif.rst_n; 
                seq_item.SS_n         = wrapper_monitor_vif.SS_n;
                seq_item.MOSI         = wrapper_monitor_vif.MOSI;
                seq_item.MISO         = wrapper_monitor_vif.MISO;

                if (wrapper_ref_monitor_vif  != null) begin  
                    seq_item.MISO_ref         = wrapper_ref_monitor_vif.MISO_ref;
                end

                mon_ap.write(seq_item);
                `uvm_info("run_phase", seq_item.convert2string() , UVM_HIGH)
            end
        endtask
    endclass    
endpackage
