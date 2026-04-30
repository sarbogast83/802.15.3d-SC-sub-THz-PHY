classdef frameDetector < matlab.System
    % use Ga128 to detect frame 
    properties
        sps
        a128_hex = '5A5599963C33FFF00F00CCC36966AAA5'
    end

    % Pre-computed constants or internal states
    properties (Access = private)
        pState
        pGolaySequence
        pGolayFilter 
    end

    methods (Access = protected)
        function setupImpl(obj)
            buildGolay();
        end

        function y = stepImpl(obj,u)
            % Implement algorithm. Calculate y as a function of input u and
            % internal states.
            y = u;
        end

        function resetImpl(obj)
            % Initialize / reset internal states
        end

        function obj = buildGolay(obj)
            a_bits = cell2mat(arrayfun(@(c) dec2bin(hex2dec(c), 4), obj.a128_hex, 'UniformOutput', false)) - '0';
            Ga = 2*a_bits(:) - 1;
            GaTx = Ga .*exp(1j*pi/2*n);
            obj.pGolaySequence = conj(flip(GaTx));
        end


    end
end
