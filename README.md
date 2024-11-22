# These are the results of OpenSTA software on the above verilog codes: 

# Circuit1
<img width="503" alt="Screenshot 2024-11-17 at 3 37 45 AM" src="https://github.com/user-attachments/assets/3074fcef-b660-4f93-86b4-98ecf919df62">
<br>
I used the follwing SDC constraints - <br>
<img width="415" alt="Screenshot 2024-11-17 at 3 37 13 AM" src="https://github.com/user-attachments/assets/814c4b34-66a2-4e94-b4b2-a803ee438aff">
<br>
I used the following TCL script - <br>
<img width="394" alt="Screenshot 2024-11-17 at 3 39 17 AM" src="https://github.com/user-attachments/assets/e6d98247-72e1-4340-991d-d892b0919d15">
<br>
I got the following Min and Maxz timing reports - <br>
<img width="519" alt="Screenshot 2024-11-17 at 3 40 06 AM" src="https://github.com/user-attachments/assets/1c37ccaa-8519-4db6-b185-34a73cf5831e">
<br>

# FSM1
You will find the code for this in the above file. But, this is not at gate level abstraction, STA can be peformed at only gate level. So, we have to first convert this to gate level conisting of standard cells from the library. For this, we do logic synthesis (technology mapping) using the following script : <br>

read_liberty -lib NangateOpenCellLibrary_typical.lib <br>

read_verilog top.v <br>

synth -top top <br>

dfflibmap -liberty NangateOpenCellLibrary_typical.lib<br>

abc -liberty NangateOpenCellLibrary_typical.lib<br>
opt<br>
share -aggressive<br>

write_verilog -noattr top_mapped.v<br>

I have also included Synopsys design constraints (SDC) file and set clock latency and output latency in that. These are the constraints I have set : <br>
create_clock -name CLK -period 1000 [get_ports clk] <br>
set_input_delay 5 -clock CLK [get_ports x] <br>
set_output_delay 5 -clock CLK [get_ports y]<br>

Now, the above script will create a netlist of standard cells and write it to a file named top_mmapped.v We can run sta on this file. The circuit looks like this : <br>
<img width="955" alt="Screenshot 2024-11-22 at 11 05 57 AM" src="https://github.com/user-attachments/assets/04632853-0d08-443e-8b44-004375386f03">
<br>
To perform sta I used the following tcl script : <br>
read_liberty NangateOpenCellLibrary_typical.lib<br>
read_verilog top_mapped.v<br>
link_design top<br>
read_sdc top.sdc<br>
report_checks -path_delay max -format full<br>
report_checks -path_delay min -format full<br>

I got the following timing reports on the terminal : <br>
<img width="503" alt="Screenshot 2024-11-22 at 10 57 34 AM" src="https://github.com/user-attachments/assets/8a036563-de1c-4611-b0bf-df95175c2e9f">

# FSM2
Technology mapped netlist - <br>
<img width="1466" alt="Screenshot 2024-11-22 at 2 21 12 PM" src="https://github.com/user-attachments/assets/6b5ab56d-eb63-4bd1-8512-fcbd9feedacd">
<br>
STA for clock period of 1000 - <br>
<img width="467" alt="Screenshot 2024-11-22 at 2 22 47 PM" src="https://github.com/user-attachments/assets/d2e521f4-f084-4045-a1b8-91bae644c1b5">
<br> 
Clearly, both hold and setup constraints are met.<br>
Let us reduce the clock period in SDC file to 5 and see what happens <br>
<img width="477" alt="Screenshot 2024-11-22 at 2 24 11 PM" src="https://github.com/user-attachments/assets/6e8095f6-f1f6-40e5-8f1d-6cbb28ea1083">
As you can see the hold constraint is met but the setup contraint is violated as setup slack is negative which means that the required time is lesser than the arrival time <br>


