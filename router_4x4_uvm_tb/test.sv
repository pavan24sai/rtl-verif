//Section T1 : Include environment classes
`include "environment.sv"
//Section T2 : Define test class
class base_test;

//Section T3 : Define Stimulus packet count
bit [15:0] no_of_pkts;
bit [15:0] no_dropped_pkts,total_inp_pkt_count,total_outp_pkt_count;

//Section T4 : Define virtual interface handles required for Driver,iMonitor and oMonitor
virtual router_if.tb_mod_port vif;
virtual router_if.tb_mon vif_mon_in;
virtual router_if.tb_mon vif_mon_out;

//Section T5 : Define environment class handle
environment env;

//Section T6: Define custom constructor with virtual interface handles as arguments.
function new (input virtual router_if.tb_mod_port vif_in,
              input virtual router_if.tb_mon  vif_mon_in,
              input virtual router_if.tb_mon  vif_mon_out
	          );
	this.vif = vif_in;
	this.vif_mon_in  = vif_mon_in;
	this.vif_mon_out = vif_mon_out;

endfunction

//Section T7: Build Verification environment and connect them.
function void build();
//Section T7.1: Construct object for environment and connect interfaces
	env = new(vif, vif_mon_in, vif_mon_out, no_of_pkts);

//Section T7.2: Call env build method which contruct its internal components and connects them
	env.build();
endfunction

//Section T8: Define run method to start Verification environment.
virtual task run ();
	$display("[Testcase] run started at time=%0t",$time);
	//Section T8.1: Decide number of packets to generate in generator
	no_of_pkts = 15;
	//Section T8.2: Construct objects for environment and connects intefaces.
	build();
	
	env.env_disable_EOT    = 1;
	env.env_disable_report = 1;
	//Section T8.3: Start the Verification Environment
	env.run();
		 
	wait(env.scb.scoreboard_end == 1);
		 
	read_dut_csr();
	report();
	$display("[Testcase] run ended at time=%0t",$time);
endtask

task read_dut_csr();
	$display("[Test] Reading DUT Status registers Started at time=%0t",$time);
	@(vif.cb);
	vif.cb.rd 	<= 1;
	vif.cb.addr <= 'h32;	//csr_pkt_size_dropped_count
	@(vif.cb);
	no_dropped_pkts = vif.cb.rdata;
	
	@(vif.cb);
	vif.cb.rd 	<= 1;
	vif.cb.addr <= 'h66;	//csr_invalid_da_pkt_dropped_count
	@(vif.cb);
	no_dropped_pkts = no_dropped_pkts + vif.cb.rdata;
	
	@(vif.cb);
	vif.cb.rd 	<= 1;
	vif.cb.addr <= 'h70;	//csr_sa1_pkt_dropped_count
	@(vif.cb);
	no_dropped_pkts = no_dropped_pkts + vif.cb.rdata;
	
	@(vif.cb);
	vif.cb.rd 	<= 1;
	vif.cb.addr <= 'h72;	//csr_sa2_pkt_dropped_count
	@(vif.cb);
	no_dropped_pkts = no_dropped_pkts + vif.cb.rdata;
	
	@(vif.cb);
	vif.cb.rd 	<= 1;
	vif.cb.addr <= 'h74;	//csr_sa3_pkt_dropped_count
	@(vif.cb);
	no_dropped_pkts = no_dropped_pkts + vif.cb.rdata;
	
	@(vif.cb);
	vif.cb.rd 	<= 1;
	vif.cb.addr <= 'h76;	//csr_sa4_pkt_dropped_count
	@(vif.cb);
	no_dropped_pkts = no_dropped_pkts + vif.cb.rdata;
	
	@(vif.cb);
	vif.cb.rd 	<= 1;
	vif.cb.addr <= 'h80;	//csr_da1_pkt_dropped_count
	@(vif.cb);
	no_dropped_pkts = no_dropped_pkts + vif.cb.rdata;
	
	@(vif.cb);
	vif.cb.rd 	<= 1;
	vif.cb.addr <= 'h82;	//csr_da2_pkt_dropped_count
	@(vif.cb);
	no_dropped_pkts = no_dropped_pkts + vif.cb.rdata;
	
	@(vif.cb);
	vif.cb.rd 	<= 1;
	vif.cb.addr <= 'h84;	//csr_da3_pkt_dropped_count
	@(vif.cb);
	no_dropped_pkts = no_dropped_pkts + vif.cb.rdata;
	
	@(vif.cb);
	vif.cb.rd 	<= 1;
	vif.cb.addr <= 'h86;	//csr_da4_pkt_dropped_count
	@(vif.cb);
	no_dropped_pkts = no_dropped_pkts + vif.cb.rdata;
	
	@(vif.cb);
	vif.cb.rd 	<= 1;
	vif.cb.addr <= 'h94;	//csr_total_crc_dropped_pkt_count
	@(vif.cb);
	no_dropped_pkts = no_dropped_pkts + vif.cb.rdata;
	
	@(vif.cb);
	vif.cb.rd 	<= 1;
	vif.cb.addr <= 'h90;	//csr_total_inp_pkt_count
	@(vif.cb.rdata);
	total_inp_pkt_count = vif.cb.rdata;
	
	@(vif.cb);
	vif.cb.rd 	<= 1;
	vif.cb.addr <= 'h92;	//csr_total_outp_pkt_count
	@(vif.cb);
	total_outp_pkt_count = vif.cb.rdata;
	
	$display("\n*******************************");
	$display("**********CSR Status*************");
	$display("Total input packets count = %0d",total_inp_pkt_count);
	$display("Total output packets count = %0d",total_outp_pkt_count);
	$display("Total dropped count = %0d",no_dropped_pkts);	
	$display("\n*******************************");
	vif.cb.rd <= 0;
	$display("[Test] Reading DUT Status registers Ended at time=%0t",$time);
endtask

function void report();
	$display("\n[Test] ****** Report Started ********** "); 
	//Section E10.1 : Call report method of scoreboard
	this.env.scb.report();

	$display("\n*******************************"); 
	//Section E10.2 : Check the results and print test Passed or Failed
	if(this.env.scb.m_mismatches == 0 && (no_of_pkts == (this.env.scb.total_pkts_recvd + no_dropped_pkts)))
		$display("***********TEST PASSED************");
	else
	begin
		$display("***********TEST FAILED************");
		$display("*******Matches= %0d Mis_matches= %0d**********",this.env.scb.m_matches, this.env.scb.m_mismatches);
	end

	$display("*************************\n "); 
	$display("[Test] ******** Report ended******** \n"); 
endfunction
endclass