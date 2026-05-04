% steve Arbogast

% Golay hardware sim
clear; close all
%% init

addpath("testWaveforms\")
addpath('filters\')
load('testWaveforms\TXtestSig1.mat') % this will load all need params
load('phyShortPreamble.mat');
Rchip = 1760e6;
Tchip = 1/Rchip;
FSample = Rchip * sps;
Tsample = 1/FSample;

%% golay 
load('RRCfitler.mat')
a128_hex = '5A5599963C33FFF00F00CCC36966AAA5';
a_bits = cell2mat(arrayfun(@(c) dec2bin(hex2dec(c), 4), a128_hex, 'UniformOutput', false)) - '0';
n = 0:length(a_bits)-1;
Ga = 2*a_bits(:) - 1;
GaRotated = Ga .*exp(1j*pi/2*n(:));
GaUp = upsample(GaRotated,sps);
GaRRC = conv(GaUp,RRC.h);
GaMatch = conv(GaRRC,RRC.h);
GaMatch = GaMatch(2*RRC.delay+1:end-2*RRC.delay);
GaFilter = conj(flip(GaMatch));

%% received signal
sro = comm.SampleRateOffset('Offset', 60); %% in ppm; system max 60
vfd = dsp.VariableFractionalDelay;
PreUp = upsample(preambleMod,sps);
PreRRC = conv(PreUp,RRC.h);
% PreRRCoffset = sro(PreRRC); 
PreRRCoffset = vfd(PreRRC,0); 
PreMatch = conv(PreRRC,RRC.h);

% still at sps = 4

%% frame detector
% assume running RRC outfront
threshold = computeThreshold(16.5);
bufferSize = 128*sps;
SFDDetected = false; % invCnt = 2
inversionCnt = 0; % test for 2
pntBuffer = 1;
errorPhase = 0;
priorPhase = 0;
phasePattern = [2 2 2 2];
% PreMatch = PreMatch(100:end);
while pntBuffer + bufferSize < length(PreMatch)
    bufferIdx = pntBuffer : pntBuffer+bufferSize - 1; 
    dataBuffer = PreMatch(bufferIdx);
    % correct phase
    % phaseCorrectedBuffer = dataBuffer .* exp(-1j * errorPhase);
    phaseCorrectedBuffer = dataBuffer;
    bufferCorr = conv(phaseCorrectedBuffer ,GaFilter);
        plot(real(bufferCorr),'-o')
        xline(512,'--g')
        grid on 
    [val,idx] = findpeaks(abs(bufferCorr),"MinPeakHeight",threshold);
    if ~isempty(val)
        val = val(1);
        if val > threshold
            % phase
            currentPhase = angle(bufferCorr(idx));
            SFDval = golayDespread(dataBuffer,Ga);
            phasePattern = [phasePattern(2:end) SFDval];
            SFDDetected = isequal(phasePattern, [1 1 -1 -1]);

            % timing
            estTimingOffset = idx - bufferSize; 
            pntBuffer = bufferIdx(end) + estTimingOffset + 1;
        end % threshold
    else 
        pntBuffer = bufferIdx(end) + 1;
        
    end % Exists
    
    if SFDDetected
        CESstart = pntBuffer;
        break
    end
    % pass out buffer
    % bufferOut = dataBuffer(1:estTimingOffset);
    % or pass pntbuffer to at SFD
end 



%% functions
function threshold = computeThreshold(minCNR) % false pos threhold at min CNR
            minCNR = 16.5; % temp hard code
            L = 128;
            scaleFactor = 20;
            sidelobeEst = sqrt(L) * 4; % sps 
            ebnoLin = 10^(minCNR / 10);
            sigma = 1 / sqrt(2 * ebnoLin);
            sigma = sigma * sqrt(128);
            threshold =sidelobeEst + scaleFactor*(sigma * sqrt(-2* log(0.02))); % 2% FA
        end %

function SFDbit =  golayDespread(data,golay)
    data = data(:);
    dataDown = downsample(data,4);
    n = (0:length(dataDown)-1)';
    dataDerotate = dataDown.*exp(-1j*pi/2.*n);
    intDump = sum(dataDerotate.*golay);
    if real(intDump) > 120
        SFDbit = 1;
    elseif real(intDump) < -120
        SFDbit = -1;
    else
        SFDbit = 0;
    end
end
