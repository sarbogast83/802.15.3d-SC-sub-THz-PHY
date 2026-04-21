

clear
%%
numBits = 1e6;
bits = randi([0 1],numBits,1);
EbNodB = -5:10;


%% modulate
% BPSK
    bpskSyms = bits * 2 - 1; % mod 
    n = (0:numBits-1)';
    bpskSymsRotated = bpskSyms.*exp(1j*n*pi/2); % rotate
  
% QPSK   
    qpskSyms = pskmod(bits,4,-pi/2,"gray","InputType","bit"); % note -pi/e rotation for standard
    n = (0:numBits/2-1)';
    qpskSymsRotated =  qpskSyms.*exp(1j*n*pi/2); 

%% sys obj demodulator 
bpskDemod = piOverTwoDemod(symOrder=2);
qpskDemod = piOverTwoDemod(symOrder=4);

%% noise
ebnoLin = 10.^(EbNodB/10);
realNoise = randn(numBits,1);
imagNoise = randn(numBits,1);
noiseVec = realNoise + 1j*imagNoise;
noiseScaler = 1./sqrt(2*ebnoLin);
ber_theoretical = 0.5 * erfc(sqrt(ebnoLin));
bpskBER = zeros(1,length(EbNodB));
qpskBER = zeros(1,length(EbNodB));
for i = 1:length(ebnoLin)
   scaledNoiseVec = noiseScaler(i)*noiseVec;
   noisyBpskSymsRotated = bpskSymsRotated + scaledNoiseVec;
   noisyQpskSymsRotated = qpskSymsRotated + scaledNoiseVec(1:numBits/2)/sqrt(2);

   % test bitsteam input
   bufferLen = 42; % arbitray value
   symIdx = 0;
   symbolsReady = 1;
   bpskBERbuffer = [];
   qpskBERbuffer = [];
   receivedBPSKbits = [];
   receivedQPSKbits = [];
   while symbolsReady
    bufferRange = (symIdx*bufferLen+1:symIdx*bufferLen+bufferLen);
    if max(bufferRange) < length(noisyBpskSymsRotated) 
        bpskBuffer = noisyBpskSymsRotated(bufferRange);
    else
        bpskBuffer = noisyBpskSymsRotated(min(bufferRange):end);
        symbolsReady = 0;
    end

    %% demod
    % BPSK
        receivedBPSKbits = [receivedBPSKbits; bpskDemod(bpskBuffer)];

      symIdx = symIdx + 1;  
   end % buffer test
   bpskBERbuffer = sum(receivedBPSKbits~=bits)/numBits; 
   bpskBER(i) = bpskBERbuffer;
   
   
   % QPSK buffer test
   symIdx = 0;
   symbolsReady = 1;
   while symbolsReady
    bufferRange = (symIdx*bufferLen+1:symIdx*bufferLen+bufferLen);
    if max(bufferRange) < length(noisyQpskSymsRotated) 
        qpskBuffer = noisyQpskSymsRotated(bufferRange);
    else
        qpskBuffer = noisyQpskSymsRotated(min(bufferRange):end);
        symbolsReady = 0;
    end

    %% demod
    % QPSK
        receivedQPSKbits =[receivedQPSKbits; qpskDemod(qpskBuffer)];
        
      
    symIdx = symIdx + 1;  
   end % buffer test
   qpskBERbuffer = sum(receivedQPSKbits~=bits)/numBits;
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


