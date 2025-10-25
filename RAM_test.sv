package ram_test_pkg;

import ram_config_pkg::*;
import ram_env_pkg::*;
import ram_reset_seq_pkg::*;
import ram_write_seq_pkg::*;
import ram_read_seq_pkg::*;
import ram_read_write_seq_pkg::*;
import uvm_pkg::*;
`include "uvm_macros.svh"

class ram_test extends uvm_test;

    `uvm_component_utils(ram_test)
    ram_env env;
    ram_config ram_cfg;
    virtual ram_if ram_test_vif;
    virtual ram_GM_if ram_GM_test_vif;

    ram_reset_seq rst_seq ;
    ram_write_only_seq write_seq ;
    ram_read_only_seq read_seq ;
    ram_read_write_seq read_write_seq ;   

    function new(string name = "ram_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction 

    function void build_phase (uvm_phase phase);
        super.build_phase(phase) ;
        
        env = ram_env::type_id::create("env",this);
        ram_cfg = ram_config::type_id::create("ram_cfg");

        rst_seq = ram_reset_seq::type_id:: create("rst_seq");
        write_seq = ram_write_only_seq::type_id::create("write_seq");
        read_seq = ram_read_only_seq::type_id:: create("read_seq");
        read_write_seq = ram_read_write_seq::type_id::create("read_write_seq");


        if (!uvm_config_db #(virtual ram_if)::get(this , "" , "RAM_IF" , ram_cfg.ram_config_vif )) begin
            `uvm_fatal("build_phase", "Virtual interface not found ");
        end

        //FOR GOLDEN MODEL
        if (!uvm_config_db #(virtual ram_GM_if)::get(this , "" , "RAM_GM_IF" , ram_cfg.ram_GM_config_vif )) begin
            `uvm_fatal("build_phase", "Virtual interface not found ");
        end 

        uvm_config_db#(ram_config)::set(this, "*", "CFG_RAM", ram_cfg);

    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        phase.raise_objection(this);
        //reset sequence
        `uvm_info("run_phase", "Reset Asserted", UVM_LOW)
        rst_seq.start(env.agt.sqr);
        `uvm_info("run_phase", "Reset Deasserted", UVM_LOW)

        //main sequence
        `uvm_info("run_phase", "Stimulus Generation Started", UVM_LOW)
        write_seq.start(env.agt.sqr);
        read_seq.start(env.agt.sqr);
        read_write_seq.start(env.agt.sqr);
        `uvm_info("run_phase", "Stimulus Generation Ended", UVM_LOW)
        phase.drop_objection(this);
    endtask

endclass: ram_test

endpackage

