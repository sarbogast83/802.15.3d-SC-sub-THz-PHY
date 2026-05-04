Author: Steven Arbogast
Date: 5/4/26
Course: JHU 525.782 Digital Receiver Design 

Project: 802.15.3d sub-THz Single Carrier (SC)

Clone: https://github.com/sarbogast83/802.15.3d-SC-sub-THz-PHY.git

This project implents a data frame for the sub-THz SC protocal. The intentions are to implement and recover a simulated data frame using MATLAB. All code is tested on MATLAB 2025 B. 

Software: Not all packages listed are required 
 
	MATLAB                                                Version 25.2        (R2025b)
	Simulink                                              Version 25.2        (R2025b)
	5G Toolbox                                            Version 25.2        (R2025b)
	Communications Toolbox                                Version 25.2        (R2025b)
	Control System Toolbox                                Version 25.2        (R2025b)
	DSP HDL Toolbox                                       Version 25.2        (R2025b)
	DSP System Toolbox                                    Version 25.2        (R2025b)
	Data Acquisition Toolbox                              Version 25.2        (R2025b)
	Fixed-Point Designer                                  Version 25.2        (R2025b)
	HDL Coder                                             Version 25.2        (R2025b)
	HDL Verifier                                          Version 25.2        (R2025b)
	MATLAB Coder                                          Version 25.2        (R2025b)
	Signal Processing Toolbox                             Version 25.2        (R2025b)
	WLAN Toolbox                                          Version 25.2        (R2025b)
	Wireless HDL Toolbox                                  Version 25.2        (R2025b)
	Wireless Testbench                                    Version 25.2        (R2025b)
	

File Stucture
	- system
		- transmitter
			- txPHYFrameToplevel.m 
				This script will build a full transmition signal including preamble, header, and paylaod. The signal is upsampled and pulseshaped. It will ask where to save. It is recomended to used the txwaveforms folder in the receiver directory for easy access later. 
		
		-receiver
			- receiverToplevel
				Intended full receiver, currently not fully funcitonal. It will read in a singnal, match filter, detect the preamble, implement course timing and pahse correction. Detect the start frame deliminator (SFD) and pass the position to the channel estimation sequence (CES). 
			
			- golaySimDetector.m
				Test script for preambel sync detection including the SFD. 
			
			
			- golaySimDetectorLoop.m
			    Test script for preabmle sync detection including the SFD. Buffers data into the preable detector at estimated Ga128 rate. Will update buffer position to next estimate for best peak detection. Implentents despreaedign to for SFD match. Outputs position of CES and required pahse correction. This is implemetnted directly in the receviertoplevel.m
				
			- filters
				- filterDesign 
					Builds and save RRC with all parameters
					- file: RRCFilter
					
				- GolayFilter
					Builds and saves Ga128 filter for the preamble. Builds and saves Ga8 fitler for the pilotWord (PW) detection. 
					Files: 
						PWFitler
						GaFitler
			- testWaveforms
				Holds receiver ready test singles that have been upsampled and pulse shaped
				- TXtestSig1.mat - full frame 
				- testPreamble - full preamble only 
				
		- helpers 
			- frameDetector: DECOMMISSIONED - 
				system object: parallel data processing for preamble detection with course timign estimate. detects Ga128 and ideal phase for critical sampling 

			- headerEngine
				class < handle 
					Builds full PHY header including upsample and pulse shape. Computes header check sequece, extended hamming encoding, data scrampling, blocking with PW 
			
			- macHeaderClass
				class < handle 
					builds MAC header Informaiton packet
					
			- phyHeaderClass
				class < handle
					BUilds PHY header information packet
			
			- piOverTwoDemod
				system object	
					tracks pi/2 rotation and derotates. Demodulates BPSK and QPSK. Tested in modulation test scripts succesfully. 
	
	
	
	- preamble 
		scripts for building and testing the full preamble 
	
	
	
	
	- modulator
		scipts for mod/demod of pi/2 BPSK and QPSK
		
		- modtest: simple test of pi/2 mod/demod with theory comparison 
		- modtestSciptRC: test pulse shape and match fitler, confirm sprectrum
		- modTestScriptSysObj; test system object demodulator
		- modTestSysObjBuffer: test buffering data at andom intervals, ensure obj holds sym cont for derotation 
		- piOverTwoDemod
			system object to handle the demodulation poecess. Tracks symbol count for proper derotation. 
	
	
	
	- header 
	
	
	- comps
