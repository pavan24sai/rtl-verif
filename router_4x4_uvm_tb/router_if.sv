//Section 7:Define interface with clk as input
interface router_if(input clk);

logic reset;
logic [7:0] sa [4:1];
logic sa_valid [4:1];
logic [7:0] da [4:1];
logic da_valid [4:1];

//CSR related signals
logic wr,rd;
logic [7:0]  addr;
logic [31:0] wdata;
logic [31:0] rdata;

//Section 10 :Define the clocking block
clocking cb@(posedge clk);
    output sa;//Direction are w.r.t TB
    output sa_valid;
    input  da;
    input  da_valid;
   	output wr,rd;
	output addr,wdata;
	input  rdata;
endclocking

//Section 11 :Define clocking block for monitors
clocking mcb@(posedge clk);
    input sa;
    input sa_valid;
    input da;
    input da_valid;
	input rdata;
endclocking

//Section 9:Define modport for TB Driver
//modport tb_mod_port (output reset,sa,sa_valid, input da_valid,da,busy,error);
modport tb_mod_port (clocking cb , output reset);

//Section 12:Define modport for TB Monitors
modport tb_mon (clocking mcb);

endinterface