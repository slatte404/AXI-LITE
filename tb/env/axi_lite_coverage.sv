`include "uvm_macros.svh"
import uvm_pkg::*;

class axi_lite_cov extends uvm_subscriber #(axi_trans_base);
  `uvm_component_utils(axi_lite_cov)
    //定义接口
    uvm_analysis_imp#(axi_trans_base, axi_lite_cov) cov_collected_export;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        cov_collected_export = new("cov_collected_export", this);
    endfunction

  covergroup reg_cover with function sample(int addr);
    option.per_instance = 1;
    option.name = "register_coverage";
    
    addr_cp: coverpoint addr {
      bins reg0 = {0};
      bins reg1 = {1};
      bins reg2 = {2};
      bins reg3 = {3};
      bins reg4 = {4};
      bins reg5 = {5};
    }
  endgroup

covergroup strobe_cover with function sample(bit [7:0] strobe);
  option.per_instance = 1;
  option.name = "strobe_coverage";

  strobe_cp: coverpoint strobe {
    bins all_zero      = {8'b0000_0000};          // 全 0（非法/特殊）
    bins single_byte[] = {1,2,4,8,16,32,64,128};  // 单字节写
    bins lower_half    = {8'b0000_1111};          // 低 32bit
    bins upper_half    = {8'b1111_0000};          // 高 32bit
    bins full_word     = {8'b1111_1111};          // 全 64bit
    bins others        = default;                 // 其他组合
  }
endgroup

covergroup data_cover with function sample(bit [63:0] data);
  option.per_instance = 1;
  option.name = "data_coverage";

  // 数据值 coverpoint
  data_cp: coverpoint data {
    bins all_zero     = {64'h0000_0000_0000_0000};  // 全 0
    bins all_one      = {64'hFFFF_FFFF_FFFF_FFFF};  // 全 1
    bins alt_1010     = {64'hAAAA_AAAA_AAAA_AAAA};  // 交替 1/0
    bins alt_0101     = {64'h5555_5555_5555_5555};  // 交替 0/1
    bins inc_seq      = {[64'h0000_0000_0000_0001 : 64'h0000_0000_0000_0100]}; // 小幅递增
    bins dec_seq      = {[64'hFFFF_FFFF_FFFF_FFFC : 64'hFFFF_FFFF_FFFF_FFFF]}; // 小幅递减
    bins others       = default; // 其他任意值
  }
endgroup


  function new(string name, uvm_component parent);
    super.new(name, parent);
    reg_cover = new();
    strobe_cover = new();
    data_cover = new();
  endfunction

  virtual function void write(axi_trans_base tr);
    axi_write_trans w_tr;
    axi_read_trans  r_tr;

    if ($cast(w_tr, tr)) begin
      reg_cover.sample(w_tr.addr >> 3);
      strobe_cover.sample(w_tr.strobe); // 同时采样 strobe
      data_cover.sample(w_tr.data);
    end

    else if ($cast(r_tr, tr)) begin
      reg_cover.sample(r_tr.addr >> 3);
      data_cover.sample(r_tr.data);
    end
    
  endfunction

endclass
