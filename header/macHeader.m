Steve Arbogast
525.752
Header build for 802.15.3d sub-THz SC
See Fig 13-6

clear;close all
%%
pMaxFrameBodySize = 2099200*8; %14.1.6.3 in octets

%% frame control field
protocalVersion = [1 0 0]; % pairnet 0b001
frameType =       [0 0 1]; % data 0b100
sec =             [0 ];     % secuity off 
ACK =             [0 0]; % no ACK
logicChannel =    [1];    % ch1
fcReserved =      [0 0 0 0 0 0]; %reserved set to 0s
frameControl = [protocalVersion frameType sec ACK logicChannel fcReserved];

%% PNID
pnid = zeros(1,16); % 16 bits from higher layer

%% Destination ID
destID = [0 0 0 0 0 0 0 0]; % PRC master reserved

%% Source ID
srcID = [0 0 0 0 0 0 0 1]; % 8 bit dummy

%% Tx & ACK info
numOfSubframes =            zeros(1,9); % no subframes in THz SC
lastReceivedFrameType =     [1]; % data 
lastReceivedSequenceNum =   ones(1,10); %initailze ot 0x3FF
bufferFull =                [0]; % sender buffer not full
bufferEmpty =               [0]; % sender buffer not empty
devSleep =                  [0]; % sender not going to sleep
txAckReserved =             [0]; 
txAckInfo = [numOfSubframes lastReceivedFrameType lastReceivedSequenceNum ... 
    bufferFull bufferEmpty devSleep txAckReserved];

%% steam IDX
streamIDX = zeros(1,8); % basic data 

%% full header
MACheader = [frameControl pnid destID srcID txAckInfo streamIDX]; 