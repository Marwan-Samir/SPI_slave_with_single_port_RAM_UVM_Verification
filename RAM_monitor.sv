package ram_monitor_pkg;

import ram_seq_item_pkg::*;
import uvm_pkg::*;
`include "uvm_macros.svh"
    
class ram_monitor extends uvm_monitor;
    `uvm_component_utils(ram_monitor)

    virtual ram_if ram_monitor_vif;
    virtual ram_GM_if ram_GM_monitor_vif;
    ram_seq_item rsp_seq_item ;
    
    uvm_analysis_port #(ram_seq_item) mon_ap ;

    function new(string name = "ram_monitor", uvm_component parent = null);
        super.new(name, parent);
    endfunction 

    function void build_phase (uvm_phase phase);
        super.build_phase(phase) ;
        mon_ap = new("mon_ap",this) ;
    endfunction

    task run_phase (uvm_phase phase);
        super.run_phase(phase) ;
        forever begin
            rsp_seq_item = ram_seq_item::type_id::create("rsp_seq_item");

            @(negedge ram_monitor_vif.clk ) ; 
            rsp_seq_item.rst_n = ram_monitor_vif.rst_n ;
            rsp_seq_item.rx_valid = ram_monitor_vif.rx_valid ; 
            rsp_seq_item.command = cmd_e'(ram_monitor_vif.din[9:8]) ;
            rsp_seq_item.data = ram_monitor_vif.din[7:0] ; 
            rsp_seq_item.tx_valid = ram_monitor_vif.tx_valid ; 
            rsp_seq_item.dout = ram_monitor_vif.dout ; 

            if (ram_GM_monitor_vif != null) begin
                rsp_seq_item.tx_valid_ref = ram_GM_monitor_vif.tx_valid ; 
                rsp_seq_item.dout_ref = ram_GM_monitor_vif.dout ;  
            end

            mon_ap.write(rsp_seq_item) ;
            `uvm_info("run_phase", rsp_seq_item.convert2string() , UVM_HIGH)
        end
    endtask

endclass
    
endpackage
