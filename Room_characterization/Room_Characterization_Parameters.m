close all;
clear all;
clc

addpath(genpath(pwd))

choice = input(['Inserisci un codice: ' ...
    '\n 1 con TV' ...
    '\n 2 con TV coperta ' ...
    '\n 3 senza TV ' ...
    '\n 4 senza TV e porta coperta ' ...
    '\n 5 no seat ' ...
    '\n 6 no seat no pedal ' ...
    '\n 7 to try the non predistorted sweep: ' ...
    '\n 8 analyze the subwoofer ' ...
    '\n 9 direct sound in virtual room ' ...
    '\n 10 gain tuned and tweeter switched' ...
    '\n 11 balloons:\n']);
opzione=0;
switch choice
    case 1
        disp('con TV');
        file_path='\measures\TV\Virtual_Room_Charaterization_TV_20230929\';
        calRec=audioread('\measures\TV\Calibration.wav');
    case 2
        disp('covered TV');
        file_path='\measures\CoverTV\Virtual_Room_CoverTV_NoHeadrestMeasureType_1_20231023\'; 
        calRec=audioread('\measures\CoverTV\Calibration.wav');
    case 3
        disp('no TV');
        file_path='Morel_measurements\measures\NoTV\Virtual_Room_NO_TV_NoHeadrest_SingleSpeakersMeasureType_1_20231026\'; 
         calRec=audioread('\Morel_measurements\measures\NoTV\Calibration.wav');
    case 4
        disp('no TV cover door');
        file_path='Morel_measurements\measures\NoTV_CoverDoor\Virtual_Room_NO_TV_CoverDoor_NoHeadrest_SingleSpeakersMeasureType_1_20231026\'; 
        calRec=audioread('\Morel_measurements\measures\NoTV_CoverDoor\Calibration.wav');
    case 5
        disp('no seat ');
        file_path='Morel_measurements\measures\NoSeat\Virtual_Room_NoSeat_SingleSpeakersMeasureType_1_20231031\'; 
        calRec=audioread('\Morel_measurements\measures\NoSeat\Calibration.wav');
    case 6
        disp('no seat no pedal ');
        file_path='Morel_measurements\measures\NoSeat_NoPedal\Virtual_Room_NoSeat_NoPedal_SingleSpeakersMeasureType_1_20231031\'; 
        calRec=audioread('Morel_measurements\measures\NoSeat_NoPedal\Calibration.wav');
     case 7
        disp('no predistorted, central');
        file_path='Morel_measurements\measures\no_predistorted\Virtual_Room_NoPreDist_SingleSpeakers_3Mics_v5MeasureType_1_20231102\'; 
        calRec=audioread('\Morel_measurements\measures\no_predistorted\Calibration.wav');
     case 8
        disp('Analyze subwoofer');
        file_path='Sub_measurements\'; 
        calRec=audioread('\Sub_measurements\Calibration_PCB.wav');
    case 9
        disp('suono diretto in saletta');
        opzione=input(['1: cassa 9 senza griglia non pre' ...
            '        \n 2:cassa 9 con griglia non pre' ...
            '        \n 3 cassa 7 senza griglia predistorto' ...
            '        \n 4 cassa 7 senza griglia non pre' ...
            '        \n 5 cassa 7 con griglia predistorto' ...
            '        \n 6 cassa 7 con griglia non pre:\n']);
        file_path='Morel_measurements\measures\single_morels\'; 
        calRec=audioread('Morel_measurements\measures\single_morels\Calibration.wav');
    case 10
        disp('gain aggiustato e tweeter girato, predistorto');
        opzione=input(['1: tv e porta non coperte' ...
            '        \n 2: tv e porta  coperte:\n']);
        file_path='Morel_measurements\measures\switch_tweeter_gain_tuned\'; 
         switch opzione
          case 1 
              file_path=fullfile(file_path,'Virtual_Room_PreDist_SingleSpeakerGainTunedMeasureType_1_20231110' );
          case 2
              file_path=fullfile(file_path,'Virtual_Room_PreDist_SingleSpeakerGainTuned_CoverDoor_CoverTVMeasureType_1_20231110' );
         end 
        calRec=audioread('Morel_measurements\measures\switch_tweeter_gain_tuned\Calibration_PCB.wav');  % metti il microfono
    case 11
        disp('Palloncini, valutazione stanza');
        file_path='Morel_measurements\measures\Baloon\'; 
        calRec=audioread('Morel_measurements\measures\Baloon\Calibration_PCB.wav');
        
    otherwise
        disp('wrong option');
