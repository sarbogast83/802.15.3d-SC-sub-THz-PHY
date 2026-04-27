% steve Arbogast
% 13.2.4.3.4 Header FEC
% To increase robustness in the frame header, the combination of the PHY header, scrambled MAC header,
% and HCS shall be encoded to concatenated code words of an extended Hamming (EH) code.


I4 = eye(4); %identity matrix
Pmat = [1 1 0 1;...
        0 1 1 1;...
        1 0 1 1;...
        1 1 1 0];

Gmat = [I4 Pmat]; % [I P]
Hmat = [Pmat' I4]; % [P^T I]


function encodedBits = extendedHamming(dataBits,Gmat)
    dataBits = dataBits(:); % column vector
    
    % (8,4) coding need groups of 4
    padLen = mod(4 - mod(length(dataBits), 4), 4);
    paddedData = [dataBits; zeros(padLen, 1)];
    
    numBlocks = length(paddedData) / 4;
    encodedBits = zeros(numBlocks * 8, 1);
    
    for b = 0:numBlocks-1
        blockData = paddedData(b*4 + (1:4));
        encodedBlock = mod(blockData' * G, 2);
        encodedBits(b*8 + (1:8)) = encodedBlock';
    end
end

%% fucntion to decode 
%  this should detect 2 bit error and correct 1 bit, SAVE FOR LATER
