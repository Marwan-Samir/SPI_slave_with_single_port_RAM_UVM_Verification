package spi_test_pkg;

//importing needed pkgs
import uvm_pkg::*;
import spi_env_pkg::*;
import spi_config_pkg::*;
import spi_reset_seq_pkg::*;
import spi_main_seq_pkg::*;
`include "uvm_macros.svh"

    class spi_test extends uvm_test;
        `uvm_component_utils(spi_test)

        //giving handels
        spi_env env;
        spi_config conf;
        virtual SPI_if spi_test_vif;
        virtual SPI_GM_IF SPI_GM_vif;
        spi_reset_seq res_seq;
        spi_main_seq main_seq;
        
        // constructor
        function new(string name = "spi_test", uvm_component parent = null);
        super.new(name, parent);
        endfunction

        //build_phase
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            env = spi_env::type_id::create("env", this);
            conf = spi_config::type_id::create("conf", this);
            res_seq = spi_reset_seq::type_id::create("res_seq", this);
            main_seq = spi_main_seq::type_id::create("main_seq", this);
            if (!uvm_config_db #(virtual SPI_IF)::get(this , "" , "spi" , conf.SPI_vif)) begin
                `uvm_fatal("build_phase", "error in getting the data");
            end 
            if (!uvm_config_db #(virtual SPI_GM_IF)::get(this , "" , "spi_ref" , conf.SPI_GM_vif)) begin
                `uvm_fatal("build_phase", "error in getting the data");
            end 
            uvm_config_db #(spi_config)::set(this , "*" , "CFG" , conf); 
        endfunction: build_phase

        //run_phase
        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            phase.raise_objection(this);
            // reset seq
            `uvm_info("run_phase", "reset asserted", UVM_LOW);
            res_seq.start(env.agent.sqcr);
            `uvm_info("run_phase", "reset deasserted", UVM_LOW);

            // main seq
            `uvm_info("run_phase", "main asserted", UVM_LOW);
            main_seq.start(env.agent.sqcr);
            `uvm_info("run_phase", "main deasserted", UVM_LOW);
            phase.drop_objection(this);
        endtask: run_phase
    endclass: spi_test
    
endpackage
