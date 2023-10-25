function varargout = surf(this, data, varargin)

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% This function plots the surface of an itaCoordinates object c (or of one of
% its children). The second input 'data' determines the surface's colour
% scheme. This could be for example the radius data.  
% If the radius information is complex, it is regarded as a complex plot,
% and the color is used to denote the phases.
%
% The plop parameter (see options) can be used for a upper limit of how much crazy
% shaped triangulas will exist. A plop of 1 means only plot faces
% that have smaller deformation as average. A factor of 4 makes sense for
% most plots. Default is without plop (runs faster).
%
% All properties of the MATLAB built-in "Patch Properties" can be used.
%
% Syntax:
%       surf(c, data)
%           plots the itaCoordinate object c
%       surf(c, data, options)
%           certain options (see below) can be set
%       surf(c,r,color,'plop', 1, [optional parameter of built-in surf])
%           opens the large triangles
%           (other parameters are passed to the built-in surf function)

% Options (default):
%       'radius'    []      - sphere's radius
%       'magnitude' (false)   - takes absolute value of data 
%       'parent'    []
%       'complex' (false)   - indicates if data is complex
%       'colorbar'  (true)  - use colorbar scale
%       'plop'      [] - regulation of triangle shapes 
%       'hull'      [] - regulates shape's hull
%             
% Author:
%   Martin Pollow, mpo@akustik.rwth-aachen.de, 4.1.2010

sArgs             = struct('pos1_data','double', ...
                           'radius', [], ...
                           'magnitude', 0, ... 
                           'parent', [], ...
                           'complex', false, ...
                           'colorbar', true,...
                           'plop', [],...
                           'hull', []);

[data,sArgs] = ita_parse_arguments(sArgs, [data, varargin]); 

if sArgs.magnitude
    data = abs(data);
end

%% now set radius and color according to the input variables
% set radius
if ~isempty(sArgs.radius)
    r = sArgs.radius;
else
    r = data.';
end

% set colour - there are three options for the colorbar settings:
% geometry / complex / magnitude
isComplex = ~all(isreal(r)) || sArgs.complex;
if isComplex
    if sArgs.complex && ~isempty(sArgs.radius)
        color = mod(data,2*pi);
    else
        % if the radius is complex, set the color
        color = mod(angle(r),2*pi);
    end
    colorbar_settings = 'complex';
else
    % if it is real, use the magnitude as color
    color = r;
    %         ita_verbose_info('itaCoordinates.surf is plotting negative radius, take care',0);
    colorbar_settings = 'magnitude';
end
r = abs(r);

if ~isempty(sArgs.radius) && ~sArgs.complex
    % if a color is given explicitly
    % negative radii are set to 0
    if sum(abs(imag(r))) > 0, ita_verbose_info('ignoring imaginary part of radius'); end
    r = max(real(r),0);
    color = data.';
    % use the magnitude of complex data
    if ~all(isreal(color))
        color = abs(color);
    end

    colorbar_settings = 'magnitude';
end

% define how big the patches can get
if ~isempty(sArgs.plop) 
    maxAreaVertex = sArgs.plop;
else
    maxAreaVertex = 0;
end


% set a hull 
if ~isempty(sArgs.hull) 
    hull = sArgs.hull;
    if any(size(hull,2) ~= 3)
        error('something wrong with the hull in itaCoordinates.surf');
    end
else
    % use unity radius to create triangularisation
    this.r = 1;
    % do triangularisation and then use the old radius again
    dt = DelaunayTri(this.cart);
    % check for duplicate data points
    if size(dt.X,1) ~= size(this.cart,1)
        ita_verbose_info('Duplicate data points detected, some points will be ignored.',0);
        % look for double points and use the first one
        indexOfUsedPoints = zeros(size(dt.X,1),1);
        for ind = 1:numel(indexOfUsedPoints)
            indexOfUsedPoints(ind) = find(all(bsxfun(@minus, this.cart, dt.X(ind,:)) == 0,2),1,'first');
        end
        this.cart = this.cart(indexOfUsedPoints,:);
        if (length(r) ~= 1)
            r = r(indexOfUsedPoints,:);
        end
        color = color(indexOfUsedPoints,:);
    end
    hull = dt.convexHull;
end

this.r = r;

% destroy the patches witch are too large
if maxAreaVertex > 0
    % copy the balloon and set r to unity
    s_tmp = this;
    s_tmp.r = 1;
    
    % calculate the midpoint of the triangles
    meanX = sum(s_tmp.x(hull),2)/3;
    meanY = sum(s_tmp.y(hull),2)/3;
    meanZ = sum(s_tmp.z(hull),2)/3;
    
    verformungsgrad = ...
        sum(bsxfun(@minus,s_tmp.x(hull),meanX).^2,2) + ...
        sum(bsxfun(@minus,s_tmp.y(hull),meanY).^2,2) + ...
        sum(bsxfun(@minus,s_tmp.z(hull),meanZ).^2,2);
    meanVer = verformungsgrad ./ mean(verformungsgrad,1);
    hull = hull(meanVer <= maxAreaVertex,:);
    clear s_tmp
end

% plot the surface
if sArgs.parent ~= 0
    hFig = trisurf(hull, this.x, this.y, this.z,'Parent',sArgs.parent);
else
    hFig = trisurf(hull, this.x, this.y, this.z);   
end
% jri: matlab 2014b interpolation changed: interpolation between cvalues
% leads to breaks in plot: set rgbValues only in complex plots
if (strcmp(colorbar_settings,'complex'))
    rgbValues = mapCDataToRGB(color);
    set(hFig, 'FaceVertexCData', squeeze(rgbValues));
else
    set(hFig, 'FaceVertexCData', color(:));
end
set(gca,'SortMethod','depth'); % replaced set(gca,'DrawMode','fast'); % this avoids a MATLAB segfault (?? only for renderer painters)
set(hFig);

switch colorbar_settings
    case 'geometry'
        % do nothing
    case 'complex'
        colormap(hsv)
        if sArgs.colorbar
            colorbar;
        end
        caxis([0 2*pi]);
    case 'magnitude'
        colormap jet
%         caxis([0 max(color)]);
        if min(color) < max(color)
            caxis([min(color) max(color)]);
            if sArgs.colorbar
                colorbar;
            end
        elseif all(isfinite(color))
            caxis([0 max(color)]);
        else
            ita_verbose_info('itaCoordinates.surf: strange color axis',0)
        end
    otherwise
        error('You shouldnt get here...')        
end

xlabel('X');
ylabel('Y');
zlabel('Z');
axis equal vis3d
if nargout
    varargout = {hFig};
else
    varargout = {};
end
end

function rgbValues = mapCDataToRGB(cdata)
    map = colormap(hsv);
    cmin = 0;
    cmax = 2*pi;
    cm_length = length(map);
    % use the same interpolation as the original surf (scaled mapping)
    % http://de.mathworks.com/help/matlab/visualize/coloring-mesh-and-surface-plots.html?nocookie=true
    colormap_index = fix((cdata-cmin)/(cmax-cmin)*cm_length)+1;
    rgbValues = ind2rgb(colormap_index,map);
end