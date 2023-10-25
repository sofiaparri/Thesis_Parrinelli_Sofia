function test_ita_loudness_timevariant()

% <ITA-Toolbox>
% This file is part of the application Psychoacoustics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>



% test for the external mex files
if exist(['ita_loudness_makeSlopes_MEX.' mexext],'file') ~= 3
    comeFrom = pwd;
    cd([fileparts(which(mfilename)) filesep 'private' filesep ]);
    mex ita_loudness_makeSlopes_MEX.c
    cd(comeFrom);
end

if exist(['ita_loudness_BlockNL_MEX.' mexext],'file') ~= 3
    comeFrom = pwd;
    cd([fileparts(which(mfilename)) filesep 'private' filesep ]);
    mex ita_loudness_BlockNL_MEX.c
    cd(comeFrom);
end




%% Generate Test Signals
fs = 44100;
a = 0.5 * (sqrt(log(10)) - sqrt(log(10/9)));
t1 = sqrt(log(sqrt(2)))/ a/1000; %t1 im ms

% Parameter
sig(1).L_pmax   = 70;
sig(1).t_ges    = 0.01;
sig(1).t0       = 0.014 + sig(1).t_ges/2 - t1;
sig(2).L_pmax   = 70;
sig(2).t_ges    = 0.05;
sig(2).t0       = 0.014 + sig(2).t_ges/2 - t1;
sig(3).L_pmax   = 70;
sig(3).t_ges    = 0.5;
sig(3).t0       = 0.014 + sig(3).t_ges/2 - t1;
sig(4).L_pmax   = 60;
sig(4).t_ges    = 0.1;
sig(4).t0       = 0.014 + sig(4).t_ges/2 - t1;
sig(5).L_pmax   = 80;
sig(5).t_ges    = 0.01;
sig(5).t0       = 0.122 + sig(5).t_ges/2 - t1;


testSignale = itaAudio([4 1]);

for iSig = 1:length(sig)
    % calc window
    t = 0:1/fs:1;
    tVec1 = 0:1/fs:(-sig(iSig).t_ges/2+t1+sig(iSig).t0);
    tVec2 = (sig(iSig).t_ges/2-t1+sig(iSig).t0):1/fs:1;
    h = [exp(-1*(1000*a*( tVec1 + sig(iSig).t_ges/2 - t1- sig(iSig).t0)).^2) ones(1,round((sig(iSig).t_ges-2*t1)*fs)) exp(-1*(1000*a*( tVec2 - sig(iSig).t_ges/2+t1-sig(iSig).t0)).^2) ];
    
    testSig = sqrt(2) * 2e-5 * 10^(sig(iSig).L_pmax/20) * cos(2*pi*t * 1000) .* h;
    
    if iSig <5
        testSignale(iSig).timeData = testSig.';
        testSignale(iSig).samplingRate = fs;
    else  % two signals in TestSignal D
        testSignale(4).timeData = testSignale(4).timeData +testSig.';
    end
end

testSignale = ita_merge(testSignale);
testSignale.channelNames = {'Testsignal A: 10 ms', 'Testsignal B: 50 ms', 'Testsignal C: 500 ms', 'Testsignal D: 100 + 10 ms'};
testSignale.channelUnits(:) = {'Pa'};

clear sig iSig t tVec1 tVec2 h testSig a fs t1
%% test only one signal
%[N NS]= ita_loudness_timevariant(testSignale.ch(4), 'blocksize', 2, 'overlap', 0);


%return

%% Test according to DIN
clear SollTS*
SollTS{1}{1} = [0.000 0.00 0.00 0.10 0.00 0.00 0.10
0.002 0.00 0.00 0.10 0.00 0.00 0.10
0.004 0.00 0.00 0.10 0.00 0.00 0.10
0.006 0.00 0.00 0.10 0.00 0.00 0.10
0.008 0.00 0.00 0.10 0.00 0.00 0.10
0.010 0.00 0.00 0.10 0.00 0.00 0.10
0.012 0.00 0.00 0.22 0.00 0.00 0.25
0.014 0.12 0.00 0.71 0.15 0.00 0.80
0.016 0.61 0.02 1.33 0.70 0.05 1.65
0.018 1.23 0.51 2.06 1.55 0.60 2.73
0.020 1.96 1.13 2.34 2.60 1.45 3.60
0.022 2.23 1.86 2.36 3.43 2.47 4.07
0.024 2.25 2.11 2.36 3.88 3.26 4.40
0.026 2.22 1.96 2.36 4.19 3.69 4.48
0.028 2.06 1.48 2.33 4.27 3.84 4.48
0.030 1.58 1.07 2.16 4.04 3.48 4.48
0.032 1.17 0.72 1.68 3.66 2.98 4.24
0.034 0.82 0.51 1.27 3.14 2.58 3.84
0.036 0.61 0.34 0.92 2.72 2.15 3.30
0.038 0.44 0.26 0.71 2.26 1.88 2.86
0.040 0.36 0.20 0.54 1.98 1.60 2.37
0.042 0.30 0.16 0.46 1.70 1.44 2.08
0.044 0.26 0.13 0.40 1.54 1.29 1.80
0.046 0.23 0.11 0.36 1.39 1.20 1.64
0.048 0.21 0.08 0.33 1.30 1.10 1.49
0.050 0.18 0.06 0.31 1.20 1.04 1.40];
SollTS{1}{2} = [0.104 0.01 0.00 0.11 0.42 0.30 0.53
0.106 0.00 0.00 0.11 0.40 0.29 0.52
0.108 0.00 0.00 0.10 0.39 0.28 0.50
 0.110 0 0 0 0.38 0.27 0.49
 0.112 0 0 0 0.37 0.26 0.48];

