classdef itaMSTFni < itaMSTF
    % This is a class for Transfer Function or Impulse Response
    % measurements with a National Instruments (NI) DAC using the DAQ toolbox.
    % It supports everything that the regular itaMSTF class does, so see that for
    % more info.
    %
    % Specific to this class: the NI setup is done with the Data
    % Acquisition Toolbox, and changes to the channel setup have to be
    % monitored and the NI session has to be updated accordingly.
    %
    % See also: itaMSTF
    
    % Author: Markus Mueller-Trapet 2017 - markus.mueller-trapet@nrc.ca
    
    properties(Access = public, Hidden = true) % internal variables
        niSession = []; % to store information about NI card setup
        niOutputFactor = []; % V maximum output of the sound card
    end
    
    methods
        
        %% CONSTRUCT / INIT / EDIT / COMMANDLINE
        
        function this = itaMSTFni(varargin)
            % itaMSTFni - Constructs an itaMSTFni object.
            if nargin == 0
                
                % For the creation of itaMSTFni objects from commandline strings
                % like the ones created with the commandline method of this
                % class, 2 or more input arguments have to be allowed. All
                % desired properties have to be given in pairs of two, the
                % first element being an identifying string which will be used
                % as field name for the property, and the value of the
                % specified property.
            elseif nargin >= 2
                if ~isnatural(nargin/2)
                    error('Even number of input arguments expected!');
                end
                
                % For all given pairs of two, use the first element as
                % field name, the second one as value. The validity of the
                % field names will NOT be checked.
                for idx = 1:2:nargin
                    this.(varargin{idx}) = varargin{idx+1};
                end
                
                % Only one input argument is required for the creation of an
                % itaMSTFni class object from a struct, created by the saveobj
                % method, or as a copy of an already existing itaMSTFni class
                % object. In the latter case, only the properties contained in
                % the list of saved properties will be copied.
            elseif isstruct(varargin{1}) || isa(varargin{1},'itaMSTF')
                % Check type of given argument and obtain the list of saved
                % properties accordingly.
                if isa(varargin{1},'itaMSTF')
                    %The save struct is obtained by using the saveobj
                    % method, as in the case in which a struct is given
                    % from the start (see if-case above).
                    if isa(varargin{1},'itaMSTFni')
                        deleteDateSaved = true;
                    else
                        deleteDateSaved = false;
                    end
                    varargin{1} = saveobj(varargin{1});
                    % have to delete the dateSaved field to make clear it
                    % might be from an inherited class
                    if deleteDateSaved
                        varargin{1} = rmfield(varargin{1},'dateSaved');
                    end
                end
                if isfield(varargin{1},'dateSaved')
                    varargin{1} = rmfield(varargin{1},'dateSaved');
                    fieldName = fieldnames(varargin{1});
                else %we have a class instance here, maybe a child
                    fieldName = fieldnames(rmfield(this.saveobj,'dateSaved'));
                end
                
                for ind = 1:numel(fieldName)
                    try
                        this.(fieldName{ind}) = varargin{1}.(fieldName{ind});
                    catch errmsg
                        disp(errmsg);
                    end
                end
            else
                error('itaMSTFni::wrong input arguments given to the constructor');
            end
            
            % Define listeners to automatically call the init function of
            % this class in case of a change in the below specified
            % properties.
            addlistener(this,'inputChannels','PostSet',@this.init_ni);
            addlistener(this,'outputChannels','PostSet',@this.init_ni);
        end
        
        function this = edit(this)
            % edit - Start GUI.
            %
            % This function calls the itaMSTFni GUI.
            
            this = ita_mstfni_gui(this);
        end
        
        function this = init_ni(this,varargin)
            % init - Initialize the itaMSTFni class object.
            % if this is an object loaded from disk (niSession is empty),
            % we do not need to re-initialize the card
            if ~isempty(this.niSession)
                this.niSession = init_NI_card(this);
            end
        end
                
        function checkready(this)
            %check if the instance is ready for measurement run and ask for
            %missing entries
            if isempty(this.inputChannels) || isempty(this.outputChannels)
                this.edit;
            end
            % has the NI session been initialized
            if isempty(this.niSession) || isempty(this.niSession.Channels)
                this.niSession = init_NI_card(this);
            end
            % has the samplingRate been changed (NI rate is not exact)
            if abs(this.niSession.Rate - this.samplingRate) > 1
                this.niSession = init_NI_card(this);
            end
            % output factor
            if isempty(this.niOutputFactor)
                this.niOutputFactor = getNIOutputFactor(this);
            end
        end
        
        function set_outputamplification(this,value)
            if ischar(value)
                value = str2num(value(~isstrprop(value,'alpha'))); %#ok<ST2NM>
            end
            if value > round(20*log10(getNIOutputFactor(this)))
                ita_verbose_info(['Warning, output cannot be adjusted to this level. Maximum is ' num2str(round(20*log10(getNIOutputFactor(this))))],1);
                value = round(20*log10(getNIOutputFactor(this)));
            end
            this.mOutputamplification = value;
        end
        
        function MS = calibrationMS(this)
            this.checkready;
            % call the parent function
            MS = calibrationMS@itaMSTF(this);
            % convert to instance of this class
            MS = itaMSTFni(MS);
            % release NI hardware to enable measurement with calibrationMS
            this.niSession.release;
        end
        
        function [result, max_rec_lvl] = run_raw(this)
            % run_raw - Run measurement
            this.checkready;
            singleprecision = strcmpi(this.precision,'single'); % Bool for single precision for portaudio.
            
            result = ita_NI_daq_run(this.final_excitation,this.niSession,'InputChannels',this.inputChannels, ...
                'OutputChannels', this.outputChannels,'repeats',1,...
                'latencysamples',this.latencysamples,'singleprecision',singleprecision);
            
            if this.outputVoltage ~= 1 % only if output is calibrated
                result.comment = [result.comment ' @' num2str(round(this.outputVoltage*1000)/1000) 'Vrms'];
            end
            max_rec_lvl = max(abs(result.timeData),[],1);
        end
        
        function [result, max_rec_lvl] = run_latency(this)
            % call parent function
            [result, max_rec_lvl] = run_latency@itaMSTF(this);
        end
        
        function this = calibrate_input(this,elementIds)
            % have to do this here because of different run function
            % do only specific elements (e.g. only AD)
            this.checkready
            if ~exist('elementIds','var')
                elementIds = 1:3;
            else
                elementIds = unique(min(3,max(1,elementIds)));
            end
            % and only active channels
            inputChannels = this.inputChannels;
            imcIdx = zeros(numel(inputChannels),1);
            for chIdx = 1:numel(inputChannels)
                imcIdx(chIdx) = find(this.inputMeasurementChain.hw_ch == inputChannels(chIdx));
            end
            tmpChain = this.inputMeasurementChain(imcIdx);
            % save IEPE settings for later
            inputIDs = [];
            isIEPE   = [];
            for iTmp = 1:numel(this.niSession.Channels)
                if contains(this.niSession.Channels(iTmp).ID,'ai')
                    inputIDs = [inputIDs str2double(this.niSession.Channels(iTmp).ID(3:end))+1]; %#ok<AGROW>
                    isIEPE   = [isIEPE contains(lower(this.niSession.Channels(iTmp).MeasurementType),'iepe')]; %#ok<AGROW>
                end
            end
            [inputIDs,sortIDs] = sort(inputIDs);
            isIEPE = isIEPE(sortIDs);
            % we need this to have the correct dimensions for the zeros at the output
            outputChannels = this.outputChannels;
            this.outputChannels = outputChannels(1);
            % element by element
            for iElement = elementIds
                for iCh = 1:numel(imcIdx)
                    if numel(tmpChain(iCh).elements) >= iElement
                        hw_ch = tmpChain(iCh).hardware_channel;
                        disp(['Calibration of sound card channel ' num2str(hw_ch)])
                        % go thru all elements of the chain and calibrate
                        if tmpChain(iCh).elements(iElement).calibrated ~= -1 % only calibratable devices
                            disp(['   Calibration of ' upper(tmpChain(iCh).elements(iElement).type) '  ' tmpChain(iCh).elements(iElement).name])
                            this.inputChannels = inputChannels(iCh);
                            if strcmpi(tmpChain(iCh).elements(iElement).type,'sensor') && isIEPE(hw_ch)
                                this.set_IEPE_channels(hw_ch);
                            end
                            [tmpChain(iCh).elements(iElement).sensitivity] = measurement_chain_elements_calibration_ni(this.niSession,tmpChain(iCh),iElement); %calibrate each element
                        end
                    end
                end
            end
            this.inputMeasurementChain(imcIdx) = tmpChain;
            this.inputChannels = inputChannels;
            this.outputChannels = outputChannels;
            this.set_IEPE_channels(inputIDs(logical(isIEPE)));
            disp('****************************** FINISHED *********************************')
        end
        
        function this = calibrate_output(this,input_chain_number)
            % have to do this here because of different run function
            % Calibrates all output chains, using only the first
            % (hopefully calibrated) input chain. Input chain calibration
            this.checkready
            if ~exist('input_chain_number','var')
                input_chain_number = find(this.inputMeasurementChain.hw_ch == this.inputChannels(1));
            end
            ita_verbose_info(['Calibrating using input channel ' num2str(this.inputMeasurementChain(input_chain_number).hardware_channel)],1);
            
            MS = this.calibrationMS;   % Get new simple Measurement Setup for calibration. See above.
            MS.inputChannels = MS.inputChannels(input_chain_number);
            mco = this.outputMeasurementChain;    % Get all output measurement chains.
            outChannels = this.outputChannels;    % Get all output channels.
            
            % The calibration of the multiple output measurement chains /
            % outout channels will be executed one-by-one.
            for outIdx = 1:numel(outChannels)
                chIdx = find(mco.hw_ch == outChannels(outIdx)); % Return single index of entry in 'mco', equal to the out channel, which is to be calibrated.
                MS.outputMeasurementChain = mco(chIdx);         % Set Measurement Setup's single output chain to match the one, which is to be calibrated.
                MS.outputChannels = outChannels(outIdx);        % Set Measurement Setup's single output channel to match the one, which is to be calibrated.
                
                % Execute calibration for every single element in the
                % current output measurement chain.
                % 'ita_mstfoutput_calibration' determines if the object can
                % be calibrated at all.
                for ele_idx = 1:length(mco(chIdx).elements)
                    MS = measurement_chain_output_calibration_ni(MS,input_chain_number,ele_idx);
                end
                
                % if there was no latency info before, copy it from the
                % calibrationMS because latency was measured in the output
                % calibration routine
                if this.latencysamples == 0
                    this.latencysamples = MS.latencysamples;
                end
                % Put the current calibrated measurement chain back into
                % its appropriate position in the list of all output
                % measurment chains.
                mco(chIdx) = MS.outputMeasurementChain;
            end
            this.outputMeasurementChain = mco;          % Copy over the list of all calibrated output measurement chains into the real Measurement Setup.
            % release hardware for the standard object
            if ~isempty(MS.niSession) % only if something was measured
                MS.niSession.release;
            end
        end
        
        function [niSession,inputChannels,outputChannels] = init_NI_card(this)
            % uses Christoph Hoellers's (hoellerc@nrc.ca) code for initilaization of NI session
            % for now only as simple DAC, so only Voltage type
            
            % Initialization
            [inputChannels,outputChannels,niDevices,rateLimits] = ita_get_ni_deviceinfo();
            if isempty(niDevices) % no card attached
                error('Cannot initialize NI card, maybe not connected?')
            end
            % create session (will be stored)
            niSession = daq.createSession('ni');
            % turn off useless warning
            warning('off','daq:Session:clockedOnlyChannelsAdded')
            
            if this.samplingRate < rateLimits(1)
                warning(['Device does not support a sampling rate of ' num2str(this.samplingRate) ', changing to lower limit of ' num2str(rateLimits(1))]);
                this.samplingRate = rateLimits(1);
            elseif this.samplingRate > rateLimits(2)
                warning(['Device does not support a sampling rate of ' num2str(this.samplingRate) ', changing to upper limit of ' num2str(rateLimits(2))]);
                this.samplingRate = rateLimits(2);
            end
            niSession.Rate = this.samplingRate;
            
            % INPUT
            % set channel data from MS
            if any(this.inputChannels > numel(inputChannels.name))
                error(['Your device does not have ' num2str(max(this.inputChannels)) ' input channels!']);
            else
                inputChannels.isActive = ismember(1:numel(inputChannels.name),this.inputChannels);
            end
            
            % Add analog input channels
            for iChannel = 1:numel(inputChannels.name)
                if inputChannels.isActive(iChannel)
                    iDevice = inputChannels.mapping{iChannel}(1);
                    iDeviceChannel = inputChannels.mapping{iChannel}(2);
                    niSession.addAnalogInputChannel(get(niDevices(iDevice),'ID'),iDeviceChannel-1,inputChannels.type{iChannel});
                    niSession.Channels(end).Name = inputChannels.name{iChannel};
                    % set to AC coupling to get rid of large DC offset
                    niSession.Channels(end).Coupling = 'AC';
                end
            end
            
            % OUTPUT
            % set channel data from MS
            if any(this.outputChannels > numel(outputChannels.name))
                error(['Your device does not have ' num2str(max(this.outputChannels)) ' output channels!']);
            else
                outputChannels.isActive = ismember(1:numel(outputChannels.name),this.outputChannels);
            end
            
            % Add analog output channels
            for iChannel = 1:numel(outputChannels.name)
                if outputChannels.isActive(iChannel)
                    iDevice = outputChannels.mapping{iChannel}(1);
                    iDeviceChannel = outputChannels.mapping{iChannel}(2);
                    niSession.addAnalogOutputChannel(get(niDevices(iDevice),'ID'),iDeviceChannel-1,outputChannels.type{iChannel});
                    niSession.Channels(end).Name = outputChannels.name{iChannel};
                end
            end
            
        end % function
        
        function this = set_IEPE_channels(this,channelIds)
            if isempty(this.niSession)
                this.niSession = this.init_NI_card();
            end
            % first get NI info
            [inputChannels,~,niDevices,~] = ita_get_ni_deviceinfo();
            
            % INPUT
            % set channel data from MS
            channelIds = intersect(channelIds,this.inputChannels);
            if isempty(channelIds)
                error('Nothing to do, maybe your channels are not active?');
            end
            
            channelIdsAll = [channelIds setdiff(this.inputChannels,channelIds)];
            isIEPE = [ones(numel(channelIds),1); zeros(numel(channelIdsAll)-numel(channelIds),1)];
            [channelIdsAll,channelSort] = sort(channelIdsAll);
            isIEPE = isIEPE(channelSort);
