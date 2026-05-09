`include "uvm_macros.svh"
import uvm_pkg::*;

`ifndef AXI_DRIVER_SV
`define AXI_DRIVER_SV

class axi_lite_driver extends uvm_driver #(axi_trans_base);
  `uvm_component_utils(axi_lite_driver)

  // ==== 变量与接口定义 ====
  axi_trans_base tr;
  axi_write_trans w_tr;
  axi_read_trans  r_tr;

  virtual axi_lite_if vif; 
  event reset_ev; 

  // ==== 方法声明 (extern) ====
  extern function new(string name, uvm_component parent);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual task run_phase(uvm_phase phase);
  
  // 核心任务
  extern virtual task monitor_reset();
  extern virtual task process_transactions();
  
  // 辅助任务
  extern virtual task write_normal(input logic [31:0] addr, input logic [63:0] data, input logic [7:0] strobe);
  extern virtual task read_normal(input logic [31:0] addr, output logic [63:0] data);
  extern virtual task clean_up_signals();
  extern virtual task clean_up_read_signals();

endclass

// =========================================================================
// 方法实现区 (外部实现)
// =========================================================================

function axi_lite_driver::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction

function void axi_lite_driver::build_phase(uvm_phase phase);
  super.build_phase(phase);
  if (!uvm_config_db#(virtual axi_lite_if)::get(this, "", "vif", vif))
    `uvm_fatal(get_type_name(), "No virtual interface specified for axi_lite_driver")
endfunction

task axi_lite_driver::run_phase(uvm_phase phase);
  fork
    monitor_reset();         // 线程1: 后台持续监控复位
    process_transactions();  // 线程2: 处理事务
  join
endtask

task axi_lite_driver::monitor_reset();
  forever begin
    @(negedge vif.aresetn); // 捕捉复位下降沿
    -> reset_ev;            // 触发复位事件
    clean_up_signals();     // 立刻清理总线
    clean_up_read_signals();
  end
endtask

task axi_lite_driver::process_transactions();
  forever begin
    // 等待 reset 解除
    wait(vif.aresetn == 1);

    // 获取 transaction
    seq_item_port.get_next_item(tr);
    `uvm_info(get_type_name(), $sformatf("GET transaction type = %s",tr.get_type_name()), UVM_MEDIUM)

    // 【关键修复】如果在空闲等待发包时发生了复位，event 会被错过。
    // 这里我们刚拿到包，必须确认一下现在是不是处于复位状态。
    // 如果恰好在复位期间 sequencer 发了包，我们直接扔掉它，不去做驱动。
    if (vif.aresetn == 0) begin
      seq_item_port.item_done();
      continue;
    end

    // 开始读写和复位赛跑
    fork
      begin : drive_thread
        if ($cast(w_tr, tr)) begin
          write_normal(w_tr.addr, w_tr.data, w_tr.strobe);
          `uvm_info(get_type_name(), $sformatf("WRITE addr=0x%0h data=0x%0h", w_tr.addr, w_tr.data), UVM_MEDIUM)
        end
        else if ($cast(r_tr, tr)) begin
          read_normal(r_tr.addr, r_tr.data);
          `uvm_info(get_type_name(), $sformatf("READ addr=0x%0h data=0x%0h", r_tr.addr, r_tr.data), UVM_MEDIUM)
        end
      end
      begin : reset_thread
        @(reset_ev); // 坐等复位事件发生
      end
    join_any

    disable fork; // 无论是哪一边先结束，都杀掉另一边！

    // 每次事务结束后（不论是正常结束还是被打断），统一打扫战场
    clean_up_signals();
    clean_up_read_signals();

    seq_item_port.item_done();
  end
endtask

task axi_lite_driver::write_normal(input logic [31:0] addr, input logic [63:0] data, input logic [7:0] strobe);
  vif.awaddr  <= addr;
  vif.awvalid <= 1;
  vif.wdata   <= data;
  vif.wstrb   <= strobe;
  vif.wvalid  <= 1;
  vif.bready  <= 1;

  while(!vif.awready) @(posedge vif.aclk);
  while(!vif.wready)  @(posedge vif.aclk);

  @(posedge vif.aclk);
  vif.awvalid <= 0;
  vif.wvalid <= 0;

  while(!vif.bvalid)  @(posedge vif.aclk);

  @(posedge vif.aclk);
  // 注意：这里不用写 clean_up_signals()，因为外面的 process_transactions 统一做完了
endtask

task axi_lite_driver::read_normal(input logic [31:0] addr, output logic [63:0] data);
  vif.araddr  <= addr;
  vif.arvalid <= 1;
  vif.rready  <= 1;

  while(!vif.arready) @(posedge vif.aclk);

  @(posedge vif.aclk);
  vif.arvalid <= 0;

  while(!vif.rvalid)  @(posedge vif.aclk);

  data = vif.rdata;

  @(posedge vif.aclk);
  // 同样：外部会统一调用 clean_up_read_signals()
endtask

task axi_lite_driver::clean_up_signals();
  vif.awaddr  <= '0;
  vif.awvalid <= 0;
  vif.wdata   <= '0;
  vif.wstrb   <= '0;
  vif.wvalid  <= 0;
  vif.bready  <= 0;
endtask

task axi_lite_driver::clean_up_read_signals();
  vif.araddr  <= '0;
  vif.arvalid <= 0;
  vif.rready  <= 0;
endtask

`endif
