% pi/2 BPSK adn QPSK
% % per 802.15.3d IEEE Computer Society, IEEE standard for wireless multimedia networks,
% Revision of IEEE Std 802.15.3-2016, New York, NY, USA: IEEE LAN/MAN
% Standards Committee, Nov. 2023. DOI: 10.1109/IEEESTD.2023.10332822.




clear; close all
%% init
numBits = 1000;
data = randi([0 1],numBits,1);
M = 4; % BPSK=2, QPSK=4


%% modulator
switch M
    case 2
        n = (0:numBits-1)';
        syms = (data*2-1).*exp(1j * pi/2*n); 

    case 4
        bitPairs = reshape(data,2,[]);
        

    otherwise
        disp('ERROR: Incorrect order M')
        return
end