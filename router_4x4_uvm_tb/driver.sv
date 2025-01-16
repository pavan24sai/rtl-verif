class driver;
//Section D.1:Define virtual interface, mailbox and packet class handles
	packet pkt;
	virtual router_if.tb_mod_port vif;
	mailbox #(packet) mbx;

//Section D.2: Define variable no_of_pkts_recvd to keep track of packets received from generator
	bit [15:0] no_of_pkts_recvd;
	bit [31:0] csr_rdata;
	bit [ 2:0] idx;
	
	bit [31:0] csr_pkt_size_dropped_count; 		//addr='h32
	bit [31:0] csr_invalid_da_pkt_dropped_count;//addr='h66
	bit [31:0] csr_sa1_pkt_dropped_count;		//addr='h70
	bit [31:0] csr_sa2_pkt_dropped_count;		//addr='h72
	bit [31:0] csr_sa3_pkt_dropped_count;		//addr='h74
	bit [31:0] csr_sa4_pkt_dropped_count;		//addr='h76			
	bit [31:0] csr_da1_pkt_dropped_count;		//addr='h80
	bit [31:0] csr_da2_pkt_dropped_count;		//addr='h82
	bit [31:0] csr_da3_pkt_dropped_count;		//addr='h84
	bit [31:0] csr_da4_pkt_dropped_count;		//addr='h86
	bit [31:0] csr_total_crc_dropped_pkt_count;	//addr='h94
	bit [31:0] csr_total_inp_pkt_count;			//addr='h90
	bit [31:0] csr_total_outp_pkt_count;		//addr='h92

//Section D.3: Define custom constructor with mailbox and virtual interface handles as arguments
	function new(input mailbox #(packet) mbx_arg, input virtual router_if.tb_mod_port vif_arg, input bit [2:0] index);
		mbx = mbx_arg;
		vif = vif_arg;
		idx = index;
	endfunction
//Section D.3.1: Define methods run,drive,drive_reset,drive_stimulus, configure_dut_csr and read_dut_csr as extern methods
	extern task run();
	extern task drive(packet pkt);
	extern task drive_reset(packet pkt);
	extern task drive_stimulus(packet pkt);
	extern task configure_dut_csr(packet pkt);
	extern task read_dut_csr(packet pkt);
endclass

//Section D.7: Define run method to start the driver operations
task driver::run();
	$display("[Driver(%0d)] run started at time=%0t",idx,$time);

	while(1) begin //driver runs forever 
		//Section D.7.1: Wait for packet from generator and pullout once packet available in mailbox
		mbx.get(pkt);
		no_of_pkts_recvd++;

		$display("[Driver(%0d)] Received  %0s packet %0d from generator to source port: %0d at time=%0t",idx,pkt.kind.name(),no_of_pkts_recvd,idx,$time); 
		//Section D.7.2: Process the Received transaction
		drive(pkt);
		$display("[Driver(%0d)] Done with %0s packet %0d from generator to source port: %0d at time=%0t",idx,pkt.kind.name(),no_of_pkts_recvd,idx,$time); 
	end//end_of_while
endtask

//Section D.6: Define drive method with packet as argument
task driver::drive(packet pkt);
	//Section D.6.1: Check the transaction type and call the appropriate method
	case(pkt.kind)
		IDLE:		$display("[Driver(%0d)] IDLE packet received at time=%0t",idx, $time);
		RESET: 		drive_reset(pkt);
		STIMULUS: 	drive_stimulus(pkt);
		CSR_WRITE: 	configure_dut_csr(pkt);
		CSR_READ:	read_dut_csr(pkt);
		default:	$display("[Driver(%0d)] Unknown packet received",idx);
	endcase
endtask

//Section D.4: Define drive_reset method with packet as argument
task driver::drive_reset(packet pkt);
	$display("[Driver(%0d)] Driving Reset transaction into DUT at time = %0t",idx, $time);
	vif.reset <= 1'b1;

	repeat(pkt.reset_cycles) @(vif.cb);

	vif.reset <= 1'b0;

	$display("[Driver(%0d)] Driving Reset transaction completed at time = %0t",idx, $time);
endtask


//Section D.5: Define drive_stimulus method with packet as argument
task driver::drive_stimulus(packet pkt);
	@(vif.cb);
	$display("[Driver(%0d)] Driving of packet %0d (size=%0d) to source port: %0d started at time = %0t",idx, no_of_pkts_recvd, pkt.len, idx, $time);

	vif.cb.sa_valid[idx] <= 1;
	foreach(pkt.inp_stream[i])
	begin
		vif.cb.sa[idx] <= pkt.inp_stream[i];
		@(vif.cb);
	end

	$display("[Driver(%0d)] Driving of packet %0d (size=%0d) to source port: %0d ended at time = %0t",idx, no_of_pkts_recvd, pkt.len, idx, $time);

	vif.cb.sa_valid[idx] <= 0;
	vif.cb.sa[idx]       <= 'z;
	repeat(5) @(vif.cb);
endtask

//Section D.8: Define configure_dut_csr method with packet as argument
task driver::configure_dut_csr(packet pkt);
	$display("[Driver(%0d)] Configuring DUT Control registers Started at time=%0t",idx,$time);
	@(vif.cb);
	vif.cb.wr <= 1;
	//Section D.8.1 : Drive pkt.addr onto dut's addr pin
	vif.cb.addr  <= pkt.addr; 
	//Section D.8.2 : Drive pkt.data onto dut's data pin
	vif.cb.wdata <= pkt.data;
	@(vif.cb);
	vif.cb.wr <= 0;
	$display("[Driver(%0d)] Configuring DUT Control registers Ended at time=%0t",idx,$time);
endtask

//Section D.9: Define read_dut_csr method with packet as argument
task driver::read_dut_csr(packet pkt);
	$display("[Driver(%0d)] Reading DUT Status registers Started at time=%0t",idx,$time);
	@(vif.cb);
	vif.cb.rd <= 1;
	//Section D.9.1 : Drive pkt.addr onto dut's addr pin
	vif.cb.addr <= pkt.addr;
	@(vif.cb.rdata);
	//Section D.9.2 : Receive dut's rdata onto csr_rdata
	case(pkt.addr)
	32'h32:	csr_pkt_size_dropped_count		 = vif.cb.rdata;
	32'h66: csr_invalid_da_pkt_dropped_count = vif.cb.rdata;
	32'h70: csr_sa1_pkt_dropped_count		 = vif.cb.rdata;
	32'h72: csr_sa2_pkt_dropped_count		 = vif.cb.rdata;
	32'h74: csr_sa3_pkt_dropped_count	   	 = vif.cb.rdata;
	32'h76: csr_sa4_pkt_dropped_count		 = vif.cb.rdata;
	32'h80: csr_da1_pkt_dropped_count		 = vif.cb.rdata;
	32'h82: csr_da2_pkt_dropped_count		 = vif.cb.rdata;
	32'h84: csr_da3_pkt_dropped_count		 = vif.cb.rdata;
	32'h86: csr_da4_pkt_dropped_count		 = vif.cb.rdata;
	32'h94: csr_total_crc_dropped_pkt_count	 = vif.cb.rdata;
	32'h90:	csr_total_inp_pkt_count			 = vif.cb.rdata;
	32'h92: csr_total_outp_pkt_count		 = vif.cb.rdata;
	endcase	
	vif.cb.rd <= 0;

	$display("[Driver(%0d)] Reading DUT Status registers Ended at time=%0t",idx,$time);
endtask
