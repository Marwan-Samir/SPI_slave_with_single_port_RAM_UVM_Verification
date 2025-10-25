package wrapper_agent_pkg;

import wrapper_seq_item_pkg::*;
import wrapper_sequencer_pkg::*;
import wrapper_driver_pkg::*;
import wrapper_monitor_pkg::*;
import wrapper_config_pkg::*;
import uvm_pkg::*;
`include "uvm_macros.svh"
    
    class wrapper_agent extends uvm_agent;
    `uvm_component_utils(wrapper_agent)
    
        wrapper_sequencer sqr;
        wrapper_driver    drv;
        wrapper_monitor   mon;
        wrapper_config    cfg;

        uvm_analysis_port #(wrapper_seq_item) agt_ap;

        function new(string name = "wrapper_agent", uvm_component parent = null);
            super.new(name, parent);
        endfunction 

        function void build_phase (uvm_phase phase);
            super.build_phase(phase);
            if (!uvm_config_db #(wrapper_config)::get(this , "" , "CFG" , cfg )) begin
                `uvm_fatal("build_phase", "Unable to get configuration object");
            end 
            if (cfg.is_active == UVM_ACTIVE) begin
                sqr = wrapper_sequencer::type_id::create("sqr", this);
                drv = wrapper_driver::type_id::create("drv", this);
            end
            mon    =  wrapper_monitor::type_id::create("mon",this);
            agt_ap = new("agt_ap",this);
        endfunction

        function void connect_phase (uvm_phase phase);
            super.connect_phase(phase);
            if (cfg.is_active == UVM_ACTIVE) begin
                drv.wrapper_driver_vif     = cfg.wrapper_config_vif;
                drv.wrapper_ref_driver_vif = cfg.wrapper_ref_config_vif;
                drv.seq_item_port.connect(sqr.seq_item_export);
            end
            mon.wrapper_monitor_vif     = cfg.wrapper_config_vif;
            mon.wrapper_ref_monitor_vif = cfg.wrapper_ref_config_vif;
            mon.mon_ap.connect(agt_ap);
        endfunction
    endclass
endpackage
