class scoreboard;
//Section S1: Define virtual interface, mailbox and packet class handles
packet ref_pkt,ref_pkt1,ref_pkt2,ref_pkt3,ref_pkt4;
packet got_pkt,got_pkt1,got_pkt2,got_pkt3,got_pkt4;
mailbox #(packet) mbx_in1,mbx_in2,mbx_in3,mbx_in4; 	   // will be connected to input monitor
mailbox #(packet) mbx_out1,mbx_out2,mbx_out3,mbx_out4; // will be connected to output monitor

//Section S2: Define variable total_pkts_recvd to keep track of packets received from monitors
bit [31:0] total_pkts_recvd, iMon_pkts_recvd, oMon_pkts_recvd;
bit [31:0] pkts_count;
bit scoreboard_end;
packet inp_mon_pkts[$];
packet outp_mon_pkts[$];
int inp_outp_map[$];

//Section S3: Define variable to keep track of matched/mis_matched packets
bit [15:0] m_matches;
bit [15:0] m_mismatches;

//Section S4: Define custom constructor with mailbox handles as arguments
function new(input mailbox #(packet) mbx_in1, mbx_in2, mbx_in3, mbx_in4,
			 input mailbox #(packet) mbx_out1,mbx_out2,mbx_out3,mbx_out4,
			 input bit [31:0] count_arg);
	this.mbx_in1    = mbx_in1;
	this.mbx_in2    = mbx_in2;
	this.mbx_in3    = mbx_in3;
	this.mbx_in4    = mbx_in4;
	this.mbx_out1   = mbx_out1;
	this.mbx_out2   = mbx_out2;
	this.mbx_out3   = mbx_out3;
	this.mbx_out4   = mbx_out4;
	this.pkts_count = count_arg;
endfunction

//Section S5: Define run method to start the scoreboard operations
task run();
	$display("[Scoreboard] run started at time=%0t",$time);
	//Section S6: Wait for packet from Input & Output Monitors
	fork: FORK_BLK
		begin
			while(1)
			begin
				mbx_in1.get(ref_pkt1);
				inp_mon_pkts.push_back(ref_pkt1);
				iMon_pkts_recvd++;
				$display("[Scoreboard] Packet %0d received from iMonitor:1 at time=%0t",iMon_pkts_recvd,$time);
			end
		end
		begin
			while(1)
			begin
				mbx_out1.get(got_pkt1);
				outp_mon_pkts.push_back(got_pkt1);
				oMon_pkts_recvd++;
				$display("[Scoreboard] Packet %0d received from oMonitor:1 at time=%0t",oMon_pkts_recvd,$time); 
			end
		end
		begin
			while(1)
			begin
				mbx_in2.get(ref_pkt2);
				inp_mon_pkts.push_back(ref_pkt2);
				iMon_pkts_recvd++;
				$display("[Scoreboard] Packet %0d received from iMonitor:2 at time=%0t",iMon_pkts_recvd,$time); 
			end
		end
		begin
			while(1)
			begin
				mbx_out2.get(got_pkt2);
				outp_mon_pkts.push_back(got_pkt2);
				oMon_pkts_recvd++;
				$display("[Scoreboard] Packet %0d received from oMonitor:2 at time=%0t",oMon_pkts_recvd,$time); 
			end
		end
		begin
			while(1)
			begin
				mbx_in3.get(ref_pkt3);
				inp_mon_pkts.push_back(ref_pkt3);
				iMon_pkts_recvd++;
				$display("[Scoreboard] Packet %0d received from iMonitor:3 at time=%0t",iMon_pkts_recvd,$time); 
			end
		end
		begin
			while(1)
			begin
				mbx_out3.get(got_pkt3);
				outp_mon_pkts.push_back(got_pkt3);
				oMon_pkts_recvd++;
				$display("[Scoreboard] Packet %0d received from oMonitor:3 at time=%0t",oMon_pkts_recvd,$time); 
			end
		end
		begin
			while(1)
			begin
				mbx_in4.get(ref_pkt4);
				inp_mon_pkts.push_back(ref_pkt4);
				iMon_pkts_recvd++;
				$display("[Scoreboard] Packet %0d received from iMonitor:4 at time=%0t",iMon_pkts_recvd,$time); 
			end
		end
		begin
			while(1)
			begin
				mbx_out4.get(got_pkt4);
				outp_mon_pkts.push_back(got_pkt4);
				oMon_pkts_recvd++;
				$display("[Scoreboard] Packet %0d received from oMonitor:4 at time=%0t",oMon_pkts_recvd,$time);
			end
		end
	join_none
	
	wait(iMon_pkts_recvd == pkts_count && oMon_pkts_recvd == pkts_count);
	wait(mbx_in1.num()==0 && mbx_in2.num()==0 && mbx_in3.num()==0 && mbx_in4.num()==0 &&
		 mbx_out1.num()==0 && mbx_out2.num()==0 && mbx_out3.num()==0 && mbx_out4.num()==0);
	total_pkts_recvd = pkts_count;
	disable FORK_BLK;	// To kill all the threads which are still running.
	
	iMon_pkts_recvd = 32'd0;
	oMon_pkts_recvd = 32'd0;
	
	//Section S9: Compare expected packets with received packets from DUT
	// Calculate the rearranging order to match the packets based on sa & da.
	for(int i=0; i<pkts_count; i++)
	begin
		got_pkt = outp_mon_pkts[i];
		inp_outp_map = inp_mon_pkts.find_index() with (item.sa == got_pkt.sa && item.da == got_pkt.da && item.crc == got_pkt.crc && item.len == got_pkt.len);
		foreach(inp_outp_map[k])
		begin
			ref_pkt = inp_mon_pkts[inp_outp_map[k]];
			if(ref_pkt.compare(got_pkt))
			begin
			//Section S10: Increment m_matches count if packet Matches
				m_matches++;
				$display("[Scoreboard] Packet %0d Matched at time=%0t",i+1,$time);
			end
			else
			begin
				//Section S11: Increment m_mismatches count if packet does NOT Match
				m_mismatches++;
				//Section S12: Print enough information (for debug) when packet does NOT Match
				$display("[Scoreboard] ERROR :: Packet %0d Not_Matched at time=%0t",i+1,$time);
				$display("[Scoreboard] *** Expected Packet to DUT****");
				ref_pkt.print();
				$display("[Scoreboard] *** Received Packet From DUT****");
				got_pkt.print();
			end	
		end// end of foreach
	end// end of for		
	inp_mon_pkts.delete();
	outp_mon_pkts.delete();
	$display("[Scoreboard] run ended at time=%0t",$time); 
	scoreboard_end = 1;
endtask

//Section S13: Define report method to print scoreboard summary
function void report();
	$display("[Scoreboard] Report: total_packets_received= %0d", total_pkts_recvd);
	$display("[Scoreboard] Report: Matches= %0d, Mis_Matches= %0d\n\n",m_matches,m_mismatches);
endfunction

endclass