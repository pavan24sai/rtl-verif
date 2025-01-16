//Section P.1 Define enum (control knob) to identify transaction type
typedef enum {IDLE, RESET, STIMULUS, CSR_WRITE, CSR_READ} pkt_type_t;

class packet ;
	rand bit [7:0]  sa;
	rand bit [7:0]  da;
		 bit [31:0] len;
		 bit [31:0] crc;
	rand bit [7:0]  payload[];
		 bit [7:0]  inp_stream[$];
		 bit [7:0]  outp_stream[$];

//Section P.2: Define kind variable of type enum pkt_type_t.
pkt_type_t kind;

//Section P.3: Define reset_cycles variable.
bit [7:0] reset_cycles;

//Section P.4: Define CSR related signals
bit    [7:0] addr;
logic [31:0] data;

//Section P.5: Write valid constraints on sa to be in the range of 1 to 4
constraint valid_sa {
	sa inside {[1:4]};
}

//Section P.6: Write valid constraints on da to be in the range of 1 to 4
constraint valid_da {
	da inside {[1:4]};
}

//Section P.7: Write valid constraints on payload size to be in the range of 1 to 1900
constraint valid_payload {
	payload.size() inside {[1:1900]};
	foreach(payload[i]) payload[i] inside {[0:255]};
}

//Section P.8: Implement post_randomize to caluclate crc and len and also pack stimulus into queue.
function void post_randomize();
	// fill the len variable
	len = payload.size() + 1 + 1 + 4 + 4;
	// compute CRC and fill the crc variable
	crc = payload.sum();
	// pack the content to inp_stream
	this.pack(inp_stream);
endfunction

//Section P.9: Implement pack method to pack the stimulus in byte order into queue.
function void pack(ref bit[7:0] q_inp[$]);
	q_inp = {<<8{this.payload, this.crc, this.len, this.da, this.sa}};
endfunction

//Section P.10: Implement unpack method to unpack byte order into packet
function void unpack(ref bit[7:0] q_inp[$]);
	{<<8{this.payload, this.crc, this.len, this.da, this.sa}} = q_inp;
endfunction

//Section P.11: Implement Copy method to the fields of packet
function void copy(packet rhs);
	if(rhs == null)
	begin
		$display("[Error] NULL handle passed to copy method");
		$finish;
	end
	this.sa  = rhs.sa;
	this.da  = rhs.da;
	this.len = rhs.len;
	this.crc = rhs.crc;
	this.payload     = rhs.payload;
	this.inp_stream  = rhs.inp_stream;	
endfunction

//Section P.12: Implement Compare method to comapre the fields of packet 
function bit compare(input packet dut_pkt);
	bit status;
	if(this.inp_stream.size != dut_pkt.outp_stream.size)
	begin
		$display("[COMP_ERROR] Size mismatch exp_size = %0d act_size = %0d", this.inp_stream.size(), dut_pkt.outp_stream.size());
		return 0;
	end
	status = 1;
	foreach(this.inp_stream[i])
		status = status && (this.inp_stream[i] == dut_pkt.outp_stream[i]);
		
	return status;
endfunction

//Section P.13: Implement print method to print the fields of packet 
function void print();
	$write("[Packet Print] Sa=%0d Da=%0d Len=%0d Crc=%0d",sa,da,len,crc);
	$write(" Payload:");
	foreach(payload[k])
		$write(" %0h",payload[k]);
	
	$display("\n");
endfunction

endclass