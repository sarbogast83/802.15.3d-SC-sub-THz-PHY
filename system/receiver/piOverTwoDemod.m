classdef piOverTwoDemod < matlab.System
%     pi/2 demodulator: see 802.15.3d for details
%     handles pi/2 rotation
%     BPSK, QPSK demodulation
%     tracks number of symbols for rotation in frame
%         reset for a new frame
    properties
        symOrder % BPSK=2 QPSK = 4 
    end

    properties (DiscreteState)
        
    end

    % Pre-computed constants
    properties (Access = private)
        PnCounter
    end
    
    methods 
        function obj = piOverTwoDemod(varargin)
            setProperties(obj,nargin,varargin{:});
        end
    end

    methods (Access = protected)
        function setupImpl(obj)
            % Perform one-time calculations, such as computing constants
            obj.PnCounter = 0;      
        end

        function y = stepImpl(obj,RxSig) % RxSig is critically sampled
            if isrow(RxSig)
                RxSig = reshape(RxSig,[],1); % all work is clolum vectors
            end 
            len = length(RxSig);
            n = (0:len-1)' + obj.PnCounter; % set n to correct value for input
            obj.PnCounter = len + obj.PnCounter;
            deRotateRx = RxSig.*exp(-1j*n*pi/2);
    
            switch obj.symOrder
                case 2
                    y = real(deRotateRx) > 0;
                case 4
                    y = pskdemod(deRotateRx,4,-pi/2,"gray",outputType='bit');
                otherwise
                    disp('ERROR in demodulator: Mod TYpe')
            end
        end

        function resetImpl(obj)
            obj.PnCounter = 0;
        end
    end
end
