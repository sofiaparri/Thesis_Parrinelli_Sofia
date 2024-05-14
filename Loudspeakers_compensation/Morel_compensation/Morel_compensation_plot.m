clear all;
close all;

addpath(genpath(pwd));

first_cut=1000;
second_cut=5000;

[IR_predist_morel, fs]= audioread('PreDistMorel_SineSweep_RecMorel.wav');
[IR_morel, fs]=audioread('IR_Morel_version2_nonPredist.wav');
IR_morel=IR_morel( [1: length(IR_morel)-( length(IR_morel)-length(IR_predist_morel))], 1); %equal length

%cut
[pks,locs] = findpeaks(IR_morel);
[~, in]=max(pks);
sample_peak=locs(in);
sample_cut=sample_peak-first_cut;
IR_morel_cut=IR_morel(sample_cut:sample_cut+second_cut);

[pks,locs] = findpeaks(IR_predist_morel);
[~, in]=max(pks);
sample_peak=locs(in);
sample_cut=sample_peak-first_cut;
IR_predist_morel_cut=IR_predist_morel(sample_cut:sample_cut+second_cut);

IR_predist_morel_fft=fft(IR_predist_morel_cut);
IR_morel_fft=fft(IR_morel_cut);

frequencies = (1:(length(IR_morel_fft))) * fs / length(IR_morel_fft); 
figure()
loglog(frequencies(1,1:length(frequencies)/2), abs(IR_morel_fft(1:floor(length(IR_morel_fft)/2), 1))); 
hold on
loglog(frequencies(1,1:length(frequencies)/2), abs(IR_predist_morel_fft(1:floor(length(IR_predist_morel_fft)/2), 1))); 
xlabel('Hz')
xticks([ 100 200 500 1000 2000 4000])
xticklabels({'100','200','500','1000','2000', '4000'})
xlabel('Frequency [Hz]');
xlim([40 20000])
yticks([])
ylabel('Amplitude');
legend('Non predistorted speaker spectrum', 'Predistorted speaker spectrum')

%predistorted and non smoothed
f = ((1:floor(length(IR_predist_morel_fft))/2+1)'./length(IR_predist_morel_fft)).*fs;
Noct = 5; %1/Noct octave band
Z = iosr.dsp.smoothSpectrum(abs(IR_predist_morel_fft(1:floor(length(IR_predist_morel_fft)/2)+1, 1)),f,Noct);
Z_non_pre = iosr.dsp.smoothSpectrum(abs(IR_morel_fft(1:floor(length(IR_morel_fft)/2)+1, 1)),f,Noct);
%% 

% plot
figure()
loglog(f,Z, f, Z_non_pre)
title(['compensated impulse response smoothed ', Noct, ' octave band']); 
xlabel('Frequency [Hz]');
ylabel('Amplitude');
legend('predistorted spectrum', 'original spectrum')
xticks([ 100 200 500 1000 2000 4000]) ;
xticklabels({'100','200','500','1k','2k', '4k'});
xlim( [ 80 24000 ] );
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[InvKirk_IR, fs]= audioread('InvKirkeby_IR_Morel_20230921.wav');
[IR, fs]= audioread('IR_Morel_20230921.wav');
[invSineSweep, fs]= audioread('InvSineSweep_22_22k_1s_3sSilence_fadein_fadeout.wav');

figure()
fftsinesweepinv=fft(InvKirk_IR);
plot(abs(fftsinesweepinv(1:floor(end/2))))
xlabel('Hz')

figure()
plot(IR)

fft_data=fft(data);
frequencies = (1:(length(data))) * fs / length(data);
figure()
loglog(abs(fft_data(1: floor(length(data)/2))))
xlabel('Hz')
xticks([ 10  100   1000 10000 ])
xticklabels({'10' '100','1000' '10000'})
xlim([10 20000])
yticks([])
ylabel('Amplitude');



