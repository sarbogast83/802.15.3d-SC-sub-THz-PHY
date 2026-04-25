classdef macHeaderClass < handle
    %UNTITLED8 Summary of this class goes here
    %   Detailed explanation goes here

    properties
     %% frame control field
        protocalVersion = [1 0 0]; % pairnet 0b001
        frameType =       [0 0 1]; % data 0b100
        sec =             [0 ];     % secuity off 
        ACK =             [0 0]; % no ACK
        logicChannel =    [1];    % ch1
        fcReserved =      [0 0 0 0 0 0]; %reserved set to 0s
        
        
        %% PNID
        pnid = zeros(1,16); % 16 bits from higher layer
        
        %% Destination ID
        destID = [0 0 0 0 0 0 0 0]; % PRC master reserved
        
        %% Source ID
        srcID = [0 0 0 0 0 0 0 1]; % 8 bit dummy
        
        %% Tx & ACK info
        numOfSubframes =            zeros(1,9); % no subframes in THz SC
        lastReceivedFrameType =     [1]; % data 
        lastReceivedSequenceNum =   ones(1,10); %initailze ot 0x3FF
        bufferFull =                [0]; % sender buffer not full
        bufferEmpty =               [0]; % sender buffer not empty
        devSleep =                  [0]; % sender not going to sleep
        txAckReserved =             [0]; 
        
        
        %% steam IDX
        streamIDX = zeros(1,8); % basic data 
        
        %% full header

    end

    properties (SetAccess = private)
        frameControl
        txAckInfo
        MACheader
    end

    methods
        function obj = macHeaderClass()
           obj.updateHeader();
        end

        function updateHeader(obj)
            obj.frameControl = [obj.protocalVersion ... 
                                obj.frameType ...
                                obj.sec ...
                                obj.ACK ...
                                obj.logicChannel ...
                                obj.fcReserved];

            obj.txAckInfo = [obj.numOfSubframes ... 
                             obj.lastReceivedFrameType ...
                             obj.lastReceivedSequenceNum ... 
                             obj.bufferFull ...
                             obj.bufferEmpty ...
                             obj.devSleep ...
                             obj.txAckReserved];

           obj.MACheader = [obj.frameControl... 
                             obj.pnid ...
                             obj.destID ...
                             obj.srcID ...
                             obj.txAckInfo ... 
                             obj.streamIDX];
        end

        function bitArrry = getProp(obj, propName)
            if ~isprop(obj, propName)
                warning('Property "%s" does not exist in this class.', propName);
                return
            end
            % bit arrays are LSB
            bitArrry = obj.(propName);
        end

        function setProp(obj,propName,propVal)
           
            if ~isprop(obj, propName)
                warning('Property "%s" does not exist in this class.', propName);
                return
            end

            propMeta = obj.findprop(propName);
             % do not set frames directly 
            if strcmp(propMeta.SetAccess, 'private')
                warning('Can not directly set %s',propName);
                return
            end
            obj.(propName) = propVal;
            obj.updateHeader();
        end

        function computeArray(obj,binVal)
            %% convert a binary/dec/hex val to the LSB first bit array 
            % do this later
        end

        function reset(obj)
            defaultObj = phyHeaderClass();
            propMeta = obj.findprop(propName);
        end
    end
end