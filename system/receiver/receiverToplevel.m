% Steve Arbogast
% Receiver toplevel

clear; close all
%% init 
addpath("testWaveforms\")
load('testWaveforms\TXtestSig1.mat') % this will load all need params

%% noise/channel
% apply here
CNR = 10;  % dB  

%% recovery 









%%funtions
function evm = measureEVM()
    
end
function ber = measureBER(RxBits, TxBits)
    numTxBits = length(TxBits) ;
    numRxBits = length(RxBits);
    if numRxBits == numTxBits
        ber = sum(RxBits~=TxBits)/numBits;
    else
        ber = 100;
        warning('BER test Failed')
    end
end 
function [scaledNoise, theorBER] = awgnNoise(M,CNR,numSamples)
   ebnoLin = 10.^(CNR/10);
   realNoise = randn(numSamples ,1);
   imagNoise = randn(numSamples ,1);
   noiseVec = realNoise + 1j*imagNoise;
   noiseScaler = 1./sqrt(2*ebnoLin);
   theorBER = 0.5 * erfc(sqrt(ebnoLin));
   switch M
       case 1 % BPSK
            scaledNoise = noiseScaler*noiseVec;
       case 2 % QPSK
            scaledNoise = noiseVec(1:numBits/2)/sqrt(2);

   end
end

