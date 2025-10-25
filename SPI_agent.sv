package spi_agent_pkg;
    // importing needed pkgs and macros
    import uvm_pkg::*;
    import spi_config_pkg::*;
    import spi_driver_pkg::*;
    import spi_sequencer_pkg::*;
    import spi_seq_item_pkg::*;
    import spi_monitor_pkg::*;
    `include "uvm_macros.svh"

    // creating the class
    class spi_agent extends uvm_agent;
        `uvm_component_utils(spi_agent)
        // analysis port of agent
        uvm_analysis_port #(spi_seq_item) agent_aport;
        
        // giving handles
        spi_driver drv;
        spi_sequencer sqcr;
        spi_monitor mon;
        spi_config conf;

        // constructor
        function new(string name = "spi_agent", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        //build phase
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if (!uvm_config_db #(spi_config)::get(this , "" , "CFG" , conf)) begin
                `uvm_fatal("build_phase", "error in getting the data");
            end
            drv = spi_driver::type_id::create("drv", this);
            sqcr = spi_sequencer::type_id::create("sqcr", this);
            mon = spi_monitor::type_id::create("mon", this);
            agent_aport = new("agent_aport", this);
        endfunction

        // connect phase
        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            if (conf.is_active == UVM_ACTIVE) begin
                drv.SPI_vif = conf.SPI_vif;
                drv.SPI_GM_vif = conf.SPI_GM_vif;
                drv.seq_item_port.connect(sqcr.seq_item_export);
            end
            
            mon.SPI_vif = conf.SPI_vif;
            mon.SPI_GM_vif = conf.SPI_GM_vif; 
            mon.mon_aport.connect(agent_aport);
            
        endfunction

    endclass
endpackage