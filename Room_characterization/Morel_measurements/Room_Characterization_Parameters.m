close all;
clear all;
clc

addpath(genpath(pwd))

choice = input('Inserisci un codice: \n 1 con TV \n 2 con TV coperta \n 3 senza TV \n 4 senza TV e porta coperta \n: ');

switch choice
    case 1
        disp('con TV');
        file_path='\measures\Virtual_Room_Charaterization_TV_20230929\';
    case 2
        disp('covered TV');
        file_path='\measures\Virtual_Room_CoverTV_NoHeadrestMeasureType_1_20231023\'; 
    case 3
        file_path='\measures\Virtual_Room_NO_TV_NoHeadrest_SingleSpeakersMeasureType_1_20231026\'; 
        disp('no TV');
    case 4
        file_path='\measures\Virtual_Room_NO_TV_CoverDoor_NoHeadrest_SingleSpeakersMeasureType_1_20231026\'; 
        disp('no TV cover door');
    otherwise
        disp('wrong option');
end



%saving folder
folderPath = 'IR'; 
if ~isfolder(folderPath)
    mkdir(folderPath);
end

% load inv_sweep
[inv_sweep, fs] = audioread('InvSineSweep_22_22k_1s_3sSilence_fadein_fadeout.wav');

n_ls=25; %all morel signals

%% main cicle,forall loudspeakers
first_cut=230;
second_cut=5000;
for i=1: n_ls
    [morel, fs] = audioread(fullfile(file_path, ['-Channel_',  int2str(i), '.wav']));
    filter_size=length(morel)+length(inv_sweep)-1;
    
    %ffts
    inv_sweep_fft = fft(inv_sweep, filter_size);
    morel_fft = fft(morel, filter_size);
    
    %moltiplication
    IR_fft= morel_fft.* inv_sweep_fft;
    
    %in time
    IR=ifft(IR_fft);

    % window from the peak, neglecting before it, final size of 5051 samples
    [pks,locs] = findpeaks(IR);
    [M, in]=max(pks);
    sample_peak=locs(in);
    sample_cut=sample_peak-first_cut;
    IR_cut=IR(sample_cut:sample_cut+second_cut);
    IR_cut_fft=fft(IR_cut); %aggiorno lo spettro

    % salvataggio
    wholePath= fullfile(folderPath, ['IR ', int2str(i), '.wav']);
    audiowrite(wholePath, IR_cut, fs);

 

    %plot in freq, normal graph
    %figure()
    %frequencies = (1:(length(IR_cut_fft))) * fs / length(IR_cut_fft); 
    %loglog(frequencies(1,1:length(frequencies)/2), abs(IR_cut_fft(1:floor(length(IR_cut_fft)/2), 1)));  
    %title([' IR', int2str(i), 'spectrum "real values" no approximation']);
    %xlabel('Hz')
    %xticks([ 100 200 500 1000 2000 4000]) ;
    %xticklabels({'100','200','500','1000','2000', '4000'});
    %xlim([20 20000]);
end 

