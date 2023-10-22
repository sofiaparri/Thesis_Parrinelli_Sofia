clear all;
close all;

addpath(genpath(pwd));

[IR_predist_morel, fs]= audioread('PreDistMorel_SineSweep_RecMorel.wav');
[IR_morel, fs]=audioread('IR_Morel_version2_nonPredist.wav');
IR_morel=IR_morel( [1: length(IR_morel)-( length(IR_morel)-length(IR_predist_morel))], 1);
IR_predist_morel_fft=fft(IR_predist_morel);
IR_morel_fft=fft(IR_morel);

frequencies = (1:(length(IR_morel_fft))) * fs / length(IR_morel_fft); 
figure()
loglog(frequencies(1,1:length(frequencies)/2), abs(IR_morel_fft(1:floor(length(IR_morel_fft)/2), 1))); 
hold on
loglog(frequencies(1,1:length(frequencies)/2), abs(IR_predist_morel_fft(1:floor(length(IR_predist_morel_fft)/2), 1))); 
title('IR Morel ');
xlabel('Hz')
xticks([ 100 200 500 1000 2000 4000])
xticklabels({'100','200','500','1000','2000', '4000'})
xlim([40 20000])
legend('Non predistorted Morel spectrum', 'Predistorted Morel spectrum')


