
Q
Command: %s
53*	vivadotcl2 
place_design2default:defaultZ4-113h px? 
?
@Attempting to get a license for feature '%s' and/or device '%s'
308*common2"
Implementation2default:default2
xc7z010i2default:defaultZ17-347h px? 
?
0Got license for feature '%s' and/or device '%s'
310*common2"
Implementation2default:default2
xc7z010i2default:defaultZ17-349h px? 
P
Running DRC with %s threads
24*drc2
22default:defaultZ23-27h px? 
V
DRC finished with %s
79*	vivadotcl2
0 Errors2default:defaultZ4-198h px? 
e
BPlease refer to the DRC report (report_drc) for more information.
80*	vivadotclZ4-199h px? 
p
,Running DRC as a precondition to command %s
22*	vivadotcl2 
place_design2default:defaultZ4-22h px? 
P
Running DRC with %s threads
24*drc2
22default:defaultZ23-27h px? 
V
DRC finished with %s
79*	vivadotcl2
0 Errors2default:defaultZ4-198h px? 
e
BPlease refer to the DRC report (report_drc) for more information.
80*	vivadotclZ4-199h px? 
U

Starting %s Task
103*constraints2
Placer2default:defaultZ18-103h px? 
}
BMultithreading enabled for place_design using a maximum of %s CPUs12*	placeflow2
22default:defaultZ30-611h px? 
v

Phase %s%s
101*constraints2
1 2default:default2)
Placer Initialization2default:defaultZ18-101h px? 
?

Phase %s%s
101*constraints2
1.1 2default:default29
%Placer Initialization Netlist Sorting2default:defaultZ18-101h px? 
?
I%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s
268*common2.
Netlist sorting complete. 2default:default2
00:00:002default:default2
00:00:002default:default2
1490.0312default:default2
0.0002default:defaultZ17-268h px? 
Z
EPhase 1.1 Placer Initialization Netlist Sorting | Checksum: 0aaf17c9
*commonh px? 
?

%s
*constraints2s
_Time (s): cpu = 00:00:00 ; elapsed = 00:00:00.025 . Memory (MB): peak = 1490.031 ; gain = 0.0002default:defaulth px? 
?
I%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s
268*common2.
Netlist sorting complete. 2default:default2
00:00:002default:default2
00:00:002default:default2
1490.0312default:default2
0.0002default:defaultZ17-268h px? 
?

Phase %s%s
101*constraints2
1.2 2default:default2F
2IO Placement/ Clock Placement/ Build Placer Device2default:defaultZ18-101h px? 
?0
?IO placement is infeasible. Number of unplaced terminals (%s) is greater than number of available sites (%s).
The following are banks with available pins: %s
58*place2
642default:default2
542default:default2?.
?
 IO Group: 0 with : SioStd: LVCMOS18   VCCO = 1.8 Termination: 0  TermDir:  In   RangeId: 1  has only 54 sites available on device, but needs 64 sites.
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[0]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[1]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[2]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[3]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[4]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[5]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[6]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[7]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[8]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[9]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[10]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[11]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[12]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[13]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[14]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[15]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[16]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[17]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[18]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[19]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[20]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[21]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[22]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[23]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[24]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[25]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[26]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[27]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[28]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[29]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[30]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[31]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[32]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[33]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[34]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[35]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[36]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[37]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[38]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[39]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[40]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[41]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[42]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[43]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[44]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[45]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[46]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[47]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[48]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[49]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[50]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[51]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[52]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[53]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[54]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[55]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[56]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[57]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[58]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[59]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[60]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[61]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[62]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[63]<MSGMETA::END>

"?
i_data_bus[0]2?
 IO Group: 0 with : SioStd: LVCMOS18   VCCO = 1.8 Termination: 0  TermDir:  In   RangeId: 1  has only 54 sites available on device, but needs 64 sites.
	Term: :
	Term: "
i_data_bus[1]:
	Term: "
i_data_bus[2]:
	Term: "
i_data_bus[3]:
	Term: "
i_data_bus[4]:
	Term: "
i_data_bus[5]:
	Term: "
i_data_bus[6]:
	Term: "
i_data_bus[7]:
	Term: "
i_data_bus[8]:
	Term: "
i_data_bus[9]:
	Term: "
i_data_bus[10]:
	Term: "
i_data_bus[11]:
	Term: "
i_data_bus[12]:
	Term: "
i_data_bus[13]:
	Term: "
i_data_bus[14]:
	Term: "
i_data_bus[15]:
	Term: "
i_data_bus[16]:
	Term: "
i_data_bus[17]:
	Term: "
i_data_bus[18]:
	Term: "
