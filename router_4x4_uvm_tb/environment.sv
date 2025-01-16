//Section E1 : Include packet,generator,driver,iMonitor,oMonitor and scoreboard classes
`include "packet.sv"
`include "generator.sv"
`include "driver.sv"
`include "iMonitor.sv"
`include "oMonitor.sv"
`include "scoreboard.sv"

//Section E2 : Define environment class
class environment;

//Section E3 : Define all components class handles
generator 	gen;
driver 		drvr1, drvr2, drvr3, drvr4;
iMonitor 	iMon1, iMon2, iMon3, iMon4;
oMonitor 	oMon1, oMon2, oMon3, oMon4;
scoreboard 	scb;

//Section E4 : Define Stimulus packet count
bit [15:0] no_of_pkts;//assigned in testcase
bit [15:0] dropped_count;
bit env_disable_report;
bit env_disable_EOT;
//Section E5 : Define mailbox class handles
//Below will be connected to generator and driver(Generator->Driver)
mailbox #(packet) gen_drv_mbox1;
mailbox #(packet) gen_drv_mbox2;
mailbox #(packet) gen_drv_mbox3;
mailbox #(packet) gen_drv_mbox4;
//Below will be connected to input monitor and iMon in scoreborad (iMonitor->scoreboard)
mailbox #(packet) mbx_iMon_scb1;
mailbox #(packet) mbx_iMon_scb2;
mailbox #(packet) mbx_iMon_scb3;
mailbox #(packet) mbx_iMon_scb4;
//Below will be connected to output monitor and oMon in scoreborad (oMonitor->scoreboard)
mailbox #(packet) mbx_oMon_scb1;
mailbox #(packet) mbx_oMon_scb2;
mailbox #(packet) mbx_oMon_scb3;
mailbox #(packet) mbx_oMon_scb4;

//Section E6 : Define virtual interface handles required for Driver,iMonitor and oMonitor
virtual router_if.tb_mod_port vif;
virtual router_if.tb_mon vif_mon_in;
virtual router_if.tb_mon vif_mon_out;

//Section E7: Define custom constructor with virtual interface handles as arguments and pkt count
function new(input virtual router_if.tb_mod_port vif_in,
			 input virtual router_if.tb_mon vif_mon_in,
			 input virtual router_if.tb_mon vif_mon_out,
			 input bit [15:0] no_of_pkts);
	this.vif = vif_in;
	this.vif_mon_in  = vif_mon_in;
	this.vif_mon_out = vif_mon_out;
	this.no_of_pkts  = no_of_pkts;
endfunction
//Section E8: Build Verification components and connect them.
function void build();
	$display("[Environment] build started at time=%0t",$time); 
	//Section E8.1: Construct objects for mailbox handles.
	gen_drv_mbox1 = new(1);
	gen_drv_mbox2 = new(1);
	gen_drv_mbox3 = new(1);
	gen_drv_mbox4 = new(1);
	mbx_iMon_scb1 = new;
	mbx_iMon_scb2 = new;
	mbx_iMon_scb3 = new;
	mbx_iMon_scb4 = new;
	mbx_oMon_scb1 = new;
	mbx_oMon_scb2 = new;
	mbx_oMon_scb3 = new;
	mbx_oMon_scb4 = new;
	//Section E8.2: Construct all components and connect them.
	gen 	= new(gen_drv_mbox1,gen_drv_mbox2,gen_drv_mbox3,gen_drv_mbox4, no_of_pkts);
	drvr1	= new(gen_drv_mbox1, vif, 3'd1);
	drvr2	= new(gen_drv_mbox2, vif, 3'd2);
	drvr3	= new(gen_drv_mbox3, vif, 3'd3);
	drvr4	= new(gen_drv_mbox4, vif, 3'd4);
	iMon1 	= new(mbx_iMon_scb1, vif_mon_in, 3'd1);
	iMon2 	= new(mbx_iMon_scb2, vif_mon_in, 3'd2);
	iMon3 	= new(mbx_iMon_scb3, vif_mon_in, 3'd3);
	iMon4 	= new(mbx_iMon_scb4, vif_mon_in, 3'd4);
	oMon1	= new(mbx_oMon_scb1, vif_mon_out,3'd1);
	oMon2	= new(mbx_oMon_scb2, vif_mon_out,3'd2);
	oMon3	= new(mbx_oMon_scb3, vif_mon_out,3'd3);
	oMon4	= new(mbx_oMon_scb4, vif_mon_out,3'd4);
	scb		= new(mbx_iMon_scb1,mbx_iMon_scb2,mbx_iMon_scb3,mbx_iMon_scb4,
				  mbx_oMon_scb1,mbx_oMon_scb2,mbx_oMon_scb3,mbx_oMon_scb4, no_of_pkts);
	$display("[Environment] build ended at time=%0t",$time); 
endfunction

//Section E9: Define run method to start all components.
task run();
	$display("[Environment] run started at time=%0t",$time);

	//Section E9.2: Start all the components of environment
	fork
	gen.run();
	drvr1.run();
	drvr2.run();
	drvr3.run();
	drvr4.run();
	iMon1.run();
	iMon2.run();
	iMon3.run();
	iMon4.run();
	oMon1.run();
	oMon2.run();
	oMon3.run();
	oMon4.run();
	scb.run();
	join_any

	//Section E9.3 : Wait until scoreboard receives all packets from iMonitor and oMonitor
	if(!env_disable_EOT) // Test termination
		wait(scb.total_pkts_recvd + dropped_count == no_of_pkts);

	repeat(1000) @(vif.cb);//drain time

	//Section E9.4 : Print results of all components
	if(!env_disable_report) 
		report();

	$display("[Environment] run ended at time=%0t",$time); 
endtask

//Section E10 : Define report method to print results.
function void report();
	$display("\n[Environment] ****** Report Started ********** "); 
	//Section E10.1 : Call report method of scoreboard
	scb.report();

	$display("\n*******************************"); 
	//Section E10.2 : Check the results and print test Passed or Failed
	if(scb.m_mismatches == 0 && (no_of_pkts == scb.total_pkts_recvd))
		$display("***********TEST PASSED************");
	else
	begin
		$display("***********TEST FAILED************");
		$display("*******Matches= %0d Mis_matches= %0d**********",scb.m_matches, scb.m_mismatches);
	end

	$display("*************************\n "); 
	$display("[Environment] ******** Report ended******** \n"); 
endfunction

endclass