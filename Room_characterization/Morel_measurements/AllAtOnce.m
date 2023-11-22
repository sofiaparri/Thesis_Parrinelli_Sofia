function IRAllAtOnce=AllAtOnce(first_cut, second_cut, choice)
addpath(genpath(pwd))
% path to data

% load inv_sweep
[inv_sweep, fs] = audioread('InvSineSweep_22_22k_1s_3sSilence_fadein_fadeout.wav');

switch choice
    case 1
        disp('con TV');
        folder_path='\measures\TV\Virtual_Room_Charaterization_AllAtOnceTV_20231019\-_AllAtOnce.wav';
    case 2
        folder_path='\measures\CoverTV\Virtual_Room_CoverTV_NoHeadrest_AllAtOnceMeasureType_2_20231023\-_AllAtOnce.wav'; 
        disp('covered TV');
    case 3
        folder_path=('\measures\NoTV\Virtual_Room_NO_TV_NoHeadrest_AllAtOnceMeasureType_2_20231026\-_AllAtOnce.wav');
        disp('no TV');
    case 4
        folder_path=('\measures\NoTV_CoverDoor\Virtual_Room_NO_TV_CoverDoor_NoHeadrest_AllAtOnceMeasureType_2_20231026\-_AllAtOnce.wav')
        disp('no TV covered door');
end


[AllinOne, fs] = audioread(folder_path);


filter_size=length(AllinOne)+length(inv_sweep)-1;
    
 %ffts
inv_sweep_fft = fft(inv_sweep, filter_size);
AllinOne_fft = fft(AllinOne, filter_size);
    
%moltiplication (convolution)
IR_fft= AllinOne_fft.* inv_sweep_fft;
IR=ifft(IR_fft);

% window from the peak, neglecting before it
[pks,locs] = findpeaks(IR);
[M, in]=max(pks);
sample_peak=locs(in);
sample_cut=sample_peak-first_cut;
IR_cut=IR(sample_cut:sample_cut+second_cut);
IR_fft=fft(IR_cut); %aggiorna fft from cut signal


%%plot in freq
%  % keep only meaningful frequencies
%      % keep only meaningful frequencies
%      NFFT = length(IR_fft);
%      if mod(NFFT,2)==0
%          Nout = (NFFT/2)+1;
%      else
%          Nout = (NFFT+1)/2;
%      end
%      f = ((0:Nout-1)'./NFFT).*fs;
%      
%      % put into dB/abs
%      IR_fft=abs(IR_fft);
%      %IR_tot_fft = 20*log10(abs(IR_tot_fft)./NFFT);
%      
%      % smooth
%      Noct = 5; %1/Noct octave band
%      Z = iosr.dsp.smoothSpectrum(IR_fft(1:Nout),f,Noct);
%      
%      % plot
%      figure();
%      loglog(f,Z);
%      xlabel('Hz');
%      legend('whole spectrum', 'filtered spectrum');
%      xticks([ 100 200 500 1000 2000 4000]);
%      xticklabels({'100','200','500','1000','2000', '4000'});
%      xlim([20 20000]);



% salvataggio
IRAllAtOnce=IR_cut;
%wholePath= 'IR\AllAtOnceIR.wav';
%audiowrite(wholePath, IR_cut, fs);

end
