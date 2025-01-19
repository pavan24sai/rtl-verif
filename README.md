# rtl-verif
Projects focussing on RTL verification (UVM, SV, UVM Framework etc.,)

## SV testbench for a 1 channel router design
[router_1x1_sv_tb](./router_1x1_sv_tb) contains SV testbench files for a 1x1 router DUT.
- This helps to understand various verification components and their functions.
- Gives insights on how to leverage mailboxes for designing a communication framework among the testbench components.
- Motivation to understand and learn UVM.

## UVM testbench for a 4 channel router design
[router_4x4_uvm_tb](./router_4x4_uvm_tb) contains UVM testbench files for a 4x4 router DUT.
- Contains different UVM testbench components like scoreboard, input & output monitors, driver.
- Follows different UVM coding practices to design a fully-functional UVM testbench.