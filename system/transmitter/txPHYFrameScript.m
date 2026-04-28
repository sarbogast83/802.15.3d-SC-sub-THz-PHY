% steve Arbogast 
%% form full tx transmission 
% The PHY Payload field shall be constructed as follows:
% a) Scramble the MAC frame body according to 12.2.3.10
% b) Encode the scrambled MAC frame body, as specified in 14.2.3.2.
% c) Add stuff bits to the encoded and scrambled MAC frame body according to 14.2.3.7.
% d) Map the resulting MAC frame body onto the appropriate constellation, as described in 14.2.3.1.
% e) Build blocks from the resulting MAC frame body according to 13.2.4.5.1.
% f) Insert PPRE periodically, as described in 14.2.4.5.2


clear; close all
%% Data
M = 1; % BPSK
numPayloadSym = 2048*8;
payloadBits = randi([0 1],numPayloadSym*M,1);
numPayloadBits = length(payloadBits); 
%% scramble data
scramblerSeedID = [0 0 0 0]'; %this is a rollling counter
scramblerInit = [1; 1; 0; 1; 0; 0; 0; 0; 1; 0; 1; scramblerSeedID]; %12-13
[scrambledPayloadBits,scramblerState] = scrambleBits(payloadBits,scramblerInit);

%% dummy endode 14/15 LDPC (1440/1344)
padding = 14 - mod(numPayloadSym,14);
numParityBits = (numPayloadBits+padding)/14;
parityBits = randi([0 1], numParityBits+padding,1);
payloadBitsEncoded = [payloadBits; parityBits];

%% stuff bits 
numPayloadBitsEncoded = length(payloadBitsEncoded);
blockSize = 56;
numStuffBits = blockSize - mod(numPayloadBitsEncoded,blockSize);
stuffBits = zeros(numStuffBits,1);
[stuffBitsScrambled, scamblerState] = scrambleBits(stuffBits,scramblerState);
payloadBitsStuffed = [payloadBitsEncoded; stuffBitsScrambled];

%% modulate
numPayloadBitsStuffed = length(payloadBitsStuffed);
n = 0:numPayloadBitsStuffed-1;
if M == 1
    payloadbival = 2*payloadBitsStuffed -1;
else
    %% add QPSK
end
% rotate
payloadModulated = payloadbival .*exp(1j*pi/2*n'); 

%% PW
pilotWord = [1 1 0 1 0 1 1 1]; %0xEB
n = 0:7;
PW = (2*pilotWord-1).*exp(1j*pi/2*n);
% payloadModulated = (1:56*10).';
% imageTest = (1j.*(1:56*10)).';
% payloadModulated = payloadModulated +imageTest;
BitsMat = reshape(payloadModulated,blockSize,[]).';
[numRow,numCol] = size(BitsMat);
PWMat = repmat(PW,numRow,1);
BitsMat_PWMat = [BitsMat PWMat];
payloadBitsBlocked = reshape(BitsMat_PWMat.',[],1);

%% header 
phyHeaderObj = phyHeaderClass();
phyHeaderFrame = phyHeaderObj.PHYheader;
macHeaderObj = macHeaderClass();
macHeaderFrame = macHeaderObj.MACheader;
phyHeaderFrame = headerEngine(phyHeaderFrame,macHeaderFrame);

%% Save
TxWaveform = payloadBitsBlocked;
[filename, folderpath] = uiputfile('*.mat', 'Save Your Variables');
if ischar(filename)
    fullpath = fullfile(folderpath, filename);
    save(fullpath, 'TxWaveform','M', 'numPayloadSym','payloadBits','scramblerSeedID');
end









function [scrambledBits,scrambleState] = scrambleBits(dataBits, scramblerInit)
    %% the scramble and descramble are idenetical, reuse the function for both 
    dataBits = dataBits(:); % work on columns
    xInit = scramblerInit(:);
    scrambledBits = zeros(length(dataBits), 1);
    for n = 1:length(dataBits)
        xn = xor(xInit(14), xInit(15)); % 12-12
        scrambledBits(n) = xor(dataBits(n), xn); % 12-14
        xInit = [xn; xInit(1:14)]; % shift
    end
    scrambleState = xInit;
end
