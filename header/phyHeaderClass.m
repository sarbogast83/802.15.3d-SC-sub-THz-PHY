classdef phyHeaderClass < handle
    %UNTITLED8 Summary of this class goes here
    %   Detailed explanation goes here

    properties
        mcs = [0 0 0 0]; % BPSK 0b0000 QPSK 0b0001
        bandwidth = [0 0 0 0]; % 2.16 GHz 0b0000
        scramblerSeedID = [0 0 0 0]; % intialize to 0b0000; four bit counter incremented per frame
        ppre = [0 0]; % repeat phy preamble; see table 13-15 0b00 no used currently 
        pw = [1]; % 8bit piot used 
        frameLength = [1 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0]; % min 0x801 2049  
    end

    properties (SetAccess = private)
        PHYHeader
    end

    methods
        function obj = phyHeaderClass()
            obj.PHYHeader = [obj.mcs ... 
                             obj.bandwidth... 
                             obj.scramblerSeedID... 
                             obj.ppre ...
                             obj.pw ...
                             obj.frameLength];
        end

        function updateHeader(obj)
           obj.PHYHeader = [obj.mcs ... 
                             obj.bandwidth... 
                             obj.scramblerSeedID... 
                             obj.ppre ...
                             obj.pw ...
                             obj.frameLength];
        end

        function bitArrry = getProp(obj, propName)
            if ~isprop(obj, propName)
                warning('Property "%s" does not exist in this class.', propName);
                return
            end
            % bit arrays are LSB
            bitArrry = obj.(propName);
        end

        function setProp(obj,propName)
            % do not set frame directly 
            if strcmp(propName, 'phyHeader')
                warning('Can not directly set PHY header');
                return
            elseif ~isprop(obj, propName)
                warning('Property "%s" does not exist in this class.', propName);
                return
            end
            obj.(propName) = propName;
            obj.updateHeader();
        end

        function computeArray(obj,binVal)
            %% convert a binary/dec/hex val to the LSB first bit array 
            % do this later
        end

        function reset(obj)
            defaultObj = macHeaderClass();
            % propMeta = obj.findprop(propName);
            % meta = ?phyHeaderClass;
            % propMeta = meta.PropertyList;
            defaultStruct = struct(defaultObj);
            fields = fieldnames(defaultStruct);
            for i = 1:length(fields)
                propMeta = obj.findprop(fields{i});
                 % do not set frames directly 
                if ~strcmp(propMeta.SetAccess, 'private')
                    obj.(fields{i}) = defaultStruct.(fields{i});
                end
            end
            obj.updateHeader();
        end
    end
end