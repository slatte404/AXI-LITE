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
  bit in_reset; 

  // ==== 方法声明 (extern) ====
  extern function new(string name, uvm_component parent);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual task run_phase(uvm_phase phase);
  
  // 核心任务
  extern virtual task monitor_reset();
  extern virtual task process_transactions();
  
  // 辅助任务
  extern virtual task wait_until_reset_deasserted();
  extern virtual task write_with_reset(input logic [31:0] addr, input logic [63:0] data, input logic [7:0] strobe);
  extern virtual task read_with_reset(input logic [31:0] addr, output logic [63:0] data);
  extern virtual task wait_with_reset(ref logic signal);
  extern virtual task clean_up_signals();
  extern virtual task clean_up_read_signals();

endclass

// =========================================================================
// 方法实现区 (外部实现)
// =========================================================================

function axi_lite_driver::new(string name, uvm_component parent);
  super.new(name, parent);
  in_reset = 0;
endfunction

function void axi_lite_driver::build_phase(uvm_phase phase);
  super.build_phase(phase);
  if (!uvm_config_db#(virtual axi_lite_if)::get(this, "", "vif", vif))
    `uvm_fatal(get_type_name(), "No virtual interface specified for axi_lite_driver")
endfunction

task axi_lite_driver::run_phase(uvm_phase phase);
  fork
    monitor_reset();         // 线程1: 监控复位
    process_transactions();  // 线程2: 处理事务
  join
endtask

task axi_lite_driver::monitor_reset();
  forever begin
    @(posedge vif.aclk); // 每个时钟周期检查
    in_reset = !vif.aresetn;
    if (in_reset) begin
      clean_up_signals();
      clean_up_read_signals();
    end
  end
endtask

task axi_lite_driver::process_transactions();
  forever begin
    // 等待 reset 解除
    wait_until_reset_deasserted();

    // 获取 transaction
    seq_item_port.get_next_item(tr);
    `uvm_info(get_type_name(), $sformatf("GET transaction type = %s",tr.get_type_name()), UVM_MEDIUM)

    // 根据 transaction 类型执行
    if ($cast(w_tr, tr)) begin
      write_with_reset(w_tr.addr, w_tr.data, w_tr.strobe);
      `uvm_info(get_type_name(), $sformatf("WRITE addr=0x%0h data=0x%0h", w_tr.addr, w_tr.data), UVM_MEDIUM)
    end
    else if ($cast(r_tr, tr)) begin
      read_with_reset(r_tr.addr, r_tr.data);
      `uvm_info(get_type_name(), $sformatf("READ addr=0x%0h data=0x%0h", r_tr.addr, r_tr.data), UVM_MEDIUM)
    end

    seq_item_port.item_done();
  end
endtask

task axi_lite_driver::wait_until_reset_deasserted();
  while (in_reset) @(posedge vif.aclk);
  @(posedge vif.aclk); // 保证稳定
endtask

task axi_lite_driver::write_with_reset(input logic [31:0] addr, input logic [63:0] data, input logic [7:0] strobe);
  // reset 有效时直接不做操作
  if (in_reset) disable write_with_reset;

  vif.awaddr  <= addr;
  vif.awvalid <= 1;
  vif.wdata   <= data;
  vif.wstrb   <= strobe;
  vif.wvalid  <= 1;
  vif.bready  <= 1;

  wait_with_reset(vif.awready);
  if (in_reset) begin clean_up_signals(); return; end // 如果中断，立刻返回退出任务

  wait_with_reset(vif.wready);
  if (in_reset) begin clean_up_signals(); return; end

  @(posedge vif.aclk);
  vif.awvalid <= 0;
  vif.wvalid <= 0;

  wait_with_reset(vif.bvalid);
  if (in_reset) begin clean_up_signals(); return; end

  @(posedge vif.aclk);
  clean_up_signals();
endtask

task axi_lite_driver::read_with_reset(input logic [31:0] addr, output logic [63:0] data);
  if (in_reset) begin
    data = '0;
    disable read_with_reset;
  end

  vif.araddr  <= addr;
  vif.arvalid <= 1;
  vif.rready  <= 1;

  wait_with_reset(vif.arready);
  if (in_reset) begin clean_up_read_signals(); return; end

  @(posedge vif.aclk);
  vif.arvalid <= 0;

  wait_with_reset(vif.rvalid);
  if (in_reset) begin clean_up_read_signals(); return; end

  data = vif.rdata;

  @(posedge vif.aclk);
  clean_up_read_signals();
endtask

task axi_lite_driver::wait_with_reset(ref logic signal);
  while (!signal && !in_reset) @(posedge vif.aclk);
  // 结束时要么 signal=1，要么被 reset 强行打断
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
