`ifndef AXI_LITE_COVERAGE_SV
`define AXI_LITE_COVERAGE_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

class axi_lite_cov extends uvm_subscriber #(axi_trans_base);
  `uvm_component_utils(axi_lite_cov)

  // 移除了重复定义的 cov_collected_export，直接使用继承自 uvm_subscriber 的 analysis_export 即可

  // ==== Covergroups ====
  covergroup reg_cover with function sample(int addr);
    option.per_instance = 1;
    option.name = "register_coverage";
    addr_cp: coverpoint addr {
      bins reg0 = {0}; bins reg1 = {1}; bins reg2 = {2};
      bins reg3 = {3}; bins reg4 = {4}; bins reg5 = {5};
    }
  endgroup

  covergroup strobe_cover with function sample(bit [7:0] strobe);
    option.per_instance = 1;
    option.name = "strobe_coverage";
    strobe_cp: coverpoint strobe {
      bins all_zero      = {8'b0000_0000};
      bins single_byte[] = {1,2,4,8,16,32,64,128};
      bins lower_half    = {8'b0000_1111};
      bins upper_half    = {8'b1111_0000};
      bins full_word     = {8'b1111_1111};
      bins others        = default;
    }
  endgroup

  covergroup data_cover with function sample(bit [63:0] data);
    option.per_instance = 1;
    option.name = "data_coverage";
    data_cp: coverpoint data {
      bins all_zero     = {64'h0000_0000_0000_0000};
      bins all_one      = {64'hFFFF_FFFF_FFFF_FFFF};
      bins alt_1010     = {64'hAAAA_AAAA_AAAA_AAAA};
      bins alt_0101     = {64'h5555_5555_5555_5555};
      bins inc_seq      = {[64'h0000_0000_0000_0001 : 64'h0000_0000_0000_0100]};
      bins dec_seq      = {[64'hFFFF_FFFF_FFFF_FFFC : 64'hFFFF_FFFF_FFFF_FFFF]};
      bins others       = default;
    }
  endgroup

  // ==== 方法声明 (extern) ====
  extern function new(string name, uvm_component parent);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void write(axi_trans_base t);

endclass

// =========================================================================
// 方法实现区 (外部实现)
// =========================================================================

function axi_lite_cov::new(string name, uvm_component parent);
  super.new(name, parent);
  reg_cover = new();
  strobe_cover = new();
  data_cover = new();
endfunction

function void axi_lite_cov::build_phase(uvm_phase phase);
  super.build_phase(phase);
endfunction

function void axi_lite_cov::write(axi_trans_base t);
  axi_write_trans w_tr;
  axi_read_trans  r_tr;

  if ($cast(w_tr, t)) begin
    reg_cover.sample(w_tr.addr >> 3);
    strobe_cover.sample(w_tr.strobe);
    data_cover.sample(w_tr.data);
  end
  else if ($cast(r_tr, t)) begin
    reg_cover.sample(r_tr.addr >> 3);
    data_cover.sample(r_tr.data);
  end
endfunction

`endif