%             inputChannels.mapping = inputChannels.mapping(channelIds);
%             inputChannels.name = inputChannels.name(channelIds);
%             inputChannels.type = inputChannels.type(channelIds);
%             inputChannels.sensitivity = inputChannels.sensitivity(channelIds);
%             inputChannels.isActive = inputChannels.isActive(channelIds);
            
            % First remove all input channels
            for iChannel = 1:numel(channelIdsAll)
                devIdx = [];
                for iCh = 1:numel(this.niSession.Channels)
                    if strcmpi(inputChannels.name{channelIdsAll(iChannel)},this.niSession.Channels(iCh).Name)
                        devIdx = iCh;
                    end
                end
                if ~isempty(devIdx)
                    this.niSession.removeChannel(devIdx);
                else
                    error('Could not find your channel');
                end
            end
            % Then add all input channels, and turn on IEPE supply where desired
            for iChannel = 1:numel(channelIdsAll)
                % then add again
                iDevice = inputChannels.mapping{channelIdsAll(iChannel)}(1);
                iDeviceChannel = inputChannels.mapping{channelIdsAll(iChannel)}(2);
                if isIEPE(iChannel)
                    this.niSession.addAnalogInputChannel(get(niDevices(iDevice),'ID'),iDeviceChannel-1,'IEPE');
                else
                    this.niSession.addAnalogInputChannel(get(niDevices(iDevice),'ID'),iDeviceChannel-1,inputChannels.type{channelIdsAll(iChannel)});
                end
                this.niSession.Channels(end).Name = inputChannels.name{channelIdsAll(iChannel)};
            end
        end % function
        
        function outputFactor = getNIOutputFactor(this)
            % determine clipping limit from NI session information
            if isempty(this.niOutputFactor)
                outputFactor = 1; % standard
                for iChannel = 1:numel(this.niSession.Channels)
                    isOutput = ~isempty(strfind(this.niSession.Channels(iChannel).ID,'ao'));
                    if isOutput
                        outputFactor = max(outputFactor,max(abs(double(this.niSession.Channels(iChannel).Range))));
                    end
                end
                this.niOutputFactor = outputFactor;
            else
                outputFactor = this.niOutputFactor;
            end
        end % function
        
        function sObj = saveobj(this)
            % saveobj - Saves the important properties of the current
            % measurement setup to a struct.
            
            sObj = saveobj@itaMSTF(this);
            % Get list of properties to be saved for this measurement
            % class.
            propertylist = itaMSTFni.propertiesSaved;
            
            % Write the content of every item in the list of the to be saved
            % properties into its own field in the save struct.
            for idx = 1:numel(propertylist)
                sObj.(propertylist{idx}) = this.(propertylist{idx});
            end
        end
    end
    
    methods(Static, Hidden = true)
        
        function result = propertiesSaved
            % propertiesSaved - Creates a list of all the properties to be
            % saved of the current measurement setup.
            %
            % This function gets the list of all
            % properties to be saved during the saving process.
            
            % Get list of saved properties for this class.
            result = {};
        end
        
        function this = loadobj(sObj)
            % loadobj - Creates a new measurement setup and loads the
            % properties of a save struct into it.
            %
            % This function creates a new measurement setup by calling the
            % class constructor and passes it the specified save struct.
            
            this = itaMSTFni(sObj);
        end
    end
    
end % classdef
