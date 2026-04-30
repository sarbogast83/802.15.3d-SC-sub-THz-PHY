classdef frameDetector < matlab.System
    % use Ga128 to detect frame 
    properties
        sps
        a128_hex = '5A5599963C33FFF00F00CCC36966AAA5'
        falseAlarm = 0.02
        % sensedBm = -64
        minCNR = 16 % dB computed offline
        frameDetected = false % 

    end

    % Pre-computed constants or internal states
    properties (Access = private)
        pState
        pGolaySequence
        pGolayFilter
        pParallelXcorr
        pThreshold
        pXCorrFIFO = zeros(4,128,14) % adjust buffer size later
        pXCorrFIFOidx = 1
        pPeakIDXbuffer 
    end

    methods (Access = protected)
        function setupImpl(obj,sps)
            obj.sps = sps;
            buildGolay();
            computeThreshold();
        end

        function [coursePeakSample,coursePhaseError] = stepImpl(obj,dataStream)
            numData = length(dataStream);
            buffer = 1:128*obj.sps;
            while max(buffer) <= numData
                bufferData = dataStream(buffer);
                runfilter(obj,bufferData);
                runDetector(obj);

                buffer = buffer + max(buffer);

                if  obj.frameDetected == true
                    break;
                end
            end
            coursePeakSample = obj.pPeakIDXbuffer * obj.pXCorrFIFOidx; % positon in data
            coursePhaseError = obj.peakPhase;
            
        end

        function resetImpl(obj)
            % Initialize / reset internal states
        end

        function obj = buildGolay(obj) % buld the full filter, conj(flip(mod(Ga128))))
            a_bits = cell2mat(arrayfun(@(c) dec2bin(hex2dec(c), 4), obj.a128_hex, 'UniformOutput', false)) - '0';
            Ga = 2*a_bits(:) - 1;
            GaTx = Ga .*exp(1j*pi/2*n);
            obj.pGolayFilter = conj(flip(GaTx));
        end % buildGolay
        
        
        function obj = computeThreshold(obj) % false pos threhold at min CNR
            ebnoLin = 10^(obj.minCNR / 10);
            sigma = 1 / sqrt(2 * ebnoLin);
            sigma = sigma * sqrt(128);
            obj.threshold = sigma * sqrt(-2* log(obj.falseAlarm));
        end % compute threshold
        
        
        function obj = runfilter(obj,bufferData) % parallel conv
            bufferData = bufferData(:);
            parallelData = reshape(bufferData,obj.sps,128);
            obj.pParallelXcorr = conv2(parallelData,obj.pGolayFilter(:).'); % will filter by row
            updateFIFO(obj);
        end % run filter

        function obj = runDetector(obj) % scan for peaks above threhold
            threshold = obj.pThreshold;
            avgXcorr = mean(obj.pXCorrFIFO,3); % average in 3rd dimension
            map = abs(avgXcorr);
            [val, linearIdx] = max(map,[],"all"); % returns linear idx
            [sampleOffset, colIdx] = ind2sub(size(map), linearIdx); % retuns row: sample offset and column
            if val >= threshold
                obj.frameDetected = true;
                obj.sampleOffset = sampleOffset;
                obj.pPeakIDXbuffer = linearIdx;
                measurePhase(obj, colIdx);
            else
                obj.pDection = false;
            end
        end % run detector

        function obj = peakPhase(obj, colIdx) % measure the phase in rads
            map = obj.pParallelXcorr;
            obj.peakPhase = angle(map(obj.symbolOffset,colIdx));
        end % peak phase

        function obj = updateFIFO(obj) % place xcorr matrix in buffer and update cnt
            obj.pXCorrFIFO(:,:,obj.pXCorrFIFOidx) = obj.pParallelXcorr;
            obj.pXCorrFIFOidx = mod(obj.pXCorrFIFOidx, 14) + 1; % rolling counter
        end  % update fifo
    end
end
