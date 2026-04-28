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
% The CES field, used for channel estimation, shall consist of [a256 b512 a512 b128] where the right most
% sequence, b128, is transmitted first.
