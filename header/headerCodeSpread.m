% steve arbogast

% 13.2.3.8 Code spreading
% Table 13-12 is a spreading table for a frame header. The most significant bit of the output shall be
% transmitted first in Table 13-12.
% 0: 1010
% 1: 0101

function codeWord = headerCodeSpread(word)
    code0 = 1010;
    code1 = 0101;
    SF = 4; % spreading factor
    wordLength = length(word);
    codeWordLength = wordLength * SF;
    codeWord = zeros(1,codeWordLength);

    
    for i = 1:codeWordLength
        startIDX = (i-1)*SF + 1;
        endIDX = startIDX + SF - 1;
        if word(i) == 0 
            codeWord(startIDX:endIDX) = code0;
        else
            codeWord(startIDX:endIDX) = code1;
        end  
    end
end 