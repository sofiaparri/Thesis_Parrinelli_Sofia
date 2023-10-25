function [pos] = ita_setup_LS_15Design120Points(varargin)
%ITA_SETUP_15DESIGN120POINTS Spherical 15 Design with 120 sampling points
% Obtained from:
%   http://neilsloane.com/sphdesigns/index.html#REF, Accessed 20.03.2019, 20:22
%   Files: http://neilsloane.com/sphdesigns/dim3/
%
% Author: Lukas Vollmer (lvo@akustik.rwth-aachen.de)
% Date: 2022-01-28
% 

%% Parse input
opts.coordSystem   = 'itaCoordinates'; % 'openGL'  | output in Matlab or OpenGL coordinate system
opts = ita_parse_arguments(opts, varargin);

pos = itaCoordinates(120);
pos.r = ones(120, 1);
pos.theta = [1.44961890733970;0.546469278386454;1.44937795253671;2.10061261796501;2.59506513570223;1.04099802174305;0.546658539962161;2.10084171719842;2.59499241813932;1.04073187354927;1.69208895655693;1.69209826764377;1.96660853320229;1.83892851481352;1.96688632932254;0.486873015520503;1.30276487906644;2.65460878073244;1.83870626450933;0.486843292863263;1.30278941244214;2.65486088687080;1.17494479433948;1.17474439746253;1.54651231515768;2.91012352885007;1.54670028996284;1.34071361835595;0.231442680343542;1.80088292676004;2.91001611394592;1.34046058374911;0.231603192955134;1.80112926340427;1.59494953788556;1.59502385066720;0.731069276574945;1.39338626800667;0.730793351057546;2.27035306036688;1.74801794540488;0.871369731284917;1.39366142580276;2.27027901451375;1.74811771120009;0.871181678811254;2.41055780733805;2.41076368313382;1.10735059543730;2.13922445048476;1.10723246766642;2.36656287873574;1.00223869898807;0.775116308141392;2.13946981109997;2.36628449069178;1.00225630662825;0.775222519339173;2.03416126082013;2.03444078144620;1.04081597510857;2.59489083756790;1.04091524334228;1.69223516351925;0.546457617080266;1.44942505696707;2.59516603520399;1.69195240824138;0.546668963853692;1.44957116507456;2.10064446049854;2.10081182263223;1.39349394025923;0.730964809342622;1.39355408833379;0.871169584464265;2.41056443975453;2.27045297631345;0.730899867653183;0.871381354007429;2.41075883650794;2.27017850167244;1.74819978410913;1.74793662599947;1.59485015762068;1.80107649551599;1.59512429139530;0.231639400781271;1.34052254735493;2.90993836638018;1.80093573484024;0.231405965281234;1.34065113318919;2.91020131443575;1.54671217601732;1.54650012498998;2.03428037711349;0.775300403845885;2.03432111019705;1.00210537317870;2.36645097036633;2.13941607108169;0.775038295956086;1.00238788257125;2.36639619136625;2.13927602228521;1.10741914659749;1.10716356604609;1.17474455826010;2.65467007695746;1.17494415111862;1.30291820092365;0.486717413035736;1.83872852159264;2.65479952930684;1.30263524775525;0.486998734094879;1.83890377866793;1.96671777439059;1.96677632346324];
pos.phi = [5.74906127893317;2.90696109376868;2.60748562710976;1.43030287921946;0.235337320266768;4.85327248749463;6.04820703093500;4.57179710152163;3.37648052264666;1.71162273041650;0.534446888935124;3.67600565177237;1.86209096082410;5.87188592394718;5.00365922780556;3.74370656243510;3.55326741902170;2.53992733060941;2.73024617515890;0.601580656517075;0.411598034942413;5.68176658151639;4.42146387819671;1.27978725144657;2.91147354821113;0.106319327956794;6.05306116341523;4.73740761221167;3.03663334536858;1.54612385098692;3.24679773853439;1.59578432434119;6.17723612656873;4.68768344013297;3.37202370942786;0.230437850961158;4.97991365266325;2.28395261889783;1.83825060986895;0.232831701887872;0.857982579116258;6.05069116696433;5.42553510075621;3.37419626632956;3.99952872454268;2.90927538337522;1.30372462455157;4.44509898723012;4.06670947189605;2.58245524204585;0.924988173565294;5.40556426935500;0.559316646937388;0.877823394231985;5.72413469445008;2.26391536089615;3.70108890618557;4.01968359844008;2.21684442665291;5.35845741695003;3.28252510919303;1.80596749031449;0.140778067284669;5.24682074446344;1.33583516949692;1.03666618632069;4.94744090445984;2.10522613629687;4.47773793722319;4.17828886951453;3.00098529821908;6.14270919534017;0.713126708715045;0.267336819877962;3.85476886934645;1.33831095065092;2.87429896918697;4.94507457428733;3.40923655597397;4.48006161697885;6.01611849757452;1.80354363256831;5.57035798632524;2.42874734190333;1.80123245331434;6.25852461481836;4.94282371068065;4.60727475151678;3.16662433054747;1.67678659887031;3.11687427327910;1.46500198188040;0.0249725339849962;4.81792308295772;4.48227065038638;1.34067299753081;0.646127475842844;5.59029214697667;3.78758069590356;2.13020855188405;3.83459915291363;4.15321576829886;2.44880820388614;5.27178817506990;0.693289711505180;1.01178061527128;5.63741113882101;2.49587751542082;2.85066594245593;0.969494160367782;5.99217555801795;5.12402891181407;2.17267363650169;1.15950333799901;4.11060924080092;1.98242944459820;5.31420886641181;4.30103543102226;3.43281707746866;0.291339411925468];

%% Convert to OpenGL
if strcmpi(opts.coordSystem, 'openGL')
    pos = ita_matlab2openGL(pos);
end

end
