package wrapper_test_pkg;


  import wrapper_config_pkg::*;
  import wrapper_env_pkg::*;
  import wrapper_reset_seq_pkg::*;
  import wrapper_write_seq_pkg::*;
  import wrapper_read_seq_pkg::*;
  import wrapper_read_write_seq_pkg::*;
  import spi_config_pkg::*;
  import ram_config_pkg::*;
  import spi_env_pkg::*;
  import ram_env_pkg::*;
  import uvm_pkg::*;
  `include "uvm_macros.svh"


  class wrapper_test extends uvm_test;
    `uvm_component_utils(wrapper_test)

    wrapper_env            env;
    wrapper_config         wrapper_cfg;
    virtual wrapper_if     wrapper_test_vif;
    virtual wrapper_ref_if wrapper_ref_test_vif;
    wrapper_reset_seq      rst_seq ;
    wrapper_write_only_seq write_seq ;
    wrapper_read_only_seq  read_seq ;
    wrapper_read_write_seq read_write_seq ;

    ram_config             ram_conf;
    spi_config             spi_conf;
    spi_env                s_env;
    ram_env                r_env;


    function new(string name = "wrapper_test", uvm_component parent = null);
      super.new(name, parent);
    endfunction


    function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      env                = wrapper_env::type_id::create("env",this);
      r_env              = ram_env::type_id::create("r_env",this);
      s_env              = spi_env::type_id::create("s_env",this);
      wrapper_cfg        = wrapper_config::type_id::create("wrapper_cfg");

      rst_seq            = wrapper_reset_seq::type_id:: create("rst_seq");
      write_seq          = wrapper_write_only_seq::type_id::create("write_seq");
      read_seq           = wrapper_read_only_seq::type_id:: create("read_seq");
      read_write_seq     = wrapper_read_write_seq::type_id::create("read_write_seq");

      ram_conf           = ram_config::type_id::create("ram_conf");
      spi_conf           = spi_config::type_id::create("spi_conf");

      spi_conf.is_active    = UVM_PASSIVE;    
      ram_conf.is_active    = UVM_PASSIVE;
      wrapper_cfg.is_active = UVM_ACTIVE;


      if (!uvm_config_db #(virtual wrapper_if)::get(this , "" , "wifv" , wrapper_cfg.wrapper_config_vif )) begin
       `uvm_fatal("build_phase", "Virtual interface not found ");
      end

      if (!uvm_config_db #(virtual wrapper_ref_if)::get(this , "" , "wrifv" , wrapper_cfg.wrapper_ref_config_vif )) begin
       `uvm_fatal("build_phase", "Virtual interface not found ");
      end

      uvm_config_db #(wrapper_config)::set(this, "*", "CFG", wrapper_cfg); 

      if (!uvm_config_db #(virtual ram_if)::get(this , "" , "RAM_IF" , ram_conf.ram_config_vif )) begin
        `uvm_fatal("build_phase", "Virtual interface not found ");
      end

      
      if (!uvm_config_db #(virtual ram_GM_if)::get(this , "" , "RAM_GM_IF" , ram_conf.ram_GM_config_vif )) begin
       `uvm_fatal("build_phase", "Virtual interface not found ");
      end 

      uvm_config_db#(ram_config)::set(this, "*", "CFG_RAM", ram_conf);

      if (!uvm_config_db #(virtual SPI_IF)::get(this , "" , "spi" , spi_conf.SPI_vif)) begin
        `uvm_fatal("build_phase", "error in getting the data");
      end 
      if (!uvm_config_db #(virtual SPI_GM_IF)::get(this , "" , "spi_ref" , spi_conf.SPI_GM_vif)) begin
       `uvm_fatal("build_phase", "error in getting the data");
      end 
      uvm_config_db #(spi_config)::set(this , "*" , "CFG_SPI" , spi_conf); 
    endfunction


    task run_phase(uvm_phase phase);
      super.run_phase(phase);
      phase.raise_objection(this);

      `uvm_info("wrapper_test", "Starting all sequences in parallel", UVM_LOW)

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
      `uvm_info("wrapper_test", "All sequences completed successfully", UVM_LOW)
      
      phase.drop_objection(this);
    endtask
  endclass
endpackage
