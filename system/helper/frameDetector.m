classdef frameDetector < matlab.System
    % use Ga128 to detect frame 
    properties
        sps
        a128_hex = '5A5599963C33FFF00F00CCC36966AAA5'
        falseAlarm = 0.02
        % sensedBm = -64
        minCNR = 16 % dB computed offline
        dataIn
    end

    % Pre-computed constants or internal states
    properties %(Access = private)
        pFrameDetected = false % 
        pState
        pGolaySequence
        pGolayFilter
        pParallelXcorr
        pThreshold
        pXCorrFIFO  % adjust buffer size later
        pXCorrFIFOidx = 1
        pPeakIDXbuffer 
        pPriorData
        pSampleOffset 
    end

    methods 
        function obj = frameDetector(varargin)
            setProperties(obj, nargin, varargin{:});
            obj.pXCorrFIFO = zeros(4,256,14); % adjust buffer size later
        end

        
    end

     methods (Access = protected)
         function setupImpl(obj)
            % obj.dataIn = dataIn;
            buildGolay(obj);
            computeThreshold(obj);
        end

        function [coursePeakSample,coursePhaseError] = stepImpl(obj,dataStream)
            dataStream = [obj.pPriorData;dataStream(:)]; % append last data
            numData = length(dataStream);
            bufferSize = obj.sps * 256;
            buffer = 1:bufferSize;
            while max(buffer) <= numData
                bufferData = dataStream(buffer);
                obj.pPriorData = bufferData;
                runfilter(obj,bufferData);
                runDetector(obj);

                buffer = buffer + bufferSize/2;

                if  obj.pframeDetected == true
                    break;
                end
            end
            lastData = dataStream(max(buffer)+1:end);
            obj.pPriorData = [obj.pPriorData; lastData];
            coursePeakSample = obj.pPeakIDXbuffer * obj.pXCorrFIFOidx; % positon in data
            coursePhaseError = obj.peakPhase;
            
        end

        function resetImpl(obj)
            % Initialize / reset internal states
            obj.pPriorData = [];
            obj.pXCorrFIFO = zeros(4,256,14);
            obj.pXCorrFIFOidx = 1;
            obj.pFrameDetected = false;
        end

        
        
        function obj = runfilter(obj,bufferData) % parallel conv
            bufferData = bufferData(:);
            parallelData = reshape(bufferData,obj.sps,[]);
            obj.pParallelXcorr = conv2(parallelData,obj.pGolayFilter(:).',"same"); % will filter by row
            updateFIFO(obj);
        end % run filter

        function obj = runDetector(obj) % scan for peaks above threhold
            threshold = obj.pThreshold;
            avgXcorr = sum(obj.pXCorrFIFO,3); % average in 3rd dimension
            map = abs(avgXcorr);
            [val, linearIdx] = max(map,[],"all"); % returns linear idx
            [sampleOffset, colIdx] = ind2sub(size(map), linearIdx); % retuns row: sample offset and column
            if val >= threshold
                obj.pFrameDetected = true;
                obj.pSampleOffset = sampleOffset;
                obj.pPeakIDXbuffer = linearIdx;
                measurePhase(obj, colIdx);
            else
                obj.pFrameDetected = false;
            end
        end % run detector

        function obj = measurePhase(obj, colIdx) % measure the phase in rads
            map = obj.pParallelXcorr;
            obj.peakPhase = angle(map(obj.symbolOffset,colIdx));
        end % peak phase

        function obj = updateFIFO(obj) % place xcorr matrix in buffer and update cnt
            obj.pXCorrFIFO(:,:,obj.pXCorrFIFOidx) = obj.pParallelXcorr;
            obj.pXCorrFIFOidx = mod(obj.pXCorrFIFOidx, 14) + 1; % rolling counter
        end  % update fifo

        function obj = buildGolay(obj) % buld the full filter, conj(flip(mod(Ga128))))
            a_bits = cell2mat(arrayfun(@(c) dec2bin(hex2dec(c), 4), obj.a128_hex, 'UniformOutput', false)) - '0';
            n = 0:length(a_bits)-1;
            Ga = 2*a_bits(:) - 1;
            GaTx = Ga .*exp(1j*pi/2*n(:));
            obj.pGolayFilter = conj(flip(GaTx));
        end % buildGolay
        
        
        function obj = computeThreshold(obj) % false pos threhold at min CNR
            ebnoLin = 10^(obj.minCNR / 10);
            sigma = 1 / sqrt(2 * ebnoLin);
            sigma = sigma * sqrt(128);
            obj.pThreshold = sigma * sqrt(-2* log(obj.falseAlarm));
        end % compute threshold
        
    end
end
