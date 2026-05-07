`ifndef AXI_LITE_SCOREBOARD_SV
`define AXI_LITE_SCOREBOARD_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

class axi_lite_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(axi_lite_scoreboard)

  // analysis_export 接收 monitor 的 transaction
  uvm_analysis_imp#(axi_trans_base, axi_lite_scoreboard) item_collected_export;
  
  // reference memory model
  bit [63:0] ref_mem [6];
  virtual axi_lite_if vif;

  // ==== 方法声明 (extern) ====
  extern function new(string name, uvm_component parent);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void write(axi_trans_base tr);

endclass

// =========================================================================
// 方法实现区 (外部实现)
// =========================================================================

function axi_lite_scoreboard::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction

function void axi_lite_scoreboard::build_phase(uvm_phase phase);
  super.build_phase(phase);
  item_collected_export = new("item_collected_export", this);

  if (!uvm_config_db#(virtual axi_lite_if)::get(this, "", "vif", vif))
    `uvm_warning(get_type_name(), "No virtual interface specified for scoreboard, reset check disabled")
endfunction

function void axi_lite_scoreboard::write(axi_trans_base tr);
  axi_write_trans w_tr;
  axi_read_trans  r_tr;

  // 如果 reset 有效，初始化 reference memory 并忽略事务
  if (vif !== null && !vif.aresetn) begin
    for (int i = 0; i < 6; i++) ref_mem[i] = '0;
    return;
  end

  // ==== 写事务处理 ====
  if ($cast(w_tr, tr)) begin
    int reg_idx = w_tr.addr >> 3; // 64bit 对齐
    if (reg_idx < 6) begin
      bit [63:0] mask;
      for (int i = 0; i < 8; i++) begin
        mask[i*8 +: 8] = w_tr.strobe[i] ? 8'hFF : 8'h00;
      end
      ref_mem[reg_idx] = (ref_mem[reg_idx] & ~mask) | (w_tr.data & mask);

      `uvm_info("SCOREBOARD", $sformatf("WRITE: addr=0x%0h reg=%0d data=0x%0h strobe=0x%0h", w_tr.addr, reg_idx, w_tr.data, w_tr.strobe), UVM_MEDIUM)
    end
  end
  // ==== 读事务处理 ====
  else if ($cast(r_tr, tr)) begin
    int reg_idx = r_tr.addr >> 3;
    if (reg_idx < 6) begin
      bit [63:0] exp_data = ref_mem[reg_idx];
      if (r_tr.data !== exp_data)
        `uvm_error("SCOREBOARD", $sformatf("READ MISMATCH: addr=0x%0h reg=%0d exp=0x%0h got=0x%0h", r_tr.addr, reg_idx, exp_data, r_tr.data))
      else
        `uvm_info("SCOREBOARD", $sformatf("READ PASS: addr=0x%0h reg=%0d data=0x%0h", r_tr.addr, reg_idx, r_tr.data), UVM_MEDIUM)
    end
  end
endfunction

`endif
