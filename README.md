# These are the results of OpenSTA software on the above verilog codes: 

This repository aims to generate timing reports of several circuits and on the path we will also learn how to write constraints(clock constraints, delay constraints, environment constraints and so on) in sdc (Synopsys design constraints) file, we will also learn how to use various modelling techniques (NLDM,ECS,CCS,etc). We then will proceed to see how process (slow, fast,typical ) affects the timing of circuits and then finally we will perform MMMC and then finish the goal of learning how to generate timing reports.<br>
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
<img width="1470" alt="Screenshot 2024-11-25 at 1 44 48 AM" src="https://github.com/user-attachments/assets/63cf2ed3-b2d7-4cdf-b172-f4ed12a1586f"><br>
<br>
STA for clock period of 5 - <br>
<img width="532" alt="Screenshot 2024-11-25 at 1 49 45 AM" src="https://github.com/user-attachments/assets/14183037-6b8c-4cfc-9c77-e66e6cbeb90f"><br><br>
Clearly, setup violation exists. To overcome this we can increase clock period <br>
STA after increasing the clock period to 10 - <br>
<img width="532" alt="Screenshot 2024-11-25 at 1 51 24 AM" src="https://github.com/user-attachments/assets/7eb3093d-54b2-4a27-b326-57c528b1fe33"><br><br>
Now, both setup and hold constraints are met. <br>
Power analysis using OpenSTA tool - <br>
<img width="532" alt="Screenshot 2024-11-25 at 1 52 21 AM" src="https://github.com/user-attachments/assets/7a73b4e7-43a3-4535-94c2-22abf6bdaa6f"><br><br>
Having done this, we know that there are variations due to process parameters in the timing, what can we do to overcome this. One way is to consider a worst case but this would be pessimistic. Another way, is to perform multimode multicorner(MMMC) analysis and peform timing analysis for all corners (Process, RC parasitics). Now , let us read 3 liberty files in tcl file which are - read_liberty - <br>
lib NangateOpenCellLibrary_typical.lib <br>
read_liberty -lib NangateOpenCellLibrary_slow.lib <br>
read_liberty -lib NangateOpenCellLibrary_fast.lib <br>
We get the following results for typical - <br>
<img width="530" alt="Screenshot 2024-11-25 at 2 00 40 AM" src="https://github.com/user-attachments/assets/10c2ae66-83cc-4060-b5f7-e4be0d8e0495"> <br><br>
We get the following results for slow - <br>
<img width="530" alt="Screenshot 2024-11-25 at 2 01 11 AM" src="https://github.com/user-attachments/assets/5321d8c9-67f8-4f4c-850e-8b135997fa58"> <br>
As you can see the results greatly vary <br>
<br>
Now , let us see the results for fast - <br>
<img width="534" alt="Screenshot 2024-11-25 at 2 01 55 AM" src="https://github.com/user-attachments/assets/1ac34494-69e8-430e-bea3-ce6da7a34210">
<br>
<br>
All these reports are generated at once without performing the analysis again and again, so using this method we can generate the timing reports for various processes. Clearly, fast is better than typical which is better than slow. These are NLDM (Non linear delay modelling). For accurate analysis we can also use Composite current source (CCS) and Effective current source(CCS) libraries. <br>

<img width="711" alt="Screenshot 2024-11-25 at 2 05 23 AM" src="https://github.com/user-attachments/assets/3edc347f-6685-4bd1-9c62-77e548d1ee09">
<br>
<br>

# Design1
Technology mapped netlist - <br>
<img width="856" alt="Screenshot 2024-11-26 at 4 57 29 PM" src="https://github.com/user-attachments/assets/21e88b22-586a-4fc4-908a-3ee8012ee065">
<br>
<br>
Area of the circuit obtained from library - <br>
<img width="449" alt="Screenshot 2024-11-26 at 4 59 50 PM" src="https://github.com/user-attachments/assets/08d0b427-cb95-40cd-8a04-dcd697908e95">
<br>
<br>
Now, let us perform MMMC on slow, typical and fast processes and see the timing reports for the above design - <br>
Slow process - <br>
<img width="489" alt="Screenshot 2024-11-26 at 5 09 36 PM" src="https://github.com/user-attachments/assets/be8fd5b8-77b7-4da9-b723-f0ffaad9c7fa">
<br>
<br><br>
Typical process - <br>
<img width="519" alt="Screenshot 2024-11-26 at 5 22 24 PM" src="https://github.com/user-attachments/assets/f6dc8b0e-0297-4916-a0f1-dc1f88c81e88">
<br>
<img width="530" alt="Screenshot 2024-11-26 at 5 22 44 PM" src="https://github.com/user-attachments/assets/e008f73e-fb26-4e13-85e0-8b6cafa02fe0">
<br><br>
Fast process - <br>
<img width="496" alt="Screenshot 2024-11-26 at 5 23 06 PM" src="https://github.com/user-attachments/assets/abce84a1-2fec-4265-a617-0cf2628bcd60">
<br>
<img width="554" alt="Screenshot 2024-11-26 at 5 23 28 PM" src="https://github.com/user-attachments/assets/d9356cad-5900-40d9-b973-ac98a5f77c15">
<br>
<br>
<br>
Now , let us see if the hold and setup time of the elements changes if I change the input and clock slew. As we know the setup and hold time of elements depends on the input and clock slew, let me change input and clock slew in the sdc file and let us compare with previous result of typical library - <br>
<img width="526" alt="Screenshot 2024-11-26 at 5 18 51 PM" src="https://github.com/user-attachments/assets/993d6bab-77cc-410a-98aa-2c5c83f71acb">
<br>
As you can see , the library setup time has changed slightly when i changed the sdc command from set_input_transition 0.3[get_ports i] to set_input_transition 0.6[get_ports i]. Even for such minute change in input slew, the library setup time is affected <br><br>
Now let us use CCS (Composite current source - typical library) and see what changes <br>
First let us perform tech mapping - <br>
<img width="853" alt="Screenshot 2024-11-26 at 6 05 59 PM" src="https://github.com/user-attachments/assets/62a7c13b-5ec8-4b25-8de0-cb91e0f16319"><br>
As expected the technology mapping remains the same as the cells are still the same , the way of calculating delay and power has changed from NLDM which was previously used <br>
<br>
<br>
Now let us generate timing reports - <br>
I got a lot of warning messages as OpenSTA does not support 'when' attributes, so wherever there is when attribute in the library i got a warning - <br>
<img width="853" alt="Screenshot 2024-11-26 at 6 12 12 PM" src="https://github.com/user-attachments/assets/af0763b1-58c4-4037-bd1b-3f0391f43500"><br>
I got the following timing report after the warnings - <br>
<img width="496" alt="Screenshot 2024-11-26 at 6 13 09 PM" src="https://github.com/user-attachments/assets/8d2ca5ce-aaa1-463d-92ee-8fd7ead0b2e1">
<br>
<br>