SollTS{2}{1} = [0.000 0.00 0.00 0.10 0.00 0.00 0.10
0.002 0.00 0.00 0.10 0.00 0.00 0.10
0.004 0.00 0.00 0.10 0.00 0.00 0.10
0.006 0.00 0.00 0.10 0.00 0.00 0.10
0.008 0.00 0.00 0.10 0.00 0.00 0.10
0.010 0.00 0.00 0.10 0.00 0.00 0.10
0.012 0.00 0.00 0.22 0.00 0.00 0.25
0.014 0.12 0.00 0.71 0.15 0.00 0.80
0.016 0.61 0.02 1.33 0.70 0.05 1.65
0.018 1.23 0.51 2.06 1.55 0.60 2.73
0.020 1.96 1.13 2.34 2.60 1.45 3.60
0.022 2.23 1.86 2.36 3.43 2.47 4.07
0.024 2.25 2.12 2.36 3.88 3.26 4.41
0.026 2.25 2.14 2.36 4.20 3.69 4.59
0.028 2.25 2.14 2.36 4.37 3.99 4.75
0.030 2.25 2.14 2.36 4.52 4.15 4.86
0.032 2.25 2.14 2.36 4.63 4.29 4.98
0.034 2.25 2.14 2.36 4.74 4.40 5.07
0.036 2.25 2.14 2.36 4.83 4.50 5.17
0.038 2.25 2.14 2.36 4.92 4.59 5.25
0.040 2.25 2.14 2.36 5.00 4.67 5.34
0.042 2.25 2.14 2.36 5.09 4.75 5.44
0.044 2.25 2.14 2.36 5.18 4.84 5.52
0.046 2.25 2.14 2.36 5.26 4.92 5.61
0.048 2.25 2.14 2.36 5.34 5.00 5.69
0.050 2.25 2.14 2.36 5.42 5.07 5.76
0.052 2.25 2.14 2.36 5.49 5.15 5.82
0.054 2.25 2.14 2.36 5.54 5.22 5.90
0.056 2.25 2.14 2.36 5.62 5.26 5.96
0.058 2.25 2.14 2.36 5.68 5.34 6.04
0.060 2.25 2.14 2.36 5.75 5.40 6.10
0.062 2.25 2.14 2.36 5.81 5.46 6.17
0.064 2.25 2.11 2.36 5.88 5.52 6.23
0.066 2.22 1.98 2.36 5.93 5.59 6.23
0.068 2.08 1.50 2.33 5.90 5.30 6.23
0.070 1.60 1.11 2.18 5.58 4.90 6.20
0.072 1.21 0.89 1.70 5.16 4.49 5.86
0.074 0.99 0.73 1.31 4.73 4.03 5.42
0.076 0.83 0.62 1.09 4.24 3.66 4.97
0.078 0.72 0.54 0.93 3.85 3.42 4.45
0.080 0.64 0.45 0.82 3.60 3.16 4.04];
SollTS{2}{2} = [0.152 0.01 0.00 0.11 0.90 0.77 1.02
0.154 0.00 0.00 0.11 0.87 0.75 1.00
 0.156 0 0 0 0.85 0.72 0.97
0.158 0 0 0 0.82 0.70 0.95];


SollTS{3}{1} = [ 0.000 0.00 0.00 0.10 0.00 0.00 0.10
0.002 0.00 0.00 0.10 0.00 0.00 0.10
0.004 0.00 0.00 0.10 0.00 0.00 0.10
0.006 0.00 0.00 0.10 0.00 0.00 0.10
0.008 0.00 0.00 0.10 0.00 0.00 0.10
0.010 0.00 0.00 0.10 0.00 0.00 0.10
0.012 0.00 0.00 0.22 0.00 0.00 0.25
0.014 0.12 0.00 0.71 0.15 0.00 0.80
0.016 0.61 0.02 1.33 0.70 0.05 1.65
0.018 1.23 0.51 2.06 1.55 0.60 2.73
0.020 1.96 1.13 2.34 2.60 1.45 3.60
0.022 2.23 1.86 2.36 3.43 2.47 4.07
0.024 2.25 2.12 2.36 3.88 3.26 4.41
0.026 2.25 2.14 2.36 4.20 3.69 4.59];
SollTS{3}{2} = [0.504 2.25 2.14 2.36 8.00 7.60 8.40
0.506 2.25 2.14 2.36 8.00 7.60 8.40
0.508 2.25 2.14 2.36 8.00 7.60 8.40
0.510 2.25 2.14 2.36 8.00 7.60 8.40
0.512 2.25 2.14 2.36 8.00 7.60 8.40
0.514 2.25 2.13 2.36 8.00 7.59 8.40
0.516 2.24 1.96 2.36 7.99 7.50 8.40
0.518 2.06 1.70 2.35 7.89 7.28 8.39
0.520 1.80 1.45 2.16 7.66 6.94 8.28
0.522 1.55 1.28 1.90 7.30 6.61 8.04
0.524 1.38 1.09 1.65 6.96 6.20 7.67];
SollTS{3}{3} = [ 0.608 0.01 0.00 0.11 1.45 1.31 1.60
0.610 0.00 0.00 0.11 1.41 1.27 1.55
0.612 0.00 0.00 0.10 1.37 1.22 1.51];