end


%saving folder
folderPath = 'IR'; 
if ~isfolder(folderPath)
    mkdir(folderPath);
end

% load inv_sweep
if choice==7||(choice==9 && (opzione==1||opzione==2||opzione==4||opzione==6))
    %5seconds sweep
    [inv_sweep, fs] = audioread('\measures\no_predistorted\InvSineSweepMono32Bit48000_5sec_3secSilence(1).wav');
elseif choice==8
    [inv_sweep, fs] = audioread('\Sub_measurements\InvSweep_15s_1sSilence_10hz_1000hz_02Fade.wav');
else
    %3seconds sweep(predist)
    [inv_sweep, fs] = audioread('InvSineSweep_22_22k_1s_3sSilence_fadein_fadeout.wav');
end

n_ls=25; %all morel signals
responses=struct;
%points for the cut, 5001 points length
first_cut=230;
second_cut=5000;

%% main cicle,forall loudspeakers
for i=1: n_ls
    [morel, fs] = audioread(fullfile(file_path, ['-Channel_',  int2str(i), '.wav']));
    if choice==7||choice==10
            morel=morel(1:end, 1);
    end
    filter_size=length(morel)+length(inv_sweep)-1;
    inv_sweep_fft = fft(inv_sweep, filter_size);
    morel_fft = fft(morel, filter_size);
    
    IR_fft= morel_fft.* inv_sweep_fft;
    
    %in time and align
    IR=ifft(IR_fft);

    [pks,locs] = findpeaks(IR);
    [~, in]=max(pks);
    sample_peak=locs(in);
    sample_cut=sample_peak-first_cut;
    IR=IR(sample_cut:end);

    field=strcat(['IR', int2str(i)]);
    responses.(field)=IR;

end 


%% total impulse response: sum of all single IRs
    [length_total,~]=min(structfun(@length,responses));
    IR_tot_sum=zeros(length_total, 1);  %inizialization
    for i=1:n_ls
        field=strcat(['IR', int2str(i)]);
        responses.(field)=responses.(field)(1:length_total, 1);
        IR_tot_sum=IR_tot_sum+responses.(field);
    end

% window from the peak, neglecting before it, final size of 5001 samples
[pks,locs] = findpeaks(IR_tot_sum);
[~, in]=max(pks);
sample_peak=locs(in);
sample_cut=sample_peak-first_cut;
IR_tot_sum=IR_tot_sum(sample_cut:sample_cut+second_cut);

%plots
figure()
time=linspace(0, length(IR_tot_sum)/fs, length(IR_tot_sum));
plot(time, IR_tot_sum);  
title('total IR');
xlabel('time sec');

