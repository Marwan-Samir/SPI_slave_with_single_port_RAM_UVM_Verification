package spi_env_pkg;

//importing needed pkgs
import uvm_pkg::*;
import spi_agent_pkg::*;
import spi_scoreboard_pkg::*;
import spi_coverage_pkg::*;
`include "uvm_macros.svh"
    class spi_env extends uvm_env;
        `uvm_component_utils(spi_env)
        
        //giving handels
        spi_agent agent;
        spi_scoreboard score;
        spi_coverage cov;

        //constructor
        function new(string name = "spi_env", uvm_component parent = null);
        super.new(name, parent);
        endfunction

        //build_phase
        function void build_phase (uvm_phase phase);
            super.build_phase(phase);
            agent =  spi_agent::type_id::create("agent", this);
            score =  spi_scoreboard::type_id::create("score", this);
            cov =  spi_coverage::type_id::create("cov", this); 
        endfunction 

         //conecct phase 
        function void connect_phase (uvm_phase phase);
            super.connect_phase(phase) ;
            agent.agent_aport.connect(score.sb_exp);
            agent.agent_aport.connect(cov.cov_exp);
        endfunction

    endclass

   
    

endpackage