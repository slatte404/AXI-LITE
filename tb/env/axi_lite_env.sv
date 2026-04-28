class axi_lite_env extends uvm_env;
  `uvm_component_utils(axi_lite_env)

  axi_lite_agent     agent;
  axi_lite_scoreboard sb;
  axi_lite_cov       cov;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agent = axi_lite_agent::type_id::create("agent", this);
    sb  = axi_lite_scoreboard::type_id::create("sb", this);
    cov = axi_lite_cov::type_id::create("cov", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    agent.monitor.ap.connect(sb.item_collected_export);
    agent.monitor.ap.connect(cov.cov_collected_export);
  endfunction
endclass

