%% Steve Arbogast

% Scrambler 12.2.3.10

clear; close
%% 
scramblerSeedID = [0 0 0 0]; %this is a rollling counter
                            % consider int cnt to bit array later or
                            % incremet this array
testData = zeros(1,16);
scrambledBits = scrambleBits(testData,scramblerSeedID);

function scrambledBits = scrambleBits(dataBits, scramblerSeedID)
    dataBits = dataBits(:); % work on columns
    scramblerSeedID = scramblerSeedID(:);
    testVec =  [0; 0; 0; 1; 1; 1; 1; 0; 0; 0; 1; 1; 1; 0; 1; 0];
    
    % [1 1 0 1 0 0 0 0 1 0 1 S1 S2 S3 S4]
    xInit = [1; 1; 0; 1; 0; 0; 0; 0; 1; 0; 1; scramblerSeedID]; %12-13
    
    scrambledBits = zeros(length(dataBits), 1);
    for n = 1:16
%     for n = 1:length(dataBits)
        xn = xor(xInit(14), xInit(15)); % 12-12
        xnTest(n) = xn; 
        scrambledBits(n) = xor(dataBits(n), xn); % 12-14
        xInit = [xn; xInit(1:14)]; % shift
    end
    if sum(xnTest ~= testVec) ~= 0
        warning('scramble fail')
    end
end