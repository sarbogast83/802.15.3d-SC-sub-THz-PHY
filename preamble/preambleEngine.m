% steve Arbogast
% preamble 
%   Figure 13-5 shows the structure of the PHY-long or PHY-short preambles

clear; close all
load('golay128.mat')

%% The SYNC field for
% PHY-short preamble shall consist of 14 code repetitions of a128

SYNC = repmat(Ga,14,1); % column

%% SFD
% 12.2.4.2.3 SFD field
% The SFD is used to establish frame timing as well as the header rate, either MR or HR. The SFD for the two
% header rates are as follows:
% — The MR header shall use an SFD with [+1 –1 +1 –1] spread by a128
% — The HR header shall use an SFD with [+1 +1 –1 –1] spread by a128 *** high rate for data ***

HR = [1 1 -1 -1];
HRGa = HR' * Ga';
SFD = reshape(HRGa',[],1);

%% CES 
% 13.2.4.2.4 CES
% The CES field, used for channel estimation, shall consist of [a256 b512 a512 b128] where the right most
% sequence, b128, is transmitted first.
% The Golay complementary sequences of length 512, denoted by a512 b512, are defined in Equation (13-6)
% and Equation (13-7):

% *** the right sequence is transmited first ***'
a128 = flip(Ga);
b128 = flip(Gb);
a256 = [b128; a128]; % (13-8)
b256 = [-1*b128; a128]; % (13-9)
a512 = [b256; a256]; % (13-6)
b512 = [-1*b256; a256]; %  (13-7)

CESreveresed = [a256; b512; a512; b128];
CES = flip(CESreveresed); % *** this is in transmit order

%% full preamble 
% |SYNC|SFD|CES| fig (13-5)

preamble = [SYNC; SFD; CES];
n = (0:length(preamble)-1)';
preambleMod = preamble .*exp(1j*pi/2*n);
save("phyShortPreamble.mat","preambleMod")