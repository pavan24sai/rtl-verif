//Section 7:Define interface with clk as input
`include "router_dut.sv"
`include "testbench.sv"

interface router_if(input clk);

logic reset;
logic [7:0] dut_inp;
logic inp_valid;
logic [7:0]dut_outp;
logic outp_valid;
logic busy;
logic error;

//CSR related signals
logic wr,rd;
logic [7:0]  addr;
logic [31:0] wdata;
logic [31:0] rdata;

//Section 10 :Define the clocking block
clocking cb@(posedge clk);
    output dut_inp;//Direction are w.r.t TB
    output inp_valid;
    input dut_outp;
    input outp_valid;
    input busy;
    input error;
	output wr,rd;
	output addr;
	output wdata;
	input rdata;
endclocking

//Section 11 :Define clocking block for minotrs
clocking mcb@(posedge clk);
    input dut_inp;
    input inp_valid;
    input dut_outp;
    input outp_valid;
	input busy;
    input error;
endclocking

//Section 9:Define modport for TB Driver
//modport tb_mod_port (output reset,dut_inp,inp_valid, input outp_valid,dut_outp,busy,error);
modport tb_mod_port (clocking cb , output reset);

//Section 12:Define modport for TB Monitors
modport tb_mon (clocking mcb);

endinterface

module top;

//Section1: Variables for Port Connections Of DUT and TB.
logic clk;
  
//Section2: Clock initiliazation and Generation
initial clk=0;
always #5 clk=!clk;

//Section 8: Instantiate interface
router_if router_if_inst(clk);

//Section3:  DUT instantiation
router_dut dut_inst(
	.clk(clk),
	.reset(router_if_inst.reset),
	.dut_inp(router_if_inst.dut_inp),
	.inp_valid(router_if_inst.inp_valid),
	.dut_outp(router_if_inst.dut_outp),
	.outp_valid(router_if_inst.outp_valid),
	.busy(router_if_inst.busy),
	.error(router_if_inst.error),
	.wr(router_if_inst.wr),
	.rd(router_if_inst.rd),
	.addr(router_if_inst.addr),
	.wdata(router_if_inst.wdata),
	.rdata(router_if_inst.rdata)
);

//Section4:  Program Block (TB) instantiation
testbench  tb_inst(.vif(router_if_inst));

//Section 6: Dumping Waveform
initial begin
	$dumpfile("dump.vcd");
	$dumpvars(0, top.dut_inst);
end

endmodule