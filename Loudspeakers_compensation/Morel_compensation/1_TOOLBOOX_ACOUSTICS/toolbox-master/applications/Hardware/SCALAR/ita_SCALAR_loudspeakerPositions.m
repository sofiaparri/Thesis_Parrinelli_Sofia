function varargout = ita_SCALAR_loudspeakerPositions(varargin)
%ITA_SCALAR_LOUDSPEAKERPOSITIONS - Loudspeakerpositions in the SCALAR array
%  This function ++++ FILL IN INFO HERE +++
%
%  Syntax:
%   audioObjOut = ita_SCALAR_loudspeakerPositions()
%
%   Options (default):
%           'type' ('ideal'),'measured' : get the ideal equal area
%           positions or the results from an actual measurement by FPA
%           using Optitrack ('measured')
%
%  Example:
%   positions = ita_SCALAR_loudspeakerPositions();
%   positions = ita_SCALAR_loudspeakerPositions('type','measured')
%
%  See also:
%   ita_SCALAR_measureHRTF.m
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_SCALAR_loudspeakerPositions">doc ita_SCALAR_loudspeakerPositions</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>


% Author: Hark Braren -- Email: hark.braren@akustik.rwth-aachen.de
% Created:  25-Jun-2021




%% Initialization and Input Parsing
sArgs   = struct('type','ideal');
sArgs   = ita_parse_arguments(sArgs,varargin);
                    %x        %y        %z
idealPositions = [ -0.0000   -0.0000    1.3500;...  %1
                    0.2063   -0.5186    1.2292;...   
                    0.5522   -0.0806    1.2292;...
                    0.3460    0.4379    1.2292;...
                   -0.2063    0.5186    1.2292;...  %5
                   -0.5522    0.0806    1.2292;...
                   -0.3460   -0.4379    1.2292;...
                    0.0628   -0.9727    0.9341;...
                    0.6225   -0.7500    0.9341;...
                    0.9445   -0.2409    0.9341;...  %10
                    0.9057    0.3603    0.9341;...
                    0.5209    0.8238    0.9341;...
                   -0.0628    0.9727    0.9341;...
                   -0.6225    0.7500    0.9341;...
                   -0.9445    0.2409    0.9341;...  %15
                   -0.9057   -0.3603    0.9341;...
                   -0.5209   -0.8238    0.9341;...
                   -0.0704   -1.2467    0.5131;...
                    0.5171   -1.1366    0.5131;...
                    0.9860   -0.7661    0.5131;...  %20
                    1.2291   -0.2201    0.5131;...
                    1.1906    0.3763    0.5131;...
                    0.8794    0.8865    0.5131;...
                    0.3667    1.1936    0.5131;...
                   -0.2300    1.2273    0.5131;...  %25
                   -0.7740    0.9798    0.5131;...
                   -1.1407    0.5079    0.5131;...
                   -1.2461   -0.0804    0.5131;...
                   -1.0660   -0.6503    0.5131;...
                   -0.6417   -1.0712    0.5131;...  %30
                   -0.1411   -1.3426         0;...
                    0.4172   -1.2839         0;...
                    0.9033   -1.0032         0;...
                    1.2333   -0.5491         0;...
                    1.3500         0         0;...  %35 
                    1.2333    0.5491         0;...
                    0.9033    1.0032         0;...
                    0.4172    1.2839         0;...
                   -0.1411    1.3426         0;...
                   -0.6750    1.1691         0;...  %40
                   -1.0922    0.7935         0;...
                   -1.3205    0.2807         0;...
                   -1.3205   -0.2807         0;...
                   -1.0922   -0.7935         0;...
                   -0.6750   -1.1691         0;...  %45
                   -0.0302   -1.2483   -0.5131;...
                    0.5534   -1.1194   -0.5131;...
                    1.0102   -0.7340   -0.5131;...
                    1.2356   -0.1804   -0.5131;...
                    1.1779    0.4145   -0.5131;...  %50
                    0.8504    0.9144   -0.5131;...
                    0.3280    1.2048   -0.5131;...
                   -0.2694    1.2193   -0.5131;...
                   -0.8052    0.9544   -0.5131;...
                   -1.1565    0.4709   -0.5131;...  %55
                   -1.2429   -0.1205   -0.5131;...
                   -1.0445   -0.6843   -0.5131;...
                   -0.6068   -1.0913   -0.5131;...
                    0.1408   -0.9645   -0.9341;...
                    0.6808   -0.6975   -0.9341;...  %60
                    0.9608   -0.1641   -0.9341;...
                    0.8737    0.4320   -0.9341;...
                    0.4530    0.8630   -0.9341;...
                   -0.1408    0.9645   -0.9341;...
                   -0.6808    0.6975   -0.9341;...  %65
                   -0.9608    0.1641   -0.9341;...
                   -0.8737   -0.4320   -0.9341;...
                   -0.4530   -0.8630   -0.9341];
