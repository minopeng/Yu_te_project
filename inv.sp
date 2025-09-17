* Two Stage OP 2023 Yu-Te Liao Project Student *

********* SUB CIRCUIT *********
.param VDD = 1.8
.param VICM = 0.9
.param VSS = 0

********* SUB CIRCUIT *********
.SUBCKT two_stage_amp VI+ VI- VOUT VDD VSS VBias 
.param wid1=2.6u len1=3u
.param wid3=3.3u len3=0.4u
.param wid5=3.876u len5=3u

.param wid6=1.58u len6=0.2u
.param wid7=5.472u len7=3u

.param widB=0.7u lenB=1u

.param CC = 0.2p 
.param CL = 1p

M1 N1 VI- N3 VSS n_18 W=wid1 L=len1 m=2
M2 n2 VI+ N3 VSS n_18 W=wid1 L=len1 m=2

M3 N1 N1 Vdd Vdd  p_18 W=wid3 L=len3 m=2
M4 n2 N1 Vdd Vdd  p_18 W=wid3 L=len3 m=2

M5 N3 Vbias VSS VSS  n_18 W=wid5 L=len5 m=3

Mbias Vbias Vbias VSS VSS n_18 W=widB L=lenB m=1

M6 VOUT N2 Vdd Vdd  p_18 W=wid6 L=len6 m=20
M7 VOUT Vbias VSS VSS  n_18 W=wid7 L=len7 m=10
    
Cc VOUT N2  CC
CL VOUT VSS CL
.ENDS
********* Supply & Bias *********
V1 VDD 0 VDD
V2 VSS 0 VSS
I1 VDD VBias 1u

********* INSTANCE LIB *********
.protect
.lib'/home/u112511037/C018/models/cic018.l'TT
.unprotect


********* MAIN CIRCUIT *********
X1 VI+ VI- VOUT VDD VSS VBias two_stage_amp


*1u for I1
********* OPERATION POINT *********
.option post=1
.option accurate=1
.option post acout=0
.temp 27


** Operation point analysis *
*VIN+ VI+ VSS VICM
*VIN- VI- VSS VICM
*.op

*AC_analysis*
VDM VID VSS 0 ac 1 
VCM VCMI VSS VICM
EIN+ VI+ VCMI VID VSS 0.5
EIN- VI- VCMI VID VSS -0.5
.ac DEC 1000 1 1e9 
.probe vdb(VOUT) vp(VOUT)
.meas ac Unit_Gain_Bandwidth when vdb(VOUT)=0
.meas ac phase_margine FIND=par'180+vp(VOUT)' when vdb(VOUT)=0
.meas ac DC_gain MAX vdb(VOUT)
*.pz v(vout) VDM



*Slew_Rate_analysis*
** Test Slew Rate ==> OP as unit gain buffer (VI- --> VOUT)
*VIN+ VI+ VSS pulse(0 1.8 1u 1n 1n 10u 20u)
*VIN- VI- VOUT 0
*.tran 0.1n 80u  
*.probe I(X1.CL) I(X1.CC)  

*PSRR*
* Remember to turn VDD off *Supply & Bias
**Add the ac signal to supply for PSR testing
*V1 VDD 0 VDD ac 1
*V2 VSS 0 0
*VIN- VI- VSS VICM
*VIN+ VI+ VSS VICM
*.ac DEC 100 1 100MEG
*.probe vdb(VOUT) **This result is PSR
*PSRR definition: Adm/PSR

*CMRR*
** remember to open VDD after PSRR analysis
*VDM VID VSS 0 
*VCM VCMI VSS VICM ac 1
*EIN+ VI+ VCMI VID VSS 0.5
*EIN- VI- VCMI VID VSS -0.5
*.ac DEC 100 1 100MEG
*.probe vdb(VOUT) **This result is Acm
**CMRR definition: Acm/Adm


*Output_Swing_analysis*
** remember to open VDD after PSRR analysis
*Output_Swing_analysis*
*.param offset = 0
*VDM VID VSS offset 
*VCM VCMI VSS VICM
*EIN+ VI+ VCMI VID VSS 0.5
*EIN- VI- VCMI VID VSS -0.5
*.dc offset -1m 1m 0.001m


.end
