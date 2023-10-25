classdef itaPigeonProject
    %itaPigeonProject interface class for the urban simulation
    
    properties(Access = public)
        
        
        % algorithm settings
        MaxDiffractionOrder = 1;
        MaxReflectionOrder = 1;
        MaxCombinedOrder = 2;
        OnlyNeighbouredEdgeDiffraction = false;
        DiffractionOnlyIntoShadowedEdges = false;
        FilterNotVisiblePaths = true;
        FilterEmitterToEdgeIntersectedPaths = true;
        FilterSensorToEdgeIntersectedPaths = true;
        FilterNotVisiblePointToEdge = false;

        IntersectionTestResolution = 0.001;
        NumIterations = 10;
        
        MaxAccumulatedDiffractionAngle = -6.2;
        LevelDropThreshold = -131.0;
        ReflectionPenalty = 0.97;
        DiffractionPenalty = 2.5;
        
        export_visualization = false;
        
        fixDirectPath = true;
        
        result_file_path = 'pigeon_project.json';
        geometry_file_path;
        config_file_path = 'pigeon_project.ini';
		
		runtime_stats_path = 'pigeon_project_stats.json';
		export_runtime_statistics = true;
        
        run_quiet = false;
                
    end
    
    properties(Access = public, Hidden = true)
       
        % path settings
        pigeon_exe_path;
        visualizationPaths = [];
        saveBackupConfig = false;
        
    end
    
    %% Initialization
    methods
        function obj = itaPigeonProject()
            %itaPigeonProject Construct an instance of this class
            
            pigeon_exe_path = which( 'pigeon.exe' );
            if isempty( pigeon_exe_path )
                error 'Could not locate pigeon executable, please make pigeon available in the Matlab environment'
            end
            obj.pigeon_exe_path = pigeon_exe_path;
            
        end
            
    end
    
    
    %% public functions
    methods(Access = public)
        
        function paths = run( obj, source_pos, receiver_pos )
        
            % generate Config file
            %obj.generate_config( source_pos, receiver_pos ); % old style
            obj.export_config( source_pos, receiver_pos );

            if obj.run_quiet
                be_quiet = 'quiet';
            else
                be_quiet = '';
            end
            command = sprintf( 'call "%s" "%s" %s', obj.pigeon_exe_path, obj.config_file_path, be_quiet );
            [ rcode, outp ] = system( command );
            
            if rcode == 0
                
                if ~obj.run_quiet
                	fprintf( '*** Pigeon exited successfully ***\n\n%s\n\n', outp );
                	fprintf( '*** To deactivate the output of the pigeon app, set run_quiet to ''true'' ***\n\n' );
                end
                
                if ~exist( obj.result_file_path, 'file' )
                    error( 'Result file ''%s'' has not been generated by pigeon application', obj.result_file_path )
                end

                paths = ita_propagation_load_paths( obj.result_file_path );

                if obj.fixDirectPath
                    paths = obj.fixPaths( paths );
                end
                
            else
                
                error( 'Pigeon exited with an error: \n%s\n', rcode, outp );
                
            end

        end
        
        function run_gui( obj )
            
            command = sprintf( 'call "%s"', obj.pigeon_exe_path );
            [ ~, ~ ] = system( command );
            
        end
        
        sim_result_files = run_dynamic_scenario(obj,...
            source_positions, receiver_posistions,...
            output_folder, force)
        
        function axHandle = plotPaths(this,urbanPaths,colors,axHandle)
           
            if nargin < 3
                colors = {'r','g','b','c','m','#D95319','#EDB120','#77AC30'};
            end
            
            if nargin < 4
                figure;
                axHandle = axes;
            end
            
            hold on
            for idPath=1:length(urbanPaths)

                    currentPath = urbanPaths(idPath).propagation_anchors;
                    interactionPoints=zeros(length(currentPath),3);

                    for idInteractionPoint=1:length(currentPath)
                        interactionPoints(idInteractionPoint,:) = currentPath{idInteractionPoint}.interaction_point(1:3);
                    end
                    
                    interactionType = currentPath{2}.anchor_type;                  
                    switch interactionType
                        case {'outer_edge_diffraction','inner_edge_diffraction'}
                            lineStyle = ':';
                        case 'receiver'
                            lineStyle = '-';
                        case 'specular_reflection'
                            lineStyle = '--';
                    end
                    
                    colorId = mod(idPath,numel(colors));
                    if colorId == 0
                        colorId = numel(colors);
                    end
                    currentPlot = plot3(axHandle,interactionPoints(:,1),interactionPoints(:,2),interactionPoints(:,3),...
                        lineStyle,'Color',colors{colorId},'LineWidth',2);
                    uistack(currentPlot, 'bottom');   

                    % make sure axis ratios are set correctly
                    span = max(round(max(interactionPoints(:,1))-min(interactionPoints(:,1))),1);
                    xRange = round([min(interactionPoints(:,1)),min(interactionPoints(:,1))+span]);
                    yRange = round([min(interactionPoints(:,2)),min(interactionPoints(:,2))+span]);
                    zRange = round([min(interactionPoints(:,3)),min(interactionPoints(:,3))+span]);

                    set(axHandle,'xLim',xRange)
                    set(axHandle,'yLim',yRange)
                    set(axHandle,'zLim',zRange)
                    axis equal
                    xlabel(axHandle,'x [m]')
                    ylabel(axHandle,'y [m]')
                    zlabel(axHandle,'z [m]')
                    set(axHandle,'xGrid','on')
                    set(axHandle,'yGrid','on')
                    set(axHandle,'zGrid','on')
            end
            
        end
    end
    
    %% private functions
    methods(Access = private)
        
        generateConfig(obj,sourcePosition,receiverPosition)
        
    end
    
    %% hidden functions
        
    methods(Access = public, Hidden = true)
        function outPaths = fixPaths(~,inPaths)
            
            outPaths = inPaths;
            tmpPropagationAnchors = cell(2,1);
            for idPath = 1:numel(inPaths)
                if numel(inPaths(idPath).propagation_anchors) == 2
                    outPaths(idPath).class = inPaths(idPath).class;
                    outPaths(idPath).identifier = inPaths(idPath).identifier;
                    tmpPropagationAnchors{1,1} = inPaths(idPath).propagation_anchors(1);
                    tmpPropagationAnchors{2,1} = inPaths(idPath).propagation_anchors(2);
                    outPaths(idPath).propagation_anchors = tmpPropagationAnchors;
                end
            end
            
        end
    end
end

