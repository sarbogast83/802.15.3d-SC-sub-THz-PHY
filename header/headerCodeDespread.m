% steve arbogast

% 13.2.3.8 Code spreading
% Table 13-12 is a spreading table for a frame header. The most significant bit of the output shall be
% transmitted first in Table 13-12.
% 0: 1010
% 1: 0101

function word = headerCodeDespread(codeWord)
    code0 = 1010;
    code1 = 0101;
    SF = 4; % spreading factor
    codeWordLength = length(codeWord);
    wordLength = codeWordLength / SF;
    word = zeros(1,wordLength);

    
    for i = 1:wordLength
        startIDX = (i-1)*SF + 1;
        endIDX = startIDX + SF - 1;
        code = codeWord(startIDX:endIDX);
        word(i) = sum(code.*code0)/2; % EX; sum(1010.*0101)/2 = 0
    end
end 