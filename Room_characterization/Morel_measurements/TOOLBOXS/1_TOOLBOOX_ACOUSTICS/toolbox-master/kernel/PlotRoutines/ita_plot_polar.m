function lineHandle = ita_plot_polar(varargin)
%ITA_PLOT_POLAR - plot a polar pattern, linear or in dB
%  This function plots the polar pattern using the dirplot routine which
%  extends the matlab polar routine to enable negative values in polar
%  plots
%   
%
%  Syntax:
%   ita_plot_polar(itaSuper, double, options)
%
%   Options (default):
%           'plotDomain' ('freq')      : in which domain to plot
%           'plotPlane' ('xy')         : cut through a plane from spherical data
%           'plotType' ('mag')         : how to plot the data (linear,mag,phase)
%           'plotRange' ([])           : dynamic range of the plot
%           'plotCoord' ('polar')      : define plot type
%                                        'polar' -> polar coordinates
%                                        'cart'  -> Cartesian coordinates
%           'newFigure' (true)         : whether to open a new figure
%           'normalize' (false)        : set maximum to 0 dB (linear 1)
%           'plotFunction'('polarplot'): use matlab function 'polarplot' or
%                                        old ita-function  'dirplot' for
%                                        polar plots
%
%  Example:
%   audioObjOut = ita_plot_polar(audioObjIn)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_plot_polar">doc ita_plot_polar</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

%  *dirplot modified in January 2014, jonas.tumbraegel@rwth-aachen.de
%   (Bugfix: Rho-values outside plotRange do not produce wrong plots
%   anymore)

% Author: Markus Mueller Trapet -- Email: mmt@akustik.rwth-aachen.de
% Created:  31-May-2011
% Modified: 09-Jan-2014 ('plotCoord' - tumbraegel)


%% Get Function String
thisFuncStr  = [upper(mfilename) ':'];     %Use to show warnings or infos in this functions

%% Initialization and Input Parsing
sArgs                       = struct('pos1_data',        'itaSuper',...
                                     'pos2_plotInstant', 'double',  ...
                                     'plotDomain',       'freq',    ...
                                     'plotPlane',        'xy',      ...
                                     'plotType',         'mag',     ...
                                     'plotRange',        [],        ...
                                     'plotCoord',        'polar',   ...
                                     'newFigure',        true,      ...
                                     'normalize',        false,     ...
                                     'nTicks',           5,         ...
                                     'lineStyle',        '-',       ...
                                     'plotFunction',     'polarplot',...
                                     'clipData',         false);
[input,frequencyPlot,sArgs] = ita_parse_arguments(sArgs,varargin);

%% input data processing
if isempty(input.channelCoordinates) && ~any(isnan(input.channelCoordinates.theta))
    error([thisFuncStr 'could not find coordinates, need those for plotting']);
end

theta       = input.channelCoordinates.theta.*180/pi;
phi         = input.channelCoordinates.phi.*180/pi;
thetaRes    = median(diff(unique(round(10.*theta).*0.1)));
phiRes      = median(diff(unique(round(10.*phi).*0.1)));
uniqueUnits = unique(input.channelUnits);
if numel(uniqueUnits) > 1
    uniqueUnits = uniqueUnits(1);
end

[refStr, refValue, refLogPrefix] = itaValue.log_reference(uniqueUnits);
if isnan(thetaRes) || thetaRes == 0
    thetaRes = 1;
end
if isnan(phiRes) || phiRes == 0
    phiRes = 1;
end

switch lower(sArgs.plotPlane)
    % find the correct cut through the sphere
    case 'xy'
        % means theta = 90
        thetaVal    = 90;
        phiVal      = [];
        signVals    = 1;
    case 'yz'
        thetaVal    = [];
        phiVal      = [90,270];
        signVals    = [1, -1];
    case 'xz'
        thetaVal    = [];
        phiVal      = [0,180];
        signVals    = [1, -1];
    otherwise
        error([thisFuncStr 'unknown plot type']);
end

tmpFreqData     = eval(['input.' sArgs.plotDomain '2value(' num2str(frequencyPlot) ');']);
angles          = [];
plotData        = [];

% Extract data and angles to plot.
% only one can be empty
if ~isempty(thetaVal)
    for iTheta = 1:numel(thetaVal)
        idxPlotData = find(abs(theta - thetaVal(iTheta)) <= thetaRes*0.4);
        if ~isempty(idxPlotData)
            [tmpAngles,idxAngles] = sort(mod(input.channelCoordinates.phi_deg(idxPlotData),360));
            angles                = [angles; tmpAngles.*signVals(iTheta)]; %#ok<AGROW>
            tmp                   = tmpFreqData(idxPlotData);
            plotData              = [plotData, tmp(idxAngles)]; %#ok<AGROW>
        else
            error([thisFuncStr 'no appropriate values found, could not create plot']);
        end
        angles(angles > 180) = mod(angles(angles > 180),180) - 180;  
    end
