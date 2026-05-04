

clear; close all
%%
numBits = 2^14*8;
bits = randi([0 1],numBits,1);
padding = 20;
bits = [bits; zeros(padding,1)];
EbNodB = -5:15;
sps = 4;
span = 8;
rolloff = 0.25;
sroError = comm.SampleRateOffset('Offset', 0); %% in ppm; system max 60
vfdError = dsp.VariableFractionalDelay;
vfdOffset = 0;
freqOffset = 16e3;
Fsym = 1.76e9;

%% RRC
RRC = rcosdesign(rolloff,span,sps,"sqrt");
RRC = RRC / sqrt(sum(RRC.^2));
RRC_delay = (length(RRC)-1)/2;
numSamps = length(bits)*sps;

%% modulate
% BPSK
    bpskSyms = bits * 2 - 1; % mod 
    n = (0:length(bpskSyms)-1)';
    bpskSymsRotated = bpskSyms.*exp(1j*n*pi/2); % rotate
    bpskSymsUp = upsample(bpskSymsRotated,sps);
    bpskSymsRRC = conv(RRC,bpskSymsUp); 
    bpskSymsRRC = bpskSymsRRC(RRC_delay+1:end-RRC_delay);
    
    bpskCLKoffset = sroError(bpskSymsRRC); % add clock offset, accumulates
    bpskCLKoffset = bpskCLKoffset(26:end);
    bpskSymoffset = vfdError(bpskCLKoffset,vfdOffset); % add const timing offset
    % bpskSymoffset = bpskSymoffset(3:end);
    t = (0:length(bpskSymoffset)-1)'/Fsym/sps;
    bpskFreqOffset = bpskSymoffset .* exp(-1j*2*pi*freqOffset * t); % 

    % testMask(bpskFreqOffset,sps);
% QPSK   
    qpskSyms = pskmod(bits,4,-pi/2,"gray","InputType","bit"); % note -pi/e rotation for standard
    n = (0:length(qpskSyms)-1)';
    qpskSymsRotated =  qpskSyms.*exp(1j*n*pi/2); 
    qpskSymsUp = upsample(qpskSymsRotated,sps);
    qpskSymsRRC = conv(RRC,qpskSymsUp);
    qpskSymsRRC = qpskSymsRRC(RRC_delay+1:end-RRC_delay);
    
    qpskCLKoffset = sroError(qpskSymsRRC); % add clock offset, accumulates
    qpskCLKoffset = qpskCLKoffset(26:end);
    qpskSymoffset = vfdError(qpskCLKoffset,vfdOffset); % add const timing offset
    t = (0:length(qpskSymoffset)-1)'/Fsym/sps;
    qpskFreqOffset = qpskSymoffset .* exp(-1j*2*pi*freqOffset * t); %

    % testMask(qpskFreqOffset,sps);

%% sys obj demodulator 
bpskDemod = piOverTwoDemod(symOrder=2);
qpskDemod = piOverTwoDemod(symOrder=4);

%% noise
ebnoLin = 10.^(EbNodB/10);
L = length(bpskFreqOffset);
realNoise = randn(L,1);
imagNoise = randn(L,1);
noiseVec = realNoise + 1j*imagNoise;
noiseScaler = sqrt(1./(2*ebnoLin));
ber_theoretical = 0.5 * erfc(sqrt(ebnoLin));
bpskBER = zeros(1,length(EbNodB));
qpskBER = zeros(1,length(EbNodB));
for i = 1:length(ebnoLin)
   scaledNoiseVec = noiseScaler(i)*noiseVec;
   noisyBpskSymsRotated = bpskFreqOffset + scaledNoiseVec(1:length(bpskFreqOffset));
   noisyQpskSymsRotated = qpskFreqOffset + scaledNoiseVec(1:length(qpskFreqOffset))/sqrt(2);
    

   %% match adn downsample %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   bpskSymsMatched = conv(RRC,noisyBpskSymsRotated);
   bpskSymsMatched = bpskSymsMatched(RRC_delay+1:end-RRC_delay);
   bpskSymsDown = downsample(bpskSymsMatched,sps);
   qpskSymsMatched = conv(RRC,noisyQpskSymsRotated);
   qpskSymsMatched = qpskSymsMatched(RRC_delay+1:end-RRC_delay);
   qpskSymsDown = downsample(qpskSymsMatched,sps);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% test bitsteam input
   bufferLen = 1000; % arbitray value
   symIdx = 0;
   symbolsReady = 1;
   bpskBERbuffer = [];
   qpskBERbuffer = [];
   receivedBPSKbits = [];
   receivedQPSKbits = [];
   while symbolsReady
    bufferRange = (symIdx*bufferLen+1:symIdx*bufferLen+bufferLen);
    if max(bufferRange) < length(bpskSymsDown) 
        bpskBuffer = bpskSymsDown(bufferRange);
    else
        bpskBuffer = bpskSymsDown(min(bufferRange):end);
        symbolsReady = 0;
    end

    %% demod
    % BPSK
        receivedBPSKbits = [receivedBPSKbits; bpskDemod(bpskBuffer)];

      symIdx = symIdx + 1;  
   end % buffer test
   receivedBPSKbits = receivedBPSKbits(1:numBits); % chop off zeros
   bpskBERbuffer = sum(receivedBPSKbits~=bits(1:numBits))/numBits; 
   bpskBER(i) = bpskBERbuffer;
   
   
   % QPSK buffer test
   symIdx = 0;
   symbolsReady = 1;
   while symbolsReady
    bufferRange = (symIdx*bufferLen+1:symIdx*bufferLen+bufferLen);
    if max(bufferRange) < length(qpskSymsDown) 
        qpskBuffer = qpskSymsDown(bufferRange);
    else
        qpskBuffer = qpskSymsDown(min(bufferRange):end);
        symbolsReady = 0;
    end

    %% demod
    % QPSK
        receivedQPSKbits =[receivedQPSKbits; qpskDemod(qpskBuffer)];
        
      
    symIdx = symIdx + 1;  
   end % buffer test
   qpskBERbuffer = sum(receivedQPSKbits(1:numBits)~=bits(1:numBits))/numBits;
   qpskBER(i) = qpskBERbuffer;
   reset(bpskDemod); % clear n
   reset(qpskDemod);
end
figure
semilogy(EbNodB,ber_theoretical,EbNodB,bpskBER,'-x',EbNodB,qpskBER,'-o')
legend('Theory','BPSK', 'QPSK')
grid on 
title('BER vs EbNo')
xlabel('EbNo [dB]')
ylabel('BER')

function testMask(TxSig,sps)
    symRate = 1760e3;
    fs_total = sps * symRate; 
     [psd, f] = pwelch(TxSig, rectwin(1024), 512, 1024, fs_total, 'centered');
    psd_db = 10*log10(psd);
    psd_norm = psd_db - max(psd_db);
 
    % mask for SC 2.16 Ghz BW see Figu14-1 and table 14-2
    freqParams = [0, 0.94, 1.1, 1.6, 2.2]; % Positive side
    dbLevels = [0, 0, -20, -25, -30];   % Corresponding dBr
    freqParams= [-flip(freqParams(2:end)), freqParams];
    dbLevels  = [flip(dbLevels (2:end)), dbLevels ];

    figure
    plot(freqParams, dbLevels,'--r','LineWidth',1.5);
      hold on;
    plot(f/1e6, psd_norm,'-b'); 
    grid on;
    
    yline([-20 -25 -30], '--g');
    title('Transmit Spectrum');
    legend('Mask','Spectrum')
    ylim([-50 5]);
    
   
end