i_data_bus[19]:
	Term: "
i_data_bus[20]:
	Term: "
i_data_bus[21]:
	Term: "
i_data_bus[22]:
	Term: "
i_data_bus[23]:
	Term: "
i_data_bus[24]:
	Term: "
i_data_bus[25]:
	Term: "
i_data_bus[26]:
	Term: "
i_data_bus[27]:
	Term: "
i_data_bus[28]:
	Term: "
i_data_bus[29]:
	Term: "
i_data_bus[30]:
	Term: "
i_data_bus[31]:
	Term: "
i_data_bus[32]:
	Term: "
i_data_bus[33]:
	Term: "
i_data_bus[34]:
	Term: "
i_data_bus[35]:
	Term: "
i_data_bus[36]:
	Term: "
i_data_bus[37]:
	Term: "
i_data_bus[38]:
	Term: "
i_data_bus[39]:
	Term: "
i_data_bus[40]:
	Term: "
i_data_bus[41]:
	Term: "
i_data_bus[42]:
	Term: "
i_data_bus[43]:
	Term: "
i_data_bus[44]:
	Term: "
i_data_bus[45]:
	Term: "
i_data_bus[46]:
	Term: "
i_data_bus[47]:
	Term: "
i_data_bus[48]:
	Term: "
i_data_bus[49]:
	Term: "
i_data_bus[50]:
	Term: "
i_data_bus[51]:
	Term: "
i_data_bus[52]:
	Term: "
i_data_bus[53]:
	Term: "
i_data_bus[54]:
	Term: "
i_data_bus[55]:
	Term: "
i_data_bus[56]:
	Term: "
i_data_bus[57]:
	Term: "
i_data_bus[58]:
	Term: "
i_data_bus[59]:
	Term: "
i_data_bus[60]:
	Term: "
i_data_bus[61]:
	Term: "
i_data_bus[62]:
	Term: "
i_data_bus[63]:

2default:default8Z30-58h px? 
?0
?IO placement is infeasible. Number of unplaced terminals (%s) is greater than number of available sites (%s).
The following are banks with available pins: %s
58*place2
722default:default2
542default:default2?.
?
 IO Group: 0 with : SioStd: LVCMOS18   VCCO = 1.8 Termination: 0  TermDir:  In   RangeId: 1  has only 54 sites available on device, but needs 64 sites.
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[0]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[1]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[2]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[3]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[4]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[5]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[6]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[7]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[8]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[9]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[10]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[11]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[12]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[13]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[14]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[15]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[16]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[17]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[18]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[19]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[20]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[21]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[22]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[23]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[24]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[25]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[26]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[27]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[28]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[29]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[30]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[31]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[32]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[33]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[34]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[35]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[36]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[37]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[38]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[39]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[40]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[41]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[42]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[43]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[44]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[45]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[46]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[47]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[48]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[49]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[50]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[51]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[52]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[53]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[54]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[55]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[56]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[57]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[58]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[59]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[60]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[61]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[62]<MSGMETA::END>
	Term: <MSGMETA::BEGIN::BLOCK>i_data_bus[63]<MSGMETA::END>

"?
i_data_bus[0]2?
 IO Group: 0 with : SioStd: LVCMOS18   VCCO = 1.8 Termination: 0  TermDir:  In   RangeId: 1  has only 54 sites available on device, but needs 64 sites.
	Term: :
	Term: "
i_data_bus[1]:
	Term: "
i_data_bus[2]:
	Term: "
i_data_bus[3]:
	Term: "
i_data_bus[4]:
	Term: "
i_data_bus[5]:
	Term: "
i_data_bus[6]:
	Term: "
i_data_bus[7]:
	Term: "
i_data_bus[8]:
	Term: "
i_data_bus[9]:
	Term: "
i_data_bus[10]:
	Term: "
i_data_bus[11]:
	Term: "
i_data_bus[12]:
	Term: "
i_data_bus[13]:
	Term: "
i_data_bus[14]:
	Term: "
i_data_bus[15]:
	Term: "
i_data_bus[16]:
	Term: "
i_data_bus[17]:
	Term: "
i_data_bus[18]:
	Term: "
i_data_bus[19]:
	Term: "
i_data_bus[20]:
	Term: "
i_data_bus[21]:
	Term: "
i_data_bus[22]:
	Term: "
i_data_bus[23]:
	Term: "
i_data_bus[24]:
	Term: "
i_data_bus[25]:
	Term: "
i_data_bus[26]:
	Term: "
i_data_bus[27]:
	Term: "
i_data_bus[28]:
	Term: "
i_data_bus[29]:
	Term: "
i_data_bus[30]:
	Term: "