else
    for iPhi = 1:numel(phiVal)
        idxPlotData = find(abs(phi - phiVal(iPhi)) <= phiRes*0.4); %jtu: magic number 0.4?
        if ~isempty(idxPlotData)
            [tmpAngles,idxAngles]  = sort(input.channelCoordinates.theta_deg(idxPlotData));
            angles                 = [angles; tmpAngles.*signVals(iPhi)]; %#ok<AGROW>
            tmp                    = tmpFreqData(idxPlotData);
            plotData               = [plotData, tmp(idxAngles)]; %#ok<AGROW>
        else
            error([thisFuncStr 'no appropriate values found, could not create plot']);
        end
    end
end

[angles,idxAngles] = sort(angles);
plotData           = plotData(idxAngles);
% in order to get gapless data
angles             = [angles(:); angles(1)];
plotData           = [plotData(:); plotData(1)];

% Prepare plotdata for
if strcmpi(sArgs.plotDomain,'freq')
    if strcmpi(sArgs.plotType,   'mag')
        yTitle = 'dB';
        if sArgs.normalize
            plotData = plotData./max(abs(plotData(:)));
            refValue = 1;
        else
            if ~isempty(uniqueUnits{1})
                yTitle = [yTitle, ' re ', refStr];
            end
        end
        plotData = refLogPrefix.*log10(abs(plotData)./refValue);
    elseif strcmpi(sArgs.plotType,'linear')
        yTitle = '';
        if sArgs.normalize
            plotData = plotData./max(abs(plotData(:)));
        else
            yTitle   = uniqueUnits{1};
        end
        if ~all(isreal(plotData))
            ita_verbose_info('values are complex => plotting absolute value',0)
            plotData = abs(plotData);
        end
    elseif strcmpi(sArgs.plotType,'phase')
        yTitle    = 'deg';
        plotData  = unwrap(angle(plotData)).*180/pi;
        if sArgs.normalize
            plotData = plotData - max(plotData);
        end
    end
end
if ~all(isreal(plotData))
    plotData = abs(plotData);
end

%% plot it
if sArgs.newFigure
   figure('Name','Polar plot');
end
% Determine Plot Range
if isempty(sArgs.plotRange)
    maxVal = max(plotData(:));
    minVal = min(plotData(:));
    if strcmpi(sArgs.plotType,'mag') %if mag and no plotRange given, find a suitable one
        maxVal = ceil(maxVal*0.2)*5;
        minVal = floor(minVal*0.2)*5;
    end
else
    maxVal = max(sArgs.plotRange);
    minVal = min(sArgs.plotRange);
    if sArgs.clipData
        plotData(plotData<minVal) = minVal;
        plotData(plotData>maxVal) = maxVal;
    end
end

if (strcmpi(sArgs.plotCoord, 'polar'))
    switch sArgs.plotFunction
        case 'polarplot'
            %polarplot reflects negative values at the origin, to get
            %better match for db data with a ring a zero line, offset data
            %accordingly
            
            %first update all plots to new limits if there are any
            existingLineHandles = findall(gca,'type','line');
            if ~isempty(existingLineHandles)
                currTicks = str2num(get(gca,'RTickLabel'));
                minVal = min(minVal,min(currTicks));
                maxVal = max(maxVal,max(currTicks));
                existingLineHandles = findall(gca,'type','line');
                for iExistingLine = 1:numel(existingLineHandles)
                    existingLineHandles(iExistingLine).RData = existingLineHandles(iExistingLine).RData+min(currTicks)-minVal;
                end
            end
            
            %make new plots
            lineHandle = polarplot(deg2rad(angles(:)),plotData(:)-minVal);
            
            %update Ticks to allow negative ticks
            rTicks = round(linspace(minVal,maxVal,sArgs.nTicks)-minVal);
            if sign(maxVal)*sign(minVal)<0
                %data contains 0
                offset = rTicks(min(abs(rTicks+minVal)) == abs(rTicks+minVal))+minVal;
                rTicks = rTicks-offset;
            end
            set(gca,'RTick',rTicks,...
                'RTickLabel',rTicks+minVal,...
                'RLim',[minVal,maxVal]-minVal)
            
        
        case 'dirplot'
        lineHandle = dirplot(angles(:),plotData(:),sArgs.lineStyle,[double(maxVal) double(minVal) sArgs.nTicks],yTitle);
        otherwise
            error('unknown ''plotFunction'' parameter. Use ''polarplot'' or ''dirplot''!')
    end
    
    
elseif (strcmpi(sArgs.plotCoord,'cart'))
    lineHandle = plot(angles(:),plotData(:),sArgs.lineStyle);
    set(gca,...
        'YLim', [minVal maxVal],...
        'XTick', -180:30:180,...
        'YTick', minVal:(abs(minVal)+abs(maxVal))/sArgs.nTicks:maxVal)
    %  'XLim', [-180 180],...
    xlabel('Degrees')
else
    error(['''' sArgs.plotCoord '''' ' is no appropriate string for ''' 'plotCoord' ''', could not create plot']);
end

set(lineHandle,'LineWidth',ita_preferences('linewidth'));
if strcmpi(sArgs.plotDomain,'freq')
    unitStr = 'Hz';
else
    unitStr = 's';
end
title(['Polar pattern at ' num2str(frequencyPlot) ' ' unitStr]);
end