%% grid plots
%frequencies
num_righe = 5;
num_colonne = 5;
figure;
for i = 1:n_ls
    subplot(num_righe, num_colonne, i);
    sig_IR_fft=fft(audioread(fullfile(folderPath, ['IR ', int2str(i), '.wav'])));
    margin = 0.06; %  margine tra i subplot 
    padding = 0.003; %  spazio dai bordi 
    subaxis(num_righe, num_colonne, i, 'Spacing', margin, 'Padding', padding);
    % keep only meaningful frequencies
    NFFT = length(sig_IR_fft);
    if mod(NFFT,2)==0
        Nout = (NFFT/2)+1;
    else
        Nout = (NFFT+1)/2;
    end
    sig_IR_fft = sig_IR_fft(1:Nout);
    f = ((0:Nout-1)'./NFFT).*fs;
      
    % put into dB, to decide after the calibration
    sig_IR_fft=abs(sig_IR_fft);
    %sig_IR_fft = 20*log10(abs(sig_IR_fft)./NFFT);
      
    % smooth
    Noct = 5; %1/Noct octave band
    Z = iosr.dsp.smoothSpectrum(sig_IR_fft,f,Noct);
    
    % plot
    loglog(  f,Z)
    title(['LS ' num2str(i)]); 
    xlabel('Hz');
    xticks([ 100 200 500 1000 2000 4000]) ;
    xticklabels({'100','200','500','1k','2k', '4k'});
    xlim([30 20000]);
    ylim([-10 10]);
end

%time
figure;
for i = 1:n_ls
    subplot(num_righe, num_colonne, i);
    sig_IR=audioread(fullfile(folderPath, ['IR ', int2str(i), '.wav']));
    margin = 0.05; %  margine tra i subplot 
    padding = 0.001; %  spazio dai bordi 
    time=linspace(0, length(sig_IR)/fs, length(sig_IR));
    subaxis(num_righe, num_colonne, i, 'Spacing', margin, 'Padding', padding);
    plot(time,sig_IR);
    title(['LS ' num2str(i)]); % Aggiungi un titolo
end



% %% sub (lack of impulsiveness?)
% [sub, fs] = audioread('Virtual_Room_Charaterization_SubMeasureType_1_20230929/-Channel_26.wav');
% sub_IR=subwoofer_analysis(sub, inv_sweep, fs );
% % salvataggio
% audiowrite(fullfile(folderPath, ['IR_sub.wav']), sub_IR, fs);

%% total impulse response: sum of all single IRs
IR_tot=audioread(fullfile(folderPath, 'IR 1.wav'));
for i=2:n_ls
    wholePath= fullfile(folderPath, ['IR ', int2str(i), '.wav']);
    IR_current=audioread(wholePath);
    IR_tot=IR_tot+IR_current;   
end

%plots
figure()
time=linspace(0, length(IR_tot)/fs, length(IR_tot));
plot(time, IR_tot);  
title('total IR');
xlabel('time sec');

%plot in frequencies

      IR_tot_fft = fft(IR_tot);
      % keep only meaningful frequencies
      NFFT = length(IR_tot_fft);
      if mod(NFFT,2)==0
          Nout = (NFFT/2)+1;
      else
          Nout = (NFFT+1)/2;
      end
      f = ((0:Nout-1)'./NFFT).*fs;
      
      % put into dB/abs
      IR_tot_fft=abs(IR_tot_fft);
      %IR_tot_fft = 20*log10(abs(IR_tot_fft)./NFFT);
      
      % smooth
      Noct = 5; %1/Noct octave band
      Z = iosr.dsp.smoothSpectrum(IR_tot_fft(1:Nout),f,Noct);
      
      % plot
      figure
      loglog(f,IR_tot_fft(1:Nout),f,Z);
      xlabel('Hz');
      legend('whole spectrum', 'filtered spectrum');
      xticks([ 100 200 500 1000 2000 4000]);
      xticklabels({'100','200','500','1000','2000', '4000'});
      xlim([20 20000]);
 
%%yi=smoothdata(IR_tot_fft,"gaussian");
%IR_tot_fft=fft(IR_tot, fs);
%frequencies = (1:(length(IR_tot_fft))) * fs / length(IR_tot_fft); 
%irSum=iosr.dsp.smoothSpectrum(IR_tot_fft,f,3)
%%window_size=300; %samples, width of the window where the mean is calculated
%%irSum = smoothdata(abs(IR_tot_fft), 'movmean', window_size); %moving mean smooth
%figure()
%loglog(frequencies(1,1:length(frequencies)/2), abs(irSum(1:floor(length(irSum)/2), 1))); 
%title(['total sum IR fft movmean smoothdata with ' window_size*fs/length(IR_tot_fft) ' Hz window length']);
%xlabel('Hz')
%xlabel('Hz')
%xticks([ 100 200 500 1000 2000 4000])
%xticklabels({'100','200','500','1000','2000', '4000'})
%xlim([20 20000])

% save total
wholePath= fullfile(folderPath, 'IR_sum_total.wav');
audiowrite(wholePath, IR_tot, fs);

%% plot together
%load IR in the case all ls play together
IR_AllAtOnce=AllAtOnce(first_cut, second_cut, choice);
IR_fftAllAtOnce= fft(IR_AllAtOnce);

freqs= ((1:length(IR_tot_fft))'./length(IR_tot_fft)).*fs;
figure()
loglog(freqs(1:length(freqs)/2,1), abs(IR_tot_fft(1:floor(length(IR_tot_fft)/2), 1)), freqs(1:length(freqs)/2,1), abs(IR_fftAllAtOnce(1:floor(length(IR_fftAllAtOnce)/2), 1))); 
legend('sum of single IRs', 'all at once')
xlabel('Hz')
xlabel('Hz')
xticks([ 100 200 500 1000 2000 4000 10000])
xticklabels({'100','200','500','1000','2000', '4000', '10000'})
xlim([20 20000])

%save to plot together parameters
two_signals=zeros(length(IR_AllAtOnce), 2);
two_signals(:, 1)=IR_tot(:, 1);
two_signals(:, 2)=IR_AllAtOnce(:, 1);
two_sig_path= fullfile(folderPath, 'IR_twototal.wav');
audiowrite(two_sig_path, two_signals, fs);

%% parameters extraction and visualization
    % parameters extraction trought ITA Toolbox
    RIR = ita_read;

    %T20
    freqRange       = [20 5000];       % frequency range and
    bandsPerOctave  = 1;                % bands per octave for filtering

    % calculate parameters with given frequency range in 1/3 octave bands
       
    raResults = ita_roomacoustics(RIR, 'freqRange', freqRange, 'bandsPerOctave', bandsPerOctave, 'Intersection_Time_Lundeby', 'EDT', 'T20', 'C50','D50', 'PSNR_Lundeby', 'EDC', 'plotLundebyResults', true );
    % output is a struct with itaResults:
    raResults.EDT.channelNames = {'Octave bands'};
    raResults.T20.channelNames = {'Octave bands'};
    raResults.C50.channelNames = {'Octave bands'};
    raResults.PSNR_Lundeby.channelNames = {'Octave bands'};
    raResults.D50.channelNames = {'Octave bands'};
    
    bar(raResults.EDT)
    title('Early Decay Time')
    legend('sum', 'allInOne')
    bar(raResults.D50)
    title('D50')
    bar(raResults.T20)
    title('Reverberation time T20')
    legend('sum', 'allInOne')
    bar(raResults.C50)
    title('Energy parameter C50')
    legend('sum', 'allInOne')
    raResults.PSNR_Lundeby.plot_freq
    title('Lundeby method')
    raResults.EDC.plot_time_dB
    title('energy decay curve according to Schroeder s formulation')