i_data_bus[31]:
	Term: "
i_data_bus[32]:
	Term: "
i_data_bus[33]:
	Term: "
i_data_bus[34]:
	Term: "
i_data_bus[35]:
	Term: "
i_data_bus[36]:
	Term: "
i_data_bus[37]:
	Term: "
i_data_bus[38]:
	Term: "
i_data_bus[39]:
	Term: "
i_data_bus[40]:
	Term: "
i_data_bus[41]:
	Term: "
i_data_bus[42]:
	Term: "
i_data_bus[43]:
	Term: "
i_data_bus[44]:
	Term: "
i_data_bus[45]:
	Term: "
i_data_bus[46]:
	Term: "
i_data_bus[47]:
	Term: "
i_data_bus[48]:
	Term: "
i_data_bus[49]:
	Term: "
i_data_bus[50]:
	Term: "
i_data_bus[51]:
	Term: "
i_data_bus[52]:
	Term: "
i_data_bus[53]:
	Term: "
i_data_bus[54]:
	Term: "
i_data_bus[55]:
	Term: "
i_data_bus[56]:
	Term: "
i_data_bus[57]:
	Term: "
i_data_bus[58]:
	Term: "
i_data_bus[59]:
	Term: "
i_data_bus[60]:
	Term: "
i_data_bus[61]:
	Term: "
i_data_bus[62]:
	Term: "
i_data_bus[63]:

2default:default8Z30-58h px? 
?
'IO placer failed to find a solution
%s
374*place2?
?Below is the partial placement that can be analyzed to see if any constraint modifications will make the IO placement problem easier to solve.

+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
|                                                                     IO Placement : Bank Stats                                                                           |
+----+-------+-------+------------------------------------------------------------------------+------------------------------------------+--------+--------+--------+-----+
| Id | Pins  | Terms |                               Standards                                |                IDelayCtrls               |  VREF  |  VCCO  |   VR   | DCI |
+----+-------+-------+------------------------------------------------------------------------+------------------------------------------+--------+--------+--------+-----+
|  0 |     0 |     0 |                                                                        |                                          |        |        |        |     |
| 34 |    46 |     0 |                                                                        |                                          |        |        |        |     |
| 35 |     8 |     0 |                                                                        |                                          |        |        |        |     |
+----+-------+-------+------------------------------------------------------------------------+------------------------------------------+--------+--------+--------+-----+
|    |    54 |     0 |                                                                        |                                          |        |        |        |     |
+----+-------+-------+------------------------------------------------------------------------+------------------------------------------+--------+--------+--------+-----+

IO Placement:
+--------+----------------------+-----------------+----------------------+----------------------+----------------------+
| BankId |             Terminal | Standard        | Site                 | Pin                  | Attributes           |
+--------+----------------------+-----------------+----------------------+----------------------+----------------------+
2default:defaultZ30-374h px? 
g
RPhase 1.2 IO Placement/ Clock Placement/ Build Placer Device | Checksum: 0aaf17c9
*commonh px? 
?

%s
*constraints2s
_Time (s): cpu = 00:00:00 ; elapsed = 00:00:00.281 . Memory (MB): peak = 1490.031 ; gain = 0.0002default:defaulth px? 
H
3Phase 1 Placer Initialization | Checksum: 0aaf17c9
*commonh px? 
?

%s
*constraints2s
_Time (s): cpu = 00:00:00 ; elapsed = 00:00:00.283 . Memory (MB): peak = 1490.031 ; gain = 0.0002default:defaulth px? 
?
?Placer failed with error: '%s'
Please review all ERROR and WARNING messages during placement to understand the cause for failure.
1*	placeflow2*
IO Clock Placer failed2default:defaultZ30-99h px? 
=
(Ending Placer Task | Checksum: 0aaf17c9
*commonh px? 
?

%s
*constraints2s
_Time (s): cpu = 00:00:00 ; elapsed = 00:00:00.286 . Memory (MB): peak = 1490.031 ; gain = 0.0002default:defaulth px? 
Z
Releasing license: %s
83*common2"
Implementation2default:defaultZ17-83h px? 
?
G%s Infos, %s Warnings, %s Critical Warnings and %s Errors encountered.
28*	vivadotcl2
402default:default2
02default:default2
02default:default2
52default:defaultZ4-41h px? 
N

%s failed
30*	vivadotcl2 
place_design2default:defaultZ4-43h px? 
m
Command failed: %s
69*common28
$Placer could not place all instances2default:defaultZ17-69h px? 
?
Exiting %s at %s...
206*common2
Vivado2default:default2,
Sun Sep  5 22:44:36 20212default:defaultZ17-206h px? 


End Record