class oMonitor;

//Section M2.1:Define virtual interface, mailbox and packet class handles
packet pkt;
virtual router_if.tb_mon vif;
mailbox #(packet) mbx; // will be connected to output of scoreboard

//Section M2.2: Define variable no_of_pkts_recvd to keep track of packets sent to scoreboard
bit [15:0] no_of_pkts_recvd;
bit [ 2:0] idx;

//Section M2.3: Define custom constructor with mailbox and virtual interface handles as arguments
function new(input mailbox #(packet) mbx_arg, input virtual router_if.tb_mon vif_arg, input bit [2:0] index);
	this.mbx   = mbx_arg;
	this.vif   = vif_arg;
	this.idx   = index;
endfunction

//Section M2.4: Define run method to start the monitor operations
task run();
	bit [7:0] outp_q[$];
	$display("[oMon(%0d)] run started at time=%0t ",idx,$time); 
	forever begin //Monitor runs forever
	//Section M2.4.1 : Start of Packet into DUT :Wait on outp_valid to become high
	  @(posedge vif.mcb.da_valid[idx]);
	  no_of_pkts_recvd++;
	  $display("[oMon(%0d)] Started collecting packet %0d at time=%0t ",idx,no_of_pkts_recvd,$time);
	  //Section M2.5 : Capture complete packet driven into DUT
	  while (1) 
		begin
		//Section M2.6: End of packet into DUT: Collect untill outp_valid becomes 0
		if(vif.mcb.da_valid[idx] == 0) begin
			//Section M2.7: Convert Pin level activity to Transaction Level
				pkt = new;
			//Section M2.8: Unpack collected outp_q stream into pkt fields
				pkt.unpack(outp_q);
				pkt.outp_stream=outp_q;
			//Section M2.9: Send collected to scoreboard
				mbx.put(pkt);
				$display("[oMon(%0d)] Sent packet %0d to scoreboard at time=%0t ",idx,no_of_pkts_recvd,$time);
				
				$write("[oMon(%0d)] outp_stream:",idx);
				foreach(pkt.outp_stream[k])
					$write(" %0h",pkt.outp_stream[k]);
				$display("\n");
			//Section M2.10: Delete local outp_q.
				outp_q.delete();
			//Section M2.11: Break out of while loop as collection of packet completed.
				break;
		end//end_of_if
	  
	  //Section M2.12: Wait for posedge of clk to collect all the dut inputs
	  outp_q.push_back(vif.mcb.da[idx]);
	  @(vif.mcb);  
	  end//end_of_while  
	end//end_of_forever
	$display("[oMon(%0d)] run ended at time=%0t ",idx,$time);//monitor will never end 
endtask

//Section M2.13: Define report method to print how many packets collected by oMonitor
function void report();
	$display("[oMon(%0d)] Report: total_packets_collected = %0d",idx, no_of_pkts_recvd);
endfunction

endclass