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
<br>
As you can see the hold constraint is met but the setup contraint is violated as setup slack is negative which means that the required time is lesser than the arrival time <br>
<br>
Not just this, we can also do power estimation using OpenSTA. We have to specify input_transition and output load for all inputs and outputs in sdc file and set activity factor in tcl script and then add the command report_power to the tcl script and it will give u the power analysis as shown : <br>
<img width="524" alt="Screenshot 2024-11-22 at 10 12 28 PM" src="https://github.com/user-attachments/assets/479e59b4-3a6a-424f-9726-57103bdfc145">
<br>
<br>


# Timer
Technology mapped netlist - <br>
<img width="1470" alt="Screenshot 2024-11-25 at 1 44 48 AM" src="https://github.com/user-attachments/assets/63cf2ed3-b2d7-4cdf-b172-f4ed12a1586f">
<br>
STA for clock period of 5 - <br>
<img width="532" alt="Screenshot 2024-11-25 at 1 49 45 AM" src="https://github.com/user-attachments/assets/14183037-6b8c-4cfc-9c77-e66e6cbeb90f"><br>
Clearly, setup violation exists. To overcome this we can increase clock period <br>
STA after increasing the clock period to 10 - <br>
<img width="532" alt="Screenshot 2024-11-25 at 1 51 24 AM" src="https://github.com/user-attachments/assets/7eb3093d-54b2-4a27-b326-57c528b1fe33"><br>
Now, both setup and hold constraints are met. <br>
Power analysis using OpenSTA tool - <br>
<img width="532" alt="Screenshot 2024-11-25 at 1 52 21 AM" src="https://github.com/user-attachments/assets/7a73b4e7-43a3-4535-94c2-22abf6bdaa6f"><br>
Having done this, we know that there are variations due to process parameters in the timing, what can we do to overcome this. One way is to consider a worst case but this would be pessimistic. Another way, is to perform multimode multicorner(MMMC) analysis and peform timing analysis for all corners (Process, RC parasitics). Now , let us read 3 liberty files in tcl file which are - read_liberty - <br>
lib NangateOpenCellLibrary_typical.lib <br>
read_liberty -lib NangateOpenCellLibrary_slow.lib <br>
read_liberty -lib NangateOpenCellLibrary_fast.lib <br>
We get the following results for typical - <br>
<img width="530" alt="Screenshot 2024-11-25 at 2 00 40 AM" src="https://github.com/user-attachments/assets/10c2ae66-83cc-4060-b5f7-e4be0d8e0495"> <br>
We get the following results for slow - <br>
<img width="530" alt="Screenshot 2024-11-25 at 2 01 11 AM" src="https://github.com/user-attachments/assets/5321d8c9-67f8-4f4c-850e-8b135997fa58"> <br>
As you can see the results greatly vary <br>
Now , let us see the results for fast - <br>
<img width="534" alt="Screenshot 2024-11-25 at 2 01 55 AM" src="https://github.com/user-attachments/assets/1ac34494-69e8-430e-bea3-ce6da7a34210">
<br>
All these reports are generated at once without performing the analysis again and again, so using this method we can generate the timing reports for various processes. Clearly, fast is better than typical which is better than slow. These are NLDM (Non linear delay modelling). For accurate analysis we can also use Composite current source (CCS) and Effective current source(CCS) libraries. <br>




