% 
%  OpenDAFF - A free, open-source software package for directional audio data,
%             distributed under the terms of the GNU Lesser Public License (LGPL)
%              
%  (c) Copyright Institute of Technical Acoustics, RWTH Aachen University
%   
%  File:	generateExampleDirectivities.m
%  Purpose:	Matlab script that generates a set of example directivities
%           for testing, debugging and playing around
%  Authors:	Frank Wefers (Frank.Wefers@akustik.rwth-aachen.de)
%
%  $Id: generateExampleDirectivities.m,v 1.4 2010/03/04 13:49:26 fwefers Exp $
%

% <ITA-Toolbox>
% This file is part of the application openDAFF for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Export in 5�x5� resolution
alpha_res = 5;
beta_res = 5;
channels = 1;
orient = [0 0 0];


daffv15_write('filename', '../MS Frontal dirac.daff', ...
           'content', 'ms', ...
           'datafunc', @dfFrontalDiracMS, ...
           'channels', channels, ...
           'alphares', alpha_res, ...
           'betares', beta_res, ...
           'orient', orient);
       
daffv15_write('filename', '../MS Frontal hemisphere.daff', ...
           'content', 'ms', ...
           'datafunc', @dfFrontalHemisphereMS, ...
           'channels', channels, ...
           'alphares', alpha_res, ...
           'betares', beta_res, ...
           'orient', orient);
       
daffv15_write('filename', '../MS Upper hemisphere.daff', ...
           'content', 'ms', ...
           'datafunc', @dfUpperHemisphereMS, ...
           'channels', channels, ...
           'alphares', alpha_res, ...
           'betares', beta_res, ...
           'orient', orient);
       
daffv15_write('filename', '../MS Omnidirectional.daff', ...
           'content', 'ms', ...
           'datafunc', @dfOmnidirectionalMS, ...
           'channels', channels, ...
           'alphares', alpha_res, ...
           'betares', beta_res, ...
           'orient', orient);
       
daffv15_write('filename', '../MS Dipole.daff', ...
           'content', 'ms', ...
           'datafunc', @dfDipoleMS, ...
           'channels', channels, ...
           'alphares', alpha_res, ...
           'betares', beta_res, ...
           'orient', orient);
       
daffv15_write('filename', '../MS Quadrupole.daff', ...
           'content', 'ms', ...
           'datafunc', @dfQuadrupoleMS, ...
           'channels', channels, ...
           'alphares', alpha_res, ...
           'betares', beta_res, ...
           'orient', orient);
       
daffv15_write('filename', '../MS Star.daff', ...
           'content', 'ms', ...
           'datafunc', @dfStarMS, ...
           'channels', channels, ...
           'alphares', alpha_res, ...
           'betares', beta_res, ...
           'orient', orient); 
       
daffv15_write('filename', '../MS Disc.daff', ...
           'content', 'ms', ...
           'datafunc', @dfDiscMS, ...
           'channels', channels, ...
           'alphares', alpha_res, ...
           'betares', beta_res, ...
           'orient', orient); 

daffv15_write('filename', '../MS Cube.daff', ...
           'content', 'ms', ...
           'datafunc', @dfCubeMS, ...
           'channels', channels, ...
           'alphares', alpha_res, ...
           'betares', beta_res, ...
           'orient', orient);   

daffv15_write('filename', '../MS Bulb.daff', ...
           'content', 'ms', ...
           'datafunc', @dfBulbMS, ...
           'channels', channels, ...
           'alphares', alpha_res, ...
           'betares', beta_res, ...
           'orient', orient); 
       
daffv15_write('filename', '../MS Thin Belt.daff', ...
           'content', 'ms', ...
           'datafunc', @dfOmnidirectionalMS, ...
           'channels', channels, ...
           'alphares', alpha_res, ...
           'betares', beta_res, ...
           'orient', orient, ...
           'betarange', [80 100]);