% Steve Arbogast
% Receiver toplevel

clear; close all
%% init 
addpath("testWaveforms\")
addpath('filters\')
load('RRCfitler.mat') % RRC 
load('GaFilter.mat') % sync detector
load('Ga.mat') % for despread SFD
load('PWFilter.mat') % pilotword 
load('testWaveforms\TXtestSig1.mat') % this will load all need params
% load('testWaveforms\testPreamble.mat')
Rchip = 1760e6;
Tchip = 1/Rchip;

FSample = Rchip * sps;
Tsample = 1/FSample;

%% noise/channel
% apply here
CNR = 16.5;  % dB  *** set noise here ****
rxReceive = awgnNoise(CNR,txSymFrameRRC);
% rxReceive = txSymFrameRRC;


%% recovery 
% RRC 
load('RRCfitler.mat')
rxReceiveMatch = conv(rxReceive,RRC.h);
% still at sps = 4

%% frame detector
% assume running RRC outfront
detectCNT = 0;
threshold = computeThreshold(CNR);
% threshold = 150;
bufferSize = 128*sps;
SFDDetected = false; % invCnt = 2
inversionCnt = 0; % test for 2
pntBuffer = 1;
fracTimingOffset = 0;
phaseOffset = 0;
phasePattern = [2 2 2 2];
alpha = .75; % drive phase and timing corrction
vfd = dsp.VariableFractionalDelay('InterpolationMethod', 'Farrow');
vfdGrpDelay = vfd.FilterLength/2;

while pntBuffer + bufferSize < length(rxReceiveMatch)
    bufferIdx = (pntBuffer : pntBuffer+bufferSize - 1 + vfdGrpDelay); 
    dataBuffer = rxReceiveMatch(bufferIdx);
    timedBuffer = vfd(dataBuffer, -fracTimingOffset);
    timedBuffer = timedBuffer(vfdGrpDelay+1:end); % grpdelay
    % correct phase
    % phaseCorrectedBuffer = timedBuffer .* exp(-1j * errorPhase);
    phaseCorrectedBuffer = timedBuffer;
    bufferCorr = conv(phaseCorrectedBuffer ,GaFilter);
        % plot(real(bufferCorr),'-o')
        % xline(512,'--g')
        % grid on 
    % [val,idx] = findpeaks(abs(bufferCorr),"MinPeakHeight",threshold);
    [val,idx] = max(abs(bufferCorr));
    % if ~isempty(val)
    % 
    %     val = val(1);
        if val > threshold
            detectCNT = detectCNT + 1;

            % phase
            phaseError = angle(bufferCorr(idx));
            % phaseOffset = phaseOffset + alpha * phaseError; % interate
            SFDval = golayDespread(phaseCorrectedBuffer,Ga);
            phasePattern = [phasePattern(2:end) SFDval];
            SFDDetected = isequal(phasePattern, [1 1 -1 -1]);

            % timing
            % https://ccrma.stanford.edu/~jos/sasp/Quadratic_Interpolation_Spectral_Peaks.html
            % Quadratic interp
            Qalpha = abs(bufferCorr(idx - 1));
            Qbeta  = abs(bufferCorr(idx));
            Qgamma = abs(bufferCorr(idx + 1));
            fracTimingError = 0.5 * (Qalpha - Qgamma) / (Qalpha - 2*Qbeta + Qgamma);
            courseTimingError = idx - bufferSize;
            fracTimingOffset = fracTimingOffset + alpha * fracTimingError; % integrate
            % not working below 0.5, blows up, likely due to group delay
            % and course timing negotiaiton
            % timingErrorPlot(end+1) = fracTimingOffset ;
            pntBuffer = bufferIdx(end) + courseTimingError + 1;
        % end % threshold
        else 
            pntBuffer = bufferIdx(end) + 1;
            
        end % Exists
    
    if SFDDetected
        CESstart = pntBuffer;
        disp('SFD Found')
        break
    end
    % pass out buffer
    % bufferOut = dataBuffer(1:estTimingOffset);
    % or pass pntbuffer to at SFD
end 










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
% function [scaledNoise, theorBER] = awgnNoise(M,CNR,numSamples)
%    ebnoLin = 10.^(CNR/10);
%    realNoise = randn(numSamples ,1);
%    imagNoise = randn(numSamples ,1);
%    noiseVec = realNoise + 1j*imagNoise;
%    noiseScaler = 1./sqrt(2*ebnoLin);
%    theorBER = 0.5 * erfc(sqrt(ebnoLin));
%    switch M
%        case 1 % BPSK
%             scaledNoise = noiseScaler*noiseVec;
%        case 2 % QPSK
%             scaledNoise = noiseVec(1:numBits/2)/sqrt(2);
% 
%    end
% end

function threshold = computeThreshold(minCNR) % false pos threhold at min CNR
            % minCNR = 16.5; % temp hard code
            L = 128;
            scaleFactor = 10;
            sidelobeEst = sqrt(L) * 4; % sps 
            ebnoLin = 10^(minCNR / 10);
            sigma = 1 / sqrt(2 * ebnoLin);
            sigma = sigma * sqrt(128);
            threshold =sidelobeEst + scaleFactor*(sigma * sqrt(-2* log(0.02))); % 2% FA
            threshold = 150; % temp
        end %

function SFDbit =  golayDespread(data,golay)
    data = data(:);
    dataDown = downsample(data,4);
    n = (0:length(dataDown)-1)';
    dataDerotate = dataDown.*exp(-1j*pi/2.*n);
    intDump = sum(dataDerotate.*golay);
    if real(intDump) > 128/2
        SFDbit = 1;
    elseif real(intDump) < -128/2
        SFDbit = -1;
    else
        SFDbit = 0;
    end
end

function noisySig = awgnNoise(CNR,sig)
   numSamples = length(sig);
   ebnoLin = 10.^(CNR/10);
   realNoise = randn(numSamples ,1);
   imagNoise = randn(numSamples ,1);
   noiseVec = realNoise + 1j*imagNoise;
   noiseScaler = 1./sqrt(2*ebnoLin);
   scaledNoise = noiseScaler*noiseVec;
   noisySig = sig + scaledNoise;
end
