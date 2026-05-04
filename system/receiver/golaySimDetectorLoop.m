% steve Arbogast

% Golay hardware sim
clear; close all
%% init

addpath("testWaveforms\")
addpath('..\helper\')
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
CNR = 100; % dB 
sroError = comm.SampleRateOffset('Offset', 0); %% in ppm; system max 60
vfdError = dsp.VariableFractionalDelay;
PreUp = upsample(preambleMod,sps);
PreRRC = conv(PreUp,RRC.h); % **** sig no error ****
noisyPre = awgnNoise(CNR,PreRRC); % add noise
noisyPre = PreRRC;
PreRRCoffset = sroError(noisyPre); % add clock offset, accumulates
PreRRCoffset = vfdError(PreRRCoffset,0.0); % add const timing offset
% PreRRCFreqOffset = PreRRCoffset .* exp(-1j*2*pi*freqOffset * n); % 
PreMatch = conv(PreRRCoffset,RRC.h);

% still at sps = 4

%% frame detector
% assume running RRC outfront
threshold = computeThreshold(CNR);
threshold = 150;
bufferSize = 128*sps;
SFDDetected = false; % invCnt = 2
inversionCnt = 0; % test for 2
pntBuffer = 1;
fracTimingOffset = 0;
phaseOffset = 0;
phasePattern = [2 2 2 2];
alpha = .75; % drive phase and timing corrction
timingErrorPlot = [];
vfd = dsp.VariableFractionalDelay('InterpolationMethod', 'Farrow');
vfdGrpDelay = vfd.FilterLength/2;
% PreMatch = PreMatch(100:end);
while pntBuffer + bufferSize < length(PreMatch)
    bufferIdx = (pntBuffer : pntBuffer+bufferSize - 1 + vfdGrpDelay); 
    dataBuffer = PreMatch(bufferIdx);
    timedBuffer = vfd(dataBuffer, -fracTimingOffset);
    timedBuffer = timedBuffer(vfdGrpDelay+1:end); % grpdelay
    % correct phase
    % phaseCorrectedBuffer = timedBuffer .* exp(-1j * errorPhase);
    phaseCorrectedBuffer = timedBuffer;
    bufferCorr = conv(phaseCorrectedBuffer ,GaFilter);
        plot(real(bufferCorr),'-o')
        xline(512,'--g')
        grid on 
    % [val,idx] = findpeaks(abs(bufferCorr),"MinPeakHeight",threshold);
    [val,idx] = max(abs(bufferCorr));
    % if ~isempty(val)
    % 
    %     val = val(1);
        if val > threshold
            % phase
            phaseError = angle(bufferCorr(idx));
            phaseOffset = phaseOffset + alpha * phaseError; % interate
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
            timingErrorPlot(end+1) = fracTimingOffset ;
            pntBuffer = bufferIdx(end) + courseTimingError + 1;
        % end % threshold
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

%% end main loop for integration
% plot timing error correction
% figure
% plot(timingErrorPlot)

%% functions
function threshold = computeThreshold(minCNR) % false pos threhold at min CNR
            % minCNR = 16.5; % temp hard code
            L = 128;
            scaleFactor = 10;
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