module top;
`include "router_top.sv"
`include "router_if.sv"
`include "testbench.sv"

//Section1: Variables for Port Connections Of DUT and TB.
logic clk;
  
//Section2: Clock initiliazation and Generation
initial clk=0;
always #5 clk=!clk;

//Section 8: Instantiate interface
router_if router_if_inst(clk);

//Section3:  DUT instantiation
router_top   dut_inst(.clk(clk),
		.reset(router_if_inst.reset),
        .sa1(router_if_inst.sa[1]),
		.sa1_valid(router_if_inst.sa_valid[1]),
        .sa2(router_if_inst.sa[2]),
		.sa2_valid(router_if_inst.sa_valid[2]),
        .sa3(router_if_inst.sa[3]),
		.sa3_valid(router_if_inst.sa_valid[3]),
        .sa4(router_if_inst.sa[4]),
		.sa4_valid(router_if_inst.sa_valid[4]),
		.da1(router_if_inst.da[1]),
		.da1_valid(router_if_inst.da_valid[1]),
		.da2(router_if_inst.da[2]),
		.da2_valid(router_if_inst.da_valid[2]),
		.da3(router_if_inst.da[3]),
		.da3_valid(router_if_inst.da_valid[3]),
		.da4(router_if_inst.da[4]),
		.da4_valid(router_if_inst.da_valid[4]),
		.wr(router_if_inst.wr),
		.rd(router_if_inst.rd),
		.addr(router_if_inst.addr),
		.wdata(router_if_inst.wdata),
		.rdata(router_if_inst.rdata)
		);

//Section4:  Program Block (TB) instantiation
testbench  tb_inst(.vif(router_if_inst));

 
//Section 6: Dumping Waveform
// initial begin
  // $dumpfile("dump.vcd");
  // $dumpvars(0,top.dut_inst); 
// end

endmodule


