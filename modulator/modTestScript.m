

clear
%%
numBits = 1e6;
bits = randi([0 1],numBits,1);
EbNodB = -5:15;


%% modulate
% BPSK
    bpsksyms = bits * 2 - 1; % mod 
    n = (0:numBits-1)';
    bpsksymsRotated = bpsksyms.*exp(1j*n*pi/2); % rotate
  
% QPSK   
    qpskSyms = pskmod(bits,4,-pi/2,"gray","InputType","bit"); % note -pi/e rotation for standard
    n = (0:numBits/2-1)';
    qpskSymsRotated =  qpskSyms.*exp(1j*n*pi/2); 


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
   noisybpsksymsRotated = bpsksymsRotated + scaledNoiseVec;
   noisyqpskSymsRotated = qpskSymsRotated + scaledNoiseVec(1:numBits/2)/sqrt(2);
    %% demod
    % BPSK
        n = (0:numBits-1)';
        bpsksymsDeRotate = noisybpsksymsRotated.*exp(-1j*n*pi/2); % derotate
        receivedBPSKbits = real(bpsksymsDeRotate) > 0; % logic
        bpskBER(i) = sum(receivedBPSKbits~=bits)/numBits; 
    % QPSK
        n = (0:numBits/2-1)';
        qpskSymsDeRotate =  noisyqpskSymsRotated.*exp(-1j*n*pi/2);
        receivedQPSKbits = pskdemod(qpskSymsDeRotate,4,-pi/2,"gray",outputType='bit');
        qpskBER(i) = sum(receivedQPSKbits~=bits)/numBits;
    
    
end
figure
semilogy(EbNodB,ber_theoretical,EbNodB,bpskBER,'-x',EbNodB,qpskBER,'-o')
legend('Theory','BPSK', 'QPSK')
grid on 
title('BER vs EbNo')
xlabel('EbNo [dB]')
ylabel('BER')
