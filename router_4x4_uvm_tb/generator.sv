class generator ;

//Section G.1:Define mailbox and packet class handles
	packet ref_pkt;
	mailbox #(packet) mbx1;
	mailbox #(packet) mbx2;
	mailbox #(packet) mbx3;
	mailbox #(packet) mbx4;

//Section G.1.1:Define pkt_count variable which says how many packets generator has to generate.
	bit[31:0] pkt_count; // Multiple of 4.

//Section G.2: Define custom constructor with mailbox and packet class handles as arguments
function new(input mailbox #(packet) mbx_arg1,
			 input mailbox #(packet) mbx_arg2,
			 input mailbox #(packet) mbx_arg3,
			 input mailbox #(packet) mbx_arg4,
			 input bit [31:0] count_arg);
	this.mbx1 	   = mbx_arg1;
	this.mbx2 	   = mbx_arg2;
	this.mbx3 	   = mbx_arg3;
	this.mbx4      = mbx_arg4;
	this.pkt_count = count_arg;
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
	mbx1.put(pkt);

	//Section G.4: Generate Second packet as CSR WRITE packet
	pkt = new;

	//Section G.4.1: Fill the packet type, this will be used in driver to identify
	pkt.kind = CSR_WRITE;
	pkt.addr = 'h20; // csr_sa_enable register addr = 'h20
	pkt.data = 32'hf;
	$display("[Generator] Sending %0s packet %0d to driver at time=%0t",pkt.kind.name(),pkt_id,$time); 
	//Section G.4.2: Place the CSR WRITE packet in mailbox
	mbx1.put(pkt);

	//Section G.5: Generate Third packet as CSR WRITE packet
	pkt = new;
	//Section G.5.1: Fill the packet type, this will be used in driver to identify
	pkt.kind = CSR_WRITE;
	pkt.addr = 'h24; // csr_da_enable register addr = 'h24
	pkt.data = 32'hf;
	$display("[Generator] Sending %0s packet %0d to driver at time=%0t",pkt.kind.name(),pkt_id,$time); 
	//Section G.5.2: Place the CSR WRITE packet in mailbox
	mbx1.put(pkt);
	
	wait(mbx1.num() == 0);
	//Section G.6: Generate NORMAL Stimulus packets
	repeat(pkt_count)
	begin
		pkt_id++;
		assert(ref_pkt.randomize());
		pkt = new;

		pkt.kind = STIMULUS;
		pkt.copy(ref_pkt);

		//Section G.6.2a: Place normal stimulus packet in mailbox
		case(ref_pkt.sa)
		8'd1:	begin
					mbx1.put(pkt);
					$display("[Generator] Packet %0d (size=%0d) to Sa1 Generated at time=%0t",pkt_id,pkt.len,$time);
				end
		8'd2:	begin
					mbx2.put(pkt);
					$display("[Generator] Packet %0d (size=%0d) to Sa2 Generated at time=%0t",pkt_id,pkt.len,$time);
				end
		8'd3:	begin
					mbx3.put(pkt);
					$display("[Generator] Packet %0d (size=%0d) to Sa3 Generated at time=%0t",pkt_id,pkt.len,$time);
				end
		8'd4:	begin
					mbx4.put(pkt);
					$display("[Generator] Packet %0d (size=%0d) to Sa4 Generated at time=%0t",pkt_id,pkt.len,$time);
				end
		default:begin
					mbx1.put(pkt);
					$display("[Generator] Packet %0d (size=%0d) to Sa%0d Generated at time=%0t",pkt.sa,pkt_id,pkt.len,$time);
				end
		endcase
	end
	
    $display("[Generator] run ended at time=%0t",$time);
endtask

endclass