%plot in frequencies
IR_tot_sum_fft = fft(IR_tot_sum);
NFFT = length(IR_tot_sum_fft);
Noct = 5; %1/Noct octave band
f = ((1:NFFT/2)'./NFFT).*fs;
Z = iosr.dsp.smoothSpectrum(abs(IR_tot_sum_fft(1:floor(length(IR_tot_sum)/2))),f,Noct);

% plot
figure
loglog(f, abs(IR_tot_sum_fft(1:floor(length(IR_tot_sum_fft)/2))),f,Z);
xlabel('Hz');
title('Sum af all the single IRs')
legend('whole spectrum', 'filtered spectrum');
xticks([ 100 200 500 1000 2000 4000]);
xticklabels({'100','200','500','1000','2000', '4000'});
xlim([20 20000]);

% save total
wholePath= fullfile(folderPath, 'IR_sum_total_nonCalibrated.wav');

audiowrite(wholePath, rescale(IR_tot_sum, -1, 1),  fs);

%% SUBWOOFER
[Z_sub ]=calibration_function_sub(calRec,file_path, inv_sweep);

%% CALIBRATION
calibration_function(calRec, first_cut, second_cut, n_ls, file_path, inv_sweep, choice, opzione);

%% parameters extraction and visualization- parameters extraction trought irStat - give the right path
    [rt,drr, cte, cte_mean, cfs, edt]=iosr.acoustics.irStats('subwoofer_all.wav', 'graph', true, 'y_fit', [-5 -25]);
    [rt_b,drr_b, cte_b, cte_mean_b, cfs_b, edt_b]=iosr.acoustics.irStats('sum_calibrated_whole.wav', 'graph', true, 'y_fit', [-5 -25]);

    rt_tot=zeros([2 length(cfs)-1]);
    for i=2:length(cfs)
       if i<=4
           rt_tot(1, i-1)=rt(i);
       else
           rt_tot(1, i-1)=0;
       end
       rt_tot(2, i-1)=rt_b(i);
    end

    edt_tot=zeros([2 length(cfs_b)-1]);
    for i=2:length(cfs)
       if i<=4
           edt_tot(1, i-1)=edt(i);
       else
           edt_tot(1, i-1)=0;
       end
        edt_tot(2, i-1)=edt_b(i);
    end

    cte_tot=zeros([2 length(cfs_b)-1]);
    for i=2:length(cfs)
       if i<=4
           cte_tot(1, i-1)=cte(i);
       else
           cte_tot(1, i-1)=0;
       end
        cte_tot(2, i-1)=cte_b(i);
    end

    X = categorical(cfs(2:end));
    figure();
    bar(X, rt_tot);
    legend('Subwoofer excitation', 'Woofers and tweeters excitation ');
    title({'Reverberation Time T20', ' Sweep signal with TV and door not covered'});
    ylabel('time [s]');
    xlabel('Hz');
    ylim([0 0.2])
    
    figure();
    edt_plot=edt(2:4)
    bar(X, edt_tot);
    legend('Subwoofer excitation', 'Woofers and tweeters excitation ');
    title({'EDT', 'Sweep signal TV and door  covered'});
    ylabel('time [s]');
    xlabel('Hz');
    
    figure();
    cte_plot=cte(2:4);
    bar(X, cte_tot);
    legend('Subwoofer excitation', 'Woofers and tweeters excitation ');
    ylabel('dB');
    title({'C50', 'Sweep signal TV and door  covered'});
    xlabel('Hz');
    %% parameters extraction and visualization- parameters extraction trought ITA Toolbox
    RIR = ita_read;

    freqRange       = [40 4000];       % frequency range and
    bandsPerOctave  = 2;                % bands per octave for filtering

    % calculate parameters with given frequency range in 1/3 octave bands
       
    raResults = ita_roomacoustics(RIR, 'freqRange', freqRange, 'bandsPerOctave', bandsPerOctave, 'PSNR_Lundeby','startThreshold', 5, 'edcMethod', 'cutWithCorrection', 'EDT', 'T30', 'EDC' );
    cResults = ita_roomacoustics(RIR, 'freqRange', freqRange, 'bandsPerOctave', bandsPerOctave, 'PSNR_Lundeby','startThreshold', 20, 'edcMethod', 'noCut', 'C50' );
    
   % output is a struct with itaResults:
    raResults.EDT.channelNames = {'Octave bands'};
    raResults.T30.channelNames = {'Octave bands'};
    cResults.C50.channelNames = {'Octave bands'};
    raResults.PSNR_Lundeby.channelNames = {'Octave bands'};
  
    bar(raResults.EDT)
    title('Early Decay Time')
    legend('covered', 'not covered')
    bar(raResults.T30)
    title('Reverberation time T20')
    legend('covered', 'not covered')
    bar(cResults.C50)
    title('Energy parameter C50')
    legend('covered', 'not covered')
    raResults.PSNR_Lundeby.plot_freq
    title('Lundeby method')
    raResults.EDC.plot_time_dB
    title('energy decay curve according to Schroeder s formulation')