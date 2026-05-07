`ifndef AXI_LITE_MONITOR_SV
`define AXI_LITE_MONITOR_SV

class axi_lite_monitor extends uvm_component;
  `uvm_component_utils(axi_lite_monitor)

  // 接口与端口定义
  virtual axi_lite_if vif;
  uvm_analysis_port #(axi_trans_base) ap;

  // 方法声明 (extern)
  extern function new(string name, uvm_component parent);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual task run_phase(uvm_phase phase);
  
  // 独立的并发监控任务
  extern virtual task collect_write_transactions();
  extern virtual task collect_read_transactions();

endclass

// =========================================================================
// 方法实现区 (外部实现)
// =========================================================================

function axi_lite_monitor::new(string name, uvm_component parent);
  super.new(name, parent);
  ap = new("ap", this);
endfunction

function void axi_lite_monitor::build_phase(uvm_phase phase);
  super.build_phase(phase);

  // 获取 vif
  if (!uvm_config_db#(virtual axi_lite_if)::get(this, "", "vif", vif))
    `uvm_fatal(get_type_name(), "No virtual interface specified for axi_lite_monitor")

  // 同时把 vif 传给 scoreboard
  uvm_config_db#(virtual axi_lite_if)::set(this, "*scoreboard*", "vif", vif);
endfunction

task axi_lite_monitor::run_phase(uvm_phase phase);
  // 并行启动读写通道的监控
  fork
    collect_write_transactions();
    collect_read_transactions();
  join
endtask

// ==== 修复后的写通道监控 (解决时序错位问题) ====
task axi_lite_monitor::collect_write_transactions();
  axi_write_trans w_tr;
  bit [31:0] temp_addr;
  bit [63:0] temp_data;
  bit [7:0]  temp_strb;

  forever begin
    wait(vif.aresetn === 1);
    
    // 独立捕获 AW 和 W 通道
    fork
      begin : aw_channel
        do @(posedge vif.aclk); 
        while (!(vif.awvalid && vif.awready));
        temp_addr = vif.awaddr;
      end
      begin : w_channel
        do @(posedge vif.aclk);
        while (!(vif.wvalid && vif.wready));
        temp_data = vif.wdata;
        temp_strb = vif.wstrb;
      end
    join
    
    // 当 AW 和 W 都握手完成后，组装 transaction
    w_tr = axi_write_trans::type_id::create("w_tr");
    w_tr.addr   = temp_addr;
    w_tr.data   = temp_data;
    w_tr.strobe = temp_strb;

    // 等待写响应 (B 通道) 握手
    do @(posedge vif.aclk);
    while (!(vif.bvalid && vif.bready));

    // 发送给 Scoreboard 和 Coverage
    ap.write(w_tr);
    `uvm_info(get_type_name(), 
              $sformatf("Monitor captured WRITE: addr=0x%0h data=0x%0h strobe=0x%0h", w_tr.addr, w_tr.data, w_tr.strobe), 
              UVM_LOW)
  end
endtask

// ==== 修复后的读通道监控 ====
task axi_lite_monitor::collect_read_transactions();
  axi_read_trans r_tr;
  
  forever begin
    wait(vif.aresetn === 1);
    
    r_tr = axi_read_trans::type_id::create("r_tr");

    // 等待读地址握手 (AR)
    do @(posedge vif.aclk);
    while (!(vif.arvalid && vif.arready));
    r_tr.addr = vif.araddr;

    // 等待读数据握手 (R)
    do @(posedge vif.aclk);
    while (!(vif.rvalid && vif.rready));
    r_tr.data = vif.rdata;

    // 发送
    ap.write(r_tr);
    `uvm_info(get_type_name(), 
              $sformatf("Monitor captured READ: addr=0x%0h data=0x%0h", r_tr.addr, r_tr.data), 
              UVM_LOW)
  end
endtask

`endif
