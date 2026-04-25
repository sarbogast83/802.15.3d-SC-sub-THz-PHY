% Steve Arbogast
% 525.752
% Header build for 802.15.3d sub-THz SC
% See FIG 14-6

clear; close all
%% MCS
mcs = [0 0 0 0]; % BPSK 0b0000 QPSK 0b0001

%% bandwidth 
bandwidth = [0 0 0 0]; % 2.16 GHz 0b0000

%% scrambler seed ID 
scramblerSeedID = [0 0 0 0]; % intialize to 0b0000; four bit counter incremented per frame

%% PPRE pilot preamble 
ppre = [0 0]; % repeat phy preamble; see table 13-15 0b00 no used currently 

%%  PW pilot word 
pw = [1]; % 8bit piot used 

%% frame length 
% unsinged int
%number of octets in MAC frame body 
% needs to be computed
% 22 bits
frameLength = [1 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0]; % min 0x801 2049 

%% header 
PHYHeader = [mcs bandwidth scramblerSeedID ppre pw frameLength];
