class generator ;
//Section G.1:Define mailbox and packet class handles
packet ref_pkt;
mailbox#(packet) mbx;

//Section G.1.1:Define pkt_count variable which says how many packets generator has to generate.
bit [31:0] pkt_count;


//Section G.2: Define custom constructor with mailbox and packet class handles as arguments
function new(input mailbox#(packet) mbx_arg, input bit [31:0] count_arg);
	mbx = mbx_arg;
	pkt_count = count_arg;
	ref_pkt = new;
endfunction


//Section G.3: Define run method to implement actual functionality of generator.
task run ();

	//Section 3.3.1 : Define pkt_id variable to keep track of how many packets generated.
	bit [31:0] pkt_id;

	//Section G.3.2: Define the class packet handle
	packet pkt;

	//Section G.3.3: Generate First packet as Reset packet
	pkt = new;

	//Section G.3.4: Fill the packet type, this will be used in driver to identify
	pkt.kind = RESET;
	pkt.reset_cycles = 2;

	$display("[Generator] Sending %0s packet %0d to driver at time=%0t",pkt.kind.name(),pkt_id,$time); 
	//Section G.3.5: Place the Reset packet in mailbox
	mbx.put(pkt);

	//Section G.4: Generate Second packet as CSR WRITE packet
	pkt = new;

	//Section G.4.1: Fill the packet type, this will be used in driver to identify
	pkt.kind = CSR_WRITE;
	pkt.addr = 'h20; // csr_sa_enable register addr = 'h20
	pkt.data = 31'hf;

	$display("[Generator] Sending %0s packet %0d to driver at time=%0t",pkt.kind.name(),pkt_id,$time); 
	//Section G.4.2: Place the CSR WRITE packet in mailbox
	mbx.put(pkt);

	//Section G.5: Generate Third packet as CSR WRITE packet
	pkt = new;

	//Section G.5.1: Fill the packet type, this will be used in driver to identify
	pkt.kind = CSR_WRITE;
	pkt.addr = 'h24; // csr_da_enable register addr = 'h24
	pkt.data = 31'hf;

	$display("[Generator] Sending %0s packet %0d to driver at time=%0t",pkt.kind.name(),pkt_id,$time); 
	//Section G.5.2: Place the CSR WRITE packet in mailbox
	mbx.put(pkt);

	//Section G.6: Generate NORMAL Stimulus packets
	repeat(pkt_count) begin
		//Section G.6.1: Fill the packet type, this will be used in driver to identify
		pkt_id++;
		assert(ref_pkt.randomize());
		pkt = new();

		//Section G.6.2: Place normal stimulus packet in mailbox
		pkt.kind = STIMULUS;
		pkt.copy(ref_pkt);
		mbx.put(pkt);

		$display("[Generator] Packet %0d (size=%0d) Generated at time=%0t",pkt_id,pkt.len,$time); 
	end

	//Section G.7: Generate Status Register READ stimulus as CSR READ packet
	pkt = new();

	//Section G.7.1: Fill the packet type, this will be used in driver to identify
	pkt.kind = CSR_READ;
	pkt.addr = 'h36; // csr_total_inp_count addr = 'h36;

	$display("[Generator] Sending %0s packet %0d to driver at time=%0t",pkt.kind.name(),pkt_id,$time); 
	//Section G.7.2: Place the CSR READ packet in mailbox
	mbx.put(pkt);

	//Section G.8.1: Fill the packet type, this will be used in driver to identify
	pkt = new();

	pkt.kind = CSR_READ;
	pkt.addr = 'h40; // csr_total_outp_count addr = 'h40;

	$display("[Generator] Sending %0s packet %0d to driver at time=%0t",pkt.kind.name(),pkt_id,$time); 

	//Section G.8.2: Place the CSR READ packet in mailbox
	mbx.put(pkt);
	$display("[Generator] run ended at time=%0t",$time);
endtask

endclass

