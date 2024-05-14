%% plots primo confronto
addpath(genpath(pwd))
 load('Conf1_spec.mat');
 IR_one=irFftDbCorrected;
 load('Conf2_spec.mat');
 IR_two=irFftDbCorrected;
 load('Conf3_spec.mat');
 IR_three=irFftDbCorrected;
 load('Conf4_spec.mat');
 IR_four=irFftDbCorrected;
 load('Conf5(6)_spec.mat');
 IR_five=irFftDbCorrected;
 nfft= length(IR_one);
 fs=48000;
 f = ((1:floor(nfft))'./nfft).*fs;
 
 % smooth
 Noct = 6; %1/Noct octave band
 Z_one = iosr.dsp.smoothSpectrum(abs(IR_one(1:length(IR_one))),f,Noct);
 Z_two = iosr.dsp.smoothSpectrum(abs(IR_two(1:length(IR_two))),f,Noct);
 Z_three = iosr.dsp.smoothSpectrum(abs(IR_three(1:length(IR_three))),f,Noct);
 Z_four = iosr.dsp.smoothSpectrum(abs(IR_four(1:length(IR_four))),f,Noct);
 Z_five = iosr.dsp.smoothSpectrum(abs(IR_five(1:length(IR_five))),f,Noct);

 figure()
 semilogx( f, Z_one)
 hold on

 semilogx( f, Z_two)
 hold on

 semilogx( f, Z_three)
 hold on

 semilogx( f, Z_four)
 hold on

 semilogx( f, Z_five)
 hold off
 grid on
 xlim( [ 20 24000 ] )
 ylim([100 120])
 xlabel('Hz')
 ylabel('dB')
 legend('Configuration 1' , 'Configuration 2', 'Configuration 3', 'Configuration 4', 'Configuration 5')
 xticks([ 100 200 500 1000 2000 4000 10000])
 xticklabels({'100','200','500','1000','2000', '4000', '10000'})


 %% plots secondo confronto con tweeter girato

 load('Conf1_spec_fixedPhase.mat');
 spec_one=irFftDbCorrected;
 load('Conf2(covered)_spec_fixedPhase.mat');
 spec_two=irFftDbCorrected;

 nfft= length(spec_one);
 fs=48000;
 f = ((1:floor(nfft))'./nfft).*fs;
 
 % smooth
 Noct = 6; %1/Noct octave band
 S_one = iosr.dsp.smoothSpectrum(abs(spec_one(1:length(spec_one))),f,Noct);
 S_two = iosr.dsp.smoothSpectrum(abs(spec_two(1:length(spec_two))),f,Noct);

 figure()
 semilogx( f, S_one)
 hold on
 semilogx( f, S_two)
 hold off

 grid on
 xlim( [ 20 24000 ] )
 ylim([80 130])
 xlabel('Hz')
 ylabel('dB')
 legend('Configuration 1' , 'Configuration 2')
 xticks([ 100 200 500 1000 2000 4000 10000])
 xticklabels({'100','200','500','1000','2000', '4000', '10000'})

 %% IN TEMPO
 load('Conf_1IRsumTweeterOK.mat');
 time_one=irWinPad_sum;
 load('Conf_2IRsumTweeterOK.mat');
 time_two=irWinPad_sum;

  fs=48000;

 time=linspace(0, length(time_one)/fs, length(time_one));
 figure()
 plot( time, -time_one )
 hold on
 plot( time, -time_two )

 xlabel('time [s]')
 grid on
 set(gca,'YTick',[])
 legend('No covering' , 'TV and door covered')
 xlim( [ 0 0.05 ] )




   