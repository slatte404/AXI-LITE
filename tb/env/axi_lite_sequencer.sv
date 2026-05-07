`ifndef AXI_LITE_SEQUENCER_SV
`define AXI_LITE_SEQUENCER_SV

class axi_lite_sequencer extends uvm_sequencer #(axi_trans_base);
  `uvm_component_utils(axi_lite_sequencer)

  extern function new(string name, uvm_component parent);
endclass

function axi_lite_sequencer::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction

`endif
