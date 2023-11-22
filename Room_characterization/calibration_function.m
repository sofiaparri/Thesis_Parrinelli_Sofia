function [Z_sum_cal]=calibration_function (calRec, first_cut, second_cut, n_ls, file_path, inv_sweep, choice, opzione) 
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
    nfft     = 5001;
    morels=struct;

    %  window fade
    fade                    = 10;
    fadeWin                 = hann( 2 * fade );
    fadeIn                  = fadeWin( 1 : end/2 );
    fadeOut                 = fadeWin( end/2+1 : end );
    zeroSamples             = nfft - 2*fade;
    win                     = [ fadeIn ; ones( zeroSamples, 1 ) ; fadeOut ];


    %% calibrated responses - SUM, da cambiare filtro inverso per non predist
 if(choice ~= 9 && choice ~= 11 )

    for i=1:n_ls
        [morel, fs] = audioread(fullfile(file_path, ['-Channel_',  int2str(i), '.wav']));
        if choice==7||choice==10
            morel=morel(1:end, 1);
        end
        morelCal = morel * calFactor;

        filter_size=length(morelCal)+length(inv_sweep)-1;     
        inv_sweep_fft = fft(inv_sweep, filter_size);
        morel_fft = fft(morelCal, filter_size);
        
        IR_fft= morel_fft.* inv_sweep_fft;
        
        %in time and align
        IR=ifft(IR_fft);
         
        [pks,locs] = findpeaks(IR);
        [~, in]=max(pks);
        sample_peak=locs(in);
        sample_cut=sample_peak-first_cut;
        IR=IR(sample_cut:end);

        field=strcat(['IR', int2str(i)]);
        morels.(field)=IR;

    end 


    % grid plots - frequencies - cut the single morels
    num_righe = 5;
    num_colonne = 5;
    save_singles=struct; %salvo i segnali smoothed per plot
  fig=figure;
  for i = 1: n_ls
      %cut 
      sig_IR=morels.(strcat(['IR', int2str(i)]));
      [pks,locs] = findpeaks(sig_IR);
      [~, in]=max(pks);
      sample_peak=locs(in);
      sample_cut=sample_peak-first_cut;
      sig_IR_cut=sig_IR(sample_cut:sample_cut+second_cut);
      % window and FFT - correct magnitude
      irWinPad_sum            = sig_IR_cut .* win;  
     irFft                   = fft( irWinPad_sum, nfft )/nfft;
     irFft                   = 2*irFft( 1 : floor(end / 2) + 1 );
     mean_w                  = mean(fadeWin);
     winFactor               = 1/mean_w;  %amplitude correction factor
     irFft                   = irFft*winFactor; %correction due to the window
     p0                      = 0.00002; % [Pa]
     irFftDbCorrected        = 20*log10( abs( irFft ) / p0 );
 
 % PLOT
     f = ((1:floor(nfft)/2+1)'./nfft).*fs;
     subplot(num_righe, num_colonne, i);
     padding = 0.05; 
     margin=0.13;
     subaxis(num_righe, num_colonne, i, 'Spacing', padding, 'MarginLeft', margin);
    
     
     % smooth
     Noct = 5; %1/Noct octave band
     Z = iosr.dsp.smoothSpectrum(irFftDbCorrected,f,Noct);
     
     % plot
     semilogx(f,Z)
     title([ num2str(i)]); 
     xticks([  100 200 500 1000 2000 4000]) ;
     xticklabels({'100' '200','500','1k','2k', '4k'});
     xlim( [ 30 24000 ] )
     ylim( [20 max(Z)+15] )
     field=strcat(['IR', int2str(i)]);
     save_singles.(field)=Z;
 end
 han=axes(fig,'visible','off'); 
 han.Title.Visible='on';
 han.XLabel.Visible='on';
 han.YLabel.Visible='on';
 ylabel(han,'dB');
 xlabel(han,'Hz');

   %figure(); %time plots
   %for i = 1: n_ls   
   %    subplot(num_righe, num_colonne, i);
   %    margin = 0.06; %  margine tra i subplot 
   %    padding = 0.003; %  spazio dai bordi 
   %    subaxis(num_righe, num_colonne, i, 'Spacing', margin, 'Padding', padding);
   %   
   %    
   %    % plot
   %    semilogx(irWinPad_sum)
   %    title(['LS ' num2str(i)]); 
   %    xticks([ 100 200 500 1000 2000 4000]) ;
   %    xticklabels({'100','200','500','1k','2k', '4k'});
%
   %end
    %prova plot tutte casse assieme
   %nfft=5001;
   %f = ((1:floor(nfft)/2+1)'./nfft).*fs;
   %figure()
   %for i=1:n_ls
   %    loglog(f, save_singles.(strcat(['IR', int2str(i)]))); 
   %    hold on
   %end
   %title('single morels')
   %xlabel('Hz')
   %ylim( [ 70 120] )
   %%legend('1', '2', '3', '4', '5'...);
   %xticks([ 100 200 500 1000 2000 4000 10000])
   %xticklabels({'100','200','500','1000','2000', '4000', '10000'})
   %xlim([20 20000])
%
    %% build total: cut all at the same length

    [length_total,~]=min(structfun(@length,morels));
    total_sum_calibrated=zeros(length_total, 1);
    for i=1:n_ls
        field=strcat(['IR', int2str(i)]);
        morels.(field)=morels.(field)(1:length_total, 1);
        total_sum_calibrated=total_sum_calibrated+morels.(field);
    end
    
    %cut the total
    [pks,locs] = findpeaks(total_sum_calibrated);
    [~, in]=max(pks);
    sample_peak=locs(in);
    sample_cut=sample_peak-first_cut;
    total_sum_calibrated_cut=  total_sum_calibrated(sample_cut:sample_cut+second_cut);

    %  window fade
    irWinPad_sum                = total_sum_calibrated_cut .* win;
    
    % FFT 
    irFft                   = fft( irWinPad_sum, nfft )/nfft;  % need to normalize FFTs by the number of sample you need to normalize FFTs by the number of sample 
    irFft                   = 2*irFft( 1 : floor(end / 2) + 1 ); % multiply after the energy split in two
    mean_w                  = mean(fadeWin);
    winFactor               = 1/mean_w;  %amplitude correction factor
    irFft                   = irFft*winFactor; %correction due to the window
    p0                      = 0.00002; % [Pa]
    irFftDbCorrected        = 20*log10( abs( irFft ) / p0 );
    
    %% PLOT
    %f = ((1:floor(nfft)/2+1)'./nfft).*fs;
    %
    %% smooth
    %Noct = 5; %1/Noct octave band
    %Z_sum_cal = iosr.dsp.smoothSpectrum(abs(irFftDbCorrected(1:length(irFftDbCorrected))),f,Noct);
%
    %% plot ir
    %time=linspace(0, length(irWinPad_sum)/fs, length(irWinPad_sum));
    %figure()
    %subplot( 2, 1, 1 )
    %plot( time, irWinPad_sum )
    %xlabel('time [s]')
    %grid on
    %set(gca,'YTick',[])
    %xlim( [ 0 0.05 ] )
    %
    %subplot( 2, 1, 2 )
    %semilogx( f, Z_sum_cal)
    %grid on
    %xlim( [ 20 24000 ] )
    %ylim([80 120])
    %%ylim( [ min(Z_sum_cal) max(Z_sum_cal)+10] )
    %xlabel('Hz')
    %ylabel('dB')
    %%legend(' corrected' , 'non corrected')
    %xticks([ 100 200 500 1000 2000 4000 10000])
    %xticklabels({'100','200','500','1000','2000', '4000', '10000'})
    audiowrite(fullfile(folderPath_calibrated, 'sum_calibrated_whole.wav'), rescale(total_sum_calibrated_cut, -1, 1), fs);
   return;
 end 
    %% calibrated responses - single 

   switch choice
   case 1
       disp('con TV');
       folder_path_all='\measures\TV\Virtual_Room_Charaterization_AllAtOnceTV_20231019\-_AllAtOnce.wav';
   case 2
       folder_path_all='\measures\CoverTV\Virtual_Room_CoverTV_NoHeadrest_AllAtOnceMeasureType_2_20231023\-_AllAtOnce.wav'; 
       disp('covered TV');
   case 3
       folder_path_all=('\measures\NoTV\Virtual_Room_NO_TV_NoHeadrest_AllAtOnceMeasureType_2_20231026\-_AllAtOnce.wav');
       disp('no TV');
   case 4
       folder_path_all=('\measures\NoTV_CoverDoor\Virtual_Room_NO_TV_CoverDoor_NoHeadrest_AllAtOnceMeasureType_2_20231026\-_AllAtOnce.wav')
       disp('no TV covered door');
   case 9
        switch(opzione)
            case 1 
                    folder_path_all=('\measures\single_morels\Spk_9_1m_sweep-30dB_NoGrill.wav');
            case 2 
                    folder_path_all=('\measures\single_morels\Spk_9_1m_sweep-30dB.wav');
            case 3 
                    folder_path_all=('\measures\single_morels\Spk_7_1m_sweep-30dB_NoGrill_Predist.wav');
            case 4 
                    folder_path_all=('\measures\single_morels\Spk_7_1m_sweep-30dB_NoGrill.wav');
            case 5 
                    folder_path_all=('\measures\single_morels\Spk_7_1m_sweep-30dB_Grill_Predist.wav');
            case 6 
                    folder_path_all=('\measures\single_morels\Spk_7_1m_sweep-30dB.wav');
        end
        
    case 11
        balloon_analysis(file_path, calFactor, first_cut, second_cut);
        return;
    end

    
    [AllAtOnce, fs] = audioread(folder_path_all);
    AllAtOnce_calibrated = AllAtOnce * calFactor;
    filter_size=length(AllAtOnce_calibrated)+length(inv_sweep)-1;
    
    inv_sweep_fft = fft(inv_sweep, filter_size);
    AllAtOnce_calibrated_fft = fft(AllAtOnce_calibrated, filter_size);
    
    %moltiplication
    IRAllAtOnce_calibrated_fft= AllAtOnce_calibrated_fft.* inv_sweep_fft;
    
    %in time and cut
    IRAllAtOnce_calibrated=ifft(IRAllAtOnce_calibrated_fft);
    [pks,locs] = findpeaks(IRAllAtOnce_calibrated);
    [M, in]=max(pks);
   sample_peak=locs(in);
   sample_cut=sample_peak-first_cut;
   if choice==8
       IRAllAtOnce_calibrated_cut=IRAllAtOnce_calibrated(sample_cut:sample_cut+500);
   else
    IRAllAtOnce_calibrated_cut=IRAllAtOnce_calibrated(sample_cut:sample_cut+second_cut);
   end
    nfft     = length(IRAllAtOnce_calibrated_cut);
    %  window fade
    fade                    = 10;
    fadeWin                 = hann( 2 * fade );
    fadeIn                  = fadeWin( 1 : end/2 );
    fadeOut                 = fadeWin( end/2+1 : end );
    zeroSamples             = nfft - 2*fade;
    win                     = [ fadeIn ; ones( zeroSamples, 1 ) ; fadeOut ];
    irALLWinPad             = IRAllAtOnce_calibrated_cut .* win;
  
    % FFT 
    irFft                   = fft( irALLWinPad, nfft )/nfft; 
    irFft                   = 2*irFft( 1 : nfft / 2 + 1 ); 
    mean_w                  = mean(fadeWin);
    winFactor               = 1/mean_w;
    irFft                   = irFft*winFactor;
    p0                      = 0.00002; % [Pa]
    irFftDbCorrected        = 20*log10( abs( irFft ) / p0 );

    % PLOT
   
    
    % smooth
    Noct = 5; %1/Noct octave band
    Z_all_cal = iosr.dsp.smoothSpectrum(abs(irFftDbCorrected(1:length(irFftDbCorrected))),f,Noct);
    
    % plot ir
    figure()
    time=linspace(0, length(irALLWinPad)/fs, length(irALLWinPad));
    subplot( 2, 1, 1 )
    plot(time, irALLWinPad )
    title( 'IR trimmed, windowed, padded' )
    grid on
    xlim( [ 0 0.05] )
    
    subplot( 2, 1, 2 )
    semilogx( f, Z_all_cal)
    grid on
    xlim( [ 20 24000 ] )
    ylim( [ 80 120 ] )
    xlabel('Hz')
    xticks([ 100 200 500 1000 2000 4000 10000])
    xticklabels({'100','200','500','1000','2000', '4000', '10000'})
    xlim([20 20000])
    
    audiowrite(fullfile(folderPath_calibrated, 'single_ir_calibrated.wav'), irALLWinPad, fs);

end
