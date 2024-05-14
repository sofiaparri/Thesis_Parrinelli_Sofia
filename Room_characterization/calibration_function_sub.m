function [Z_sub]=calibration_function_sub (calRec, file_path, inv_sweep) 
addpath(genpath(pwd))

    folderPath_calibrated = 'IR_calibrated'; 
       if ~isfolder(folderPath_calibrated)
           mkdir(folderPath_calibrated);
       end
       
    % calibratore
    calRms   = rms( calRec );
    calRef   = 1;                            % [Pa] rms
    calFactor= calRef / calRms;
    %checkCal = rms( calRec * calFactor );    % must be 1 Pa

    %% calibrated response subwoofer

    

    [Sub_all, ~] = audioread(fullfile(file_path, "SUB_1+2.wav"));
    [Sub_one, ~]=audioread(fullfile(file_path, "subs/SUB_1.wav"));
    [Sub_two, fs]=audioread(fullfile(file_path, "subs/SUB_2.wav"));
    Sub_calibrated_all = Sub_all * calFactor;
    Sub_calibrated_one = Sub_one * calFactor;
    Sub_calibrated_two = Sub_two * calFactor;
    filter_size_all=length(Sub_calibrated_all)+length(inv_sweep)-1;
    filter_size_one=length(Sub_calibrated_one)+length(inv_sweep)-1;
    filter_size_two=length(Sub_calibrated_two)+length(inv_sweep)-1;
    
    inv_sweep_fft_all = fft(inv_sweep, filter_size_all);
    inv_sweep_fft_one = fft(inv_sweep, filter_size_one);
    inv_sweep_fft_two = fft(inv_sweep, filter_size_two);
    Sub_calibrated_all_fft = fft(Sub_calibrated_all, filter_size_all);
    Sub_calibrated_one_fft = fft(Sub_calibrated_one, filter_size_one);
    Sub_calibrated_two_fft = fft(Sub_calibrated_two, filter_size_two);
    
    %moltiplication
    IRSub_calibrated_fft_all= Sub_calibrated_all_fft.* inv_sweep_fft_all;
    IRSub_calibrated_fft_one= Sub_calibrated_one_fft.* inv_sweep_fft_one;
    IRSub_calibrated_fft_two= Sub_calibrated_two_fft.* inv_sweep_fft_two;
    
    %in time and cut
    first_cut=100000;
    second_cut= 400000;
    IRSub_calibrated_all=ifft(IRSub_calibrated_fft_all);
    IRSub_calibrated_one=ifft(IRSub_calibrated_fft_one);
    IRSub_calibrated_two=ifft(IRSub_calibrated_fft_two);
    
    [pks,locs] = findpeaks(IRSub_calibrated_all);
    [~, in]=max(pks);
    sample_peak=locs(in);
    sample_cut=sample_peak-first_cut;
    IRSub_calibrated_cut_all=IRSub_calibrated_all(sample_cut:sample_cut+second_cut);
    
    [pks,locs] = findpeaks(IRSub_calibrated_one);
    [~, in]=max(pks);
    sample_peak_one=913586; %attenzione: il picco più alto è il secondo
    sample_cut_one=sample_peak_one-first_cut;
    IRSub_calibrated_cut_one=IRSub_calibrated_one(sample_cut_one:sample_cut_one+second_cut);

    [pks,locs] = findpeaks(IRSub_calibrated_two);
    [~, in]=max(pks);
    sample_peak_two=locs(in);
    sample_cut_two=sample_peak_two-first_cut;
    IRSub_calibrated_cut_two=IRSub_calibrated_two(sample_cut_two:sample_cut_two+second_cut);
    
    IRSub_calibrated_cut_sum=zeros( length(IRSub_calibrated_cut_two), 1);
    
    for i=1:length(IRSub_calibrated_cut_two)
        IRSub_calibrated_cut_sum(i)=IRSub_calibrated_cut_one(i)+IRSub_calibrated_cut_two(i);
    end
    %  window fade
    %% all together
    nfft                     =length(IRSub_calibrated_cut_all);
    fade                    = 512;
    fadeWin                 = hann( 2 * fade );
    fadeIn                  = fadeWin( 1 : end/2 );
    fadeOut                 = fadeWin( end/2+1 : end );
    zeroSamples             = nfft - 2*fade;
    win                     = [ fadeIn ; ones( zeroSamples, 1 ) ; fadeOut ];
    irSub_win               = IRSub_calibrated_cut_all .* win;
  
    % FFT 
    irFft                   = fft( irSub_win, nfft )/nfft; 
    irFft                   = 2*irFft( 1 : nfft / 2 + 1 ); 
    mean_w                  = mean(fadeWin);
    winFactor               = 1/mean_w;
    irFft                   = irFft*winFactor;
    p0                      = 0.00002; % [Pa]
    irFftDbCorrected        = 20*log10( abs( irFft ) / p0 );

    % PLOT
    f = ((1:floor(nfft)/2+1)'./nfft).*fs;
    
    % smooth
    Noct = 11; %1/Noct octave band
    %Z_sub = iosr.dsp.smoothSpectrum(abs(irFftDbCorrected(1:length(irFftDbCorrected))),f,Noct);
     Z_sub = abs(irFftDbCorrected(1:length(irFftDbCorrected)))
    
    % plot ir
    figure()
    time=linspace(0, length(irSub_win)/fs, length(irSub_win));
    subplot( 2, 1, 1 );
    plot(time, -irSub_win );
    xlabel('time [s]');
    yticks([]);
    title( 'Subwoofers, both excited together' );
    grid on;
    
    subplot( 2, 1, 2 )
    semilogx( f, Z_sub);
    grid on;
    xlabel('Hz');
    ylabel('[dB]');
    xticks([20 30 50  100 200 500 1000 ]);
    xticklabels({'20', '30', '50','100','200','500','1000'});
    xlim([10 500]);
    
    %% singles summed
    irSub_win_sum               = IRSub_calibrated_cut_sum .* win;

    % FFT 
    irFft_sum         = fft( irSub_win_sum, nfft )/nfft; 
    irFft_sum        = 2*irFft_sum( 1 : nfft / 2 + 1 ); 
    irFft_sum        = irFft_sum*winFactor;
    irFftDbCorrected_sum       = 20*log10( abs( irFft_sum ) / p0 );

    % PLOT
  
    % smooth
    Noct = 6; %1/Noct octave band
    Z_sub_sum = iosr.dsp.smoothSpectrum(abs(irFftDbCorrected_sum(1:length(irFftDbCorrected_sum))),f,Noct);
    
    % plot ir
    figure()
    time=linspace(0, length(irSub_win_sum)/fs, length(irSub_win_sum));
    subplot( 2, 1, 1 );
    plot(time, -irSub_win_sum );
    yticks([]);
    xlabel('Time [s]');
    ylabel ('Amplitude');
    title( 'Subwoofers Impulse Response' );
    grid on;
    
    subplot( 2, 1, 2 )
    semilogx( f, Z_sub_sum);
    grid on;
    ylabel('Amplitude [dB]');
    xlabel('Frequency [Hz]');
    xticks([20 30 50   100 200 500 1000 ]);
    xticklabels({'20', '30', '50','100','200','500','1000'});
    xlim([10 500]);


    audiowrite(fullfile(folderPath_calibrated, 'subwoofer_all.wav'), rescale(IRSub_calibrated_cut_all, -1, 1), fs);
    audiowrite(fullfile(folderPath_calibrated, 'subwoofer_sum.wav'), rescale(IRSub_calibrated_cut_sum, -1, 1), fs);
