% Steve Arbogast
% Receiver toplevel

clear; close all
%% init 
addpath("testWaveforms\")
load('testWaveforms\TXtestSig1.mat') % this will load all need params

%% noise/channel
% apply here

%% recovery 









%%funtions
function evm = measureEVEM()

end
function ber = measureBER()

end 
function ber = theorticalBER(M,CNR)
    switch M
        case 1 % BPSK

        case 2 % QPSK

    end
end

