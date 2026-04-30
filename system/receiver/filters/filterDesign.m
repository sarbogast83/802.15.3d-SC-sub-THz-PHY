% Steve arbogast
%filters

%% RRC 
clear; close all
Fs = 1760e6 * 4;
RRC = [];
RRC.sps = 4;
RRC.span = 8;
RRC.rolloff = 0.25;
rrc = rcosdesign(RRC.rolloff,RRC.span,RRC.sps,"sqrt");
RRC.h = rrc / sqrt(sum(rrc.^2));
RRC.delay = (length(RRC.h)-1)/2;

[RRC.H, w0] = freqz(rrc ,1,2^12);
figure
plot(w0/pi*Fs,20*log10(abs(RRC.H)));
grid on 
save("RRCfitler","RRC");