SollTS{4}{1} = [0.000 0.00 0.00 0.10 0.00 0.00 0.10
0.002 0.00 0.00 0.10 0.00 0.00 0.10
0.004 0.00 0.00 0.10 0.00 0.00 0.10
0.006 0.00 0.00 0.10 0.00 0.00 0.10
0.008 0.00 0.00 0.10 0.00 0.00 0.10
0.010 0.00 0.00 0.10 0.00 0.00 0.10
0.012 0.00 0.00 0.14 0.00 0.00 0.14
0.014 0.04 0.00 0.41 0.04 0.00 0.42
0.016 0.31 0.00 0.76 0.32 0.00 0.88
0.018 0.66 0.21 1.17 0.78 0.22 1.41
0.020 1.07 0.56 1.32 1.31 0.68 1.82
0.022 1.22 0.97 1.33 1.72 1.21 2.04
0.024 1.23 1.12 1.33 1.94 1.62 2.19
0.026 1.23 1.13 1.33 2.09 1.84 2.28];

SollTS{4}{2} = [0.112 1.23 1.13 1.33 3.46 3.27 3.64
0.114 1.23 1.13 1.33 3.47 3.29 3.66
0.116 1.23 1.01 1.33 3.49 3.28 3.66
0.118 1.11 0.81 1.33 3.45 3.15 3.66
0.120 0.91 0.61 1.21 3.32 3.03 3.62
0.122 0.71 0.61 1.32 3.19 3.03 3.98
0.124 1.22 0.61 2.76 3.79 3.03 5.66
0.126 2.63 1.12 3.78 5.39 3.60 7.28
0.128 3.60 2.50 4.25 6.93 5.12 8.88
0.130 4.05 3.42 4.36 8.46 6.58 9.74
0.132 4.15 3.78 4.36 9.28 8.04 10.29
0.134 3.98 3.47 4.36 9.80 8.82 10.34
0.136 3.65 2.65 4.18 9.85 8.81 10.34
0.138 2.79 1.99 3.83 9.27 8.02 10.34
0.140 2.09 1.38 2.93 8.44 6.99 9.73
0.142 1.48 1.11 2.19 7.36 6.23 8.86
0.144 1.21 0.88 1.58 6.56 5.44 7.73
0.146 0.98 0.77 1.31 5.73 4.97 6.89];

SollTS{4}{3} = [0.226 0.01 0.00 0.11 1.08 0.95 1.21
0.228 0.00 0.00 0.11 1.05 0.92 1.18
0.230 0.00 0.00 0.10 1.02 0.89 1.15];

%%
yLimits = [4.5 6.5  8.5  10.5];
figure('position', get(0,'screensize'))
for iSig = 1:4
    subplot(220+iSig)
    [N]= ita_loudness_timevariant(testSignale.ch(iSig), 'blocksize', 2, 'overlap', 0);
    plot(N.timeVector, N.timeData, 'linewidth', 2);
%     If you want to check function ita_calculate_loudness
%        [N] = ita_calculate_loudness(testSignale.ch(iSig), 'method', 'Zwicker', 'timeVarying', true, 'timeResolution', 'high');
%        plot(0:5e-4:(numel(N)-1)*5e-4, N(:,1), 'linewidth', 2);

    hold all
    for iPart = 1:numel(SollTS{iSig})
%         plot(SollTS{iSig}{iPart}(:,1), SollTS{iSig}{iPart}(:,6:7), 'color',  'r')
        patch(SollTS{iSig}{iPart}([1:end end:-1:1],1), [SollTS{iSig}{iPart}(:,6); SollTS{iSig}{iPart}(end:-1:1, 7)],'r', 'FaceAlpha', 0.5)
        plot(SollTS{iSig}{iPart}(:,1), SollTS{iSig}{iPart}(:,5), 'color',  'k')
    end
    axis([ 0 SollTS{iSig}{end}(end,1) 0 yLimits(iSig)])
    grid on
    title(['DIN Testsignal Nr ' num2str(iSig) ])
    hold off
    drawnow
end