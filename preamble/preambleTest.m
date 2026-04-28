% steve Arbogast
% preamble 
%   Figure 13-5 shows the structure of the PHY-long or PHY-short preambles

clear; close all
%% The SYNC field for
% PHY-short preamble shall consist of 14 code repetitions of a128

[Ga128,Gb128] = wlanGolaySequence(128); % these match the 802.15 
Ga128 = [0 1 0 1 1 0 1 0 0 1 0 1 0 1 0 1 1 0 0 1 1 0 0 1 1 0 0 1 0 1 1 0 ...
    0 0 1 1 1 1 0 0 0 0 1 1 0 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0 0 0 0 0 ...
    0 0 0 1 1 1 1 0 0 0 0 0 0 0 0 1 1 0 0 1 1 0 0 1 1 0 0 0 0 1 1 0 1 ...
    1 0 1 0 0 1 0 1 1 0 0 1 1 0 1 0 1 0 1 0 1 0 1 0 1 0 0 1 0 1];


sync = repmat(Ga128,14,1); % column

%% The SFD field shall consist of the sign inversion sequence
%of a128

SFD = Ga128 * -1; 

%% CES 
% The CES field, used for channel estimation, shall consist of [a256 b512 a512 b128] where the right most
% sequence, b128, is transmitted first.