%                         x        y         z
measuredPositions = [   0.0296         0    1.2942;...
                        0.1807   -0.5113    1.2229;...
                        0.5370   -0.0623    1.2170;...
                        0.3185    0.4358    1.2371;...
                       -0.2208    0.5193    1.2293;...  %5
                       -0.5701    0.0647    1.2293;...
                       -0.3208   -0.4596    1.2184;...
                        0.0905   -0.9722    0.8851;...
                        0.6205   -0.7366    0.9040;...
                        0.9528   -0.2363    0.8822;...  %10
                        0.9338    0.3315    0.9020;...
                        0.5601    0.8415    0.9011;...
                       -0.0441    0.9959    0.9010;...
                       -0.6396    0.7351    0.9288;...
                       -0.9489    0.2036    0.9267;...  %15
                       -0.9274   -0.3797    0.8828;...
                       -0.4906   -0.8453    0.8982;...
                       -0.0903   -1.2392    0.4344;...
                        0.5045   -1.1338    0.4640;...
                        0.9430   -0.7203    0.4473;...  %20
                        1.2346   -0.2130    0.4864;...
                        1.2027    0.3764    0.4924;...
                        0.9059    0.8949    0.4678;...
                        0.3660    1.2149    0.4495;...
                       -0.2403    1.2318    0.4548;...  %25
                       -0.7534    0.9150    0.4482;...
                       -1.1258    0.4823    0.4363;...
                       -1.2654   -0.1072    0.4331;...
                       -1.0497   -0.6901    0.4629;...
                       -0.6134   -1.0894    0.4646;...  %30
                       -0.1315   -1.3158   -0.0426;...
                        0.4040   -1.2651   -0.0000;...
                        0.8863   -1.0308   -0.0320;...
                        1.2708   -0.5692   -0.0360;...
                        1.3924    0.0198   -0.0234;...  %35
                        1.2171    0.5288   -0.0091;...
                        0.8573    0.9870    0.0262;...
                        0.3846    1.2526    0.0094;...
                       -0.1206    1.3415    0.0265;...
                       -0.6842    1.2115    0.0191;...  %40
                       -1.1077    0.8263    0.0061;...
                       -1.3575    0.3020   -0.0104;...
                       -1.3314   -0.3137   -0.0042;...
                       -1.0740   -0.7990   -0.0392;...
                       -0.6679   -1.1539   -0.0511;...  %45
                       -0.0628   -1.2295   -0.5417;...
                        0.5537   -1.1023   -0.5472;...
                        1.0499   -0.7389   -0.4998;...
                        1.2940   -0.1677   -0.4862;...
                        1.1744    0.4375   -0.4791;...  %50
                        0.8247    0.9244   -0.4951;...
                        0.3380    1.1603   -0.5177;...
                       -0.2741    1.2192   -0.4981;...
                       -0.8426    0.9872   -0.4852;...
                       -1.1884    0.5032   -0.4726;...  %55
                       -1.2478   -0.1080   -0.5355;...
                       -1.0416   -0.6534   -0.5323;...
                       -0.6226   -1.0607   -0.5486;...
                        0.1506   -0.9381   -0.9699;...
                        0.6855   -0.6652   -0.9571;...  %60
                        0.9962   -0.1217   -0.9463;...
                        0.8454    0.4245   -0.9525;...
                        0.4082    0.8082   -0.9965;...
                       -0.1240    0.8984   -0.9716;...
                       -0.6711    0.7095   -0.9528;...  %65
                       -0.9648    0.1901   -0.9410;...
                       -0.8971   -0.4204   -0.9408;...
                       -0.4688   -0.8309   -0.9750];

path = fileparts(mfilename('fullpath'));

switch sArgs.type
    case 'ideal'
        positions = itaCoordinates(idealPositions,'cart');
    case 'measured'
        positions = itaCoordinates(measuredPositions,'cart');
%     case 'withAdditional'
% 
%         positions = itaCoordinates([idealScalarSampling; additional_speakers],'cart');
    otherwise
        ita_verbose_info('Unkown type -> returning ideal positions.',0)
        load(fullfile(path,'idealScalarSampling.mat'),'idealScalarSampling');
        positions = idealScalarSampling;
end



%% Set Output
varargout(1) = {positions};

%end function
end