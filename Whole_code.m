close all;
clear all;
clc;

addpath(genpath(pwd));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load measurements

    path_inv_sin='\TESI_POLIMI\Thesis_Parrinelli_Sofia\Ambisonics_assessment\Measures\invSweep_22-22k_0.2_0.2_10s+2s_-6dB.wav';
    invSweep=audioread(path_inv_sin);

    pat_enc_matrix='em64-4096-64ch-24bits-lownoise-6thOrd.wav';
    encoding_matrix=audioread(pat_enc_matrix);
    encoding_dim=size(encoding_matrix);

    space_before_peak=200;
    first_cut=482114; % to be defined basing on the response
    second_cut=4096;
    order=6;
    n_sh=49;
    n_sp=25;
    n_mic=64;   
    fs=48000;

    l=0.025;             % capsule distance
    f_al=343/(4*l);      % aliasing frequency
    encod_filter_length=encoding_dim(1)/n_mic;
    filter_size_second=(second_cut+1)+encod_filter_length-1; % SH convolution
    IR_matrix_fft=zeros(n_sp, n_mic, filter_size_second);
    IR_matrix_time=zeros(n_sp, n_mic, encod_filter_length+1);

% Load directions
    
    azimuth=load("Directions_em_speakers\azimuth_Vroom.mat");
    azimuth=azimuth.azimuth;
    elevation=load('Directions_em_speakers\elevation_Vroom.mat');
    elevation=elevation.elevation;
    dirs=zeros(25, 2);
    dirs(:, 1)=deg2rad(azimuth);
    dirs(:, 2)=deg2rad(elevation);
    
    nfft=encod_filter_length+1;
    IR_matrix_aligned=zeros(n_sp, n_mic, nfft);
    IR_matrix_fft_aligned=zeros(n_sp, n_mic, filter_size_second);


    %  window fade
    fade                    = 10;
    fadeWin                 = hann( 2 * fade );
    fadeIn                  = fadeWin( 1 : end/2 );
    fadeOut                 = fadeWin( end/2+1 : end );
    zeroSamples             = nfft - 2*fade;
    win                     = [ fadeIn ; ones( zeroSamples, 1 ) ; fadeOut ];



paths = cell(4, 25);

for sp = 1:25

    paths{1, sp} = strcat('\TESI_POLIMI\Thesis_Parrinelli_Sofia\Ambisonics_assessment\Measures\Center\Sweep_22-22k_0.2_0.2_10s+2s_-28dB_Center_NoFIR\recSweepEM64_Center_', num2str(sp), '.wav');
    paths{2, sp} = strcat('\TESI_POLIMI\Thesis_Parrinelli_Sofia\Ambisonics_assessment\Measures\Center\Sweep_22-22k_0.2_0.2_10s+2s_-28dB_Center_WithFIR\recSweepEM64_Center_FIR_', num2str(sp), '.wav');
    paths{3, sp} = strcat('\TESI_POLIMI\Thesis_Parrinelli_Sofia\Ambisonics_assessment\Measures\Left\Sweep_22-22k_0.2_0.2_10s+2s_-28dB_Left_NoFIR\recSweepEM64_Left_NoFIR_', num2str(sp), '.wav');
    paths{4, sp} = strcat('\TESI_POLIMI\Thesis_Parrinelli_Sofia\Ambisonics_assessment\Measures\Left\Sweep_22-22k_0.2_0.2_10s+2s_-28dB_Left_WithFIR\recSweepEM64_Left_WithFIR_', num2str(sp), '.wav');
end

%% Build IR matrix [sp x mic x f] from em64
    for sp=1:n_sp    
        filename = paths{4, sp};
        audioData = audioread(filename);   

        for mic=1:n_mic 
            
            filter_size=length(audioData)+length(invSweep)-1;
            audioData_fft=fft(audioData(:,mic), filter_size);
            invSweep_fft=fft(invSweep, filter_size);
            IRaudioData_fft=audioData_fft.*invSweep_fft;
            IRaudioData=ifft(IRaudioData_fft);

            IRaudioData_cut=IRaudioData(first_cut:first_cut+second_cut);
            
            irWinPad_sum            = IRaudioData_cut .* win;  
            irFft                   = fft( irWinPad_sum, filter_size_second )/filter_size_second;   %qui cambia del tutto i valori
            %irFft                  = 2*irFft( 1 : floor(end) + 1 ); % non taglio per mantenere l'intero valore
            mean_w                  = mean(fadeWin);
            winFactor               = 1/mean_w;  % amplitude correction factor
            irFft                   = irFft*winFactor; % correction due to the window
            p0                      = 0.00002; % [Pa]
            irFftDbCorrected        = 20*log10( abs( irFft ) / p0 );
     

            IR_matrix_time(sp, mic, :)=irWinPad_sum;
            IRaudioData_fft_cut=irFft;
            IR_matrix_fft(sp, mic, :)=IRaudioData_fft_cut;   

            %%just for room parameters extraction
            %[pks,locs] = findpeaks(IRaudioData);
            %[~, in]=max(pks);
            %sample_peak=locs(in);
            %sample_cut=sample_peak-space_before_peak;
            %IR_matrix_aligned(sp, mic, :)=IRaudioData(sample_cut:sample_cut+encod_filter_length);
            %IR_matrix_fft_aligned(sp, mic, :)=fft(IR_matrix_aligned(sp, mic, :), filter_size_second);
            

        end
    end

%%  Pressure on the em array
    
    IR_sumSpeaker_matrix_fft=zeros( n_mic, filter_size_second);
    IR_matrix_sumL=zeros(n_mic, encod_filter_length+1);

        for mic=1:n_mic 
            for sp=1:n_sp
                toSum=squeeze(IR_matrix_time(sp, mic, :));
                IR_matrix_sumL(mic, :)=IR_matrix_sumL(mic, :)+toSum';
            end

            IR_matrix_sumL(mic, :)          =IR_matrix_sumL(mic, :)./25;
            IRaudioData_fft_cut_sum         =fft(IR_matrix_sumL(mic, :), filter_size_second)/filter_size_second;   % riapplicare correzione nello spettro dovuta alla finestra in tempo
            mean_w                          = mean(fadeWin);
            winFactor                       = 1/mean_w;  % amplitude correction factor
            IRaudioData_fft_cut_sum         = IRaudioData_fft_cut_sum*winFactor; % correction due to the window
            IR_sumSpeaker_matrix_fft(mic, :)=IRaudioData_fft_cut_sum; 

        end
    
    
    p0 = 0.00002; % [Pa]
    [xM, yM, zM]=Em_capsules;
    f = (0: length(IR_sumSpeaker_matrix_fft))*fs/( length(IR_sumSpeaker_matrix_fft)); 
    f_band=[4000 8000];
    f_band_lowLimit=f_band/sqrt(2);
    f_band_upperLimit=f_band*sqrt(2);

      %for m=1:mic
      % IR_average_octave_band_dB(m)= 20*log10(sqrt(mean(abs(IR_sumSpeaker_matrix_fft(m, f>f_band_lowLimit(band) & f<=f_band_upperLimit(band))).^2, 2))/ p0 );
      %end

    figure()
    for band=1:length(f_band)
        sample_low=find((abs(f-f_band_lowLimit(band))) == min(abs(f-f_band_lowLimit(band))));
        sample_high=find((abs(f-f_band_upperLimit(band))) == min(abs(f-f_band_upperLimit(band))));
    
        IR_average_octave_band_tot=zeros(n_mic, 1);
        IR_average_octave_band=zeros(n_mic, 1);
        IR_dB  = 20*log10( abs( IR_sumSpeaker_matrix_fft ) / p0 );
       %
      for m=1:mic
       
           for i=sample_low:sample_high
                  
                  IR_average_octave_band_tot(m)=IR_average_octave_band_tot(m)+IR_dB(m, i);
           end
           IR_average_octave_band_tot(m)=IR_average_octave_band_tot(m)/(sample_high-sample_low);
      end
        

        [X, Y, Z]=sphere;
        r=4.2;
        X2 = X * r;
        Y2 = Y * r;
        Z2 = Z * r;
        
        figure()
        scatter3(xM, yM, zM, 100, abs(IR_average_octave_band_tot), 'filled');
        title({'Pressure perceived on 64 microphones',[ num2str( f_band(band)) ' Hz octave band']});
        axis equal;
        grid on;
        colorbar;
    
        cb = colorbar(); 
        yl = ylabel(cb,'dB','FontSize',13);
        hold on
        surf(X2,Y2,Z2)
        s = findall(gca, 'type', 'surf');
        set(s, 'FaceColor', 'k', 'FaceAlpha', 0.01, 'EdgeAlpha', 0.1)
        set(gca, 'XTickLabel', []);
        set(gca, 'YTickLabel', []);
        set(gca, 'ZTickLabel', []);
        clim([30 60]);
    
    end

%% Y' extraction  (A)  

    A_effective_fft=zeros(n_sp, n_sh, filter_size_second);
    A_first_order_aligned=zeros(n_sp, filter_size_second);
    mic_enc=zeros(49, 64, encod_filter_length);

    for sp=1:n_sp     
        for sh=1:n_sh
           for mic=1:n_mic  
              
              %extract proper filter and cut as length of IR_matrix
              start_filter=((mic-1)*encod_filter_length)+1;
              encoding_filter=encoding_matrix(start_filter:start_filter+encod_filter_length-1, sh);
              encoding_filter_fft_cut=fft(encoding_filter, filter_size_second);
              %build A' matrix
              current_harmonic=squeeze(IR_matrix_fft(sp, mic, :)).*encoding_filter_fft_cut;
              toSum=squeeze(A_effective_fft(sp, sh, :));
              A_effective_fft(sp, sh, :)=toSum+(current_harmonic);

          end  
        end
    end

%% Aligned response for the RIR analysis

    A_tot_first_order_aligned=zeros(size(A_first_order_aligned, 2), 1);
    for sp=1:n_sp     
           for mic=1:n_mic  
              
              %extract proper filter and cut as length of IR_matrix
              start_filter=((mic-1)*encod_filter_length)+1;
              encoding_filter=encoding_matrix(start_filter:start_filter+encod_filter_length-1, 1);
              encoding_filter_fft_cut=fft(encoding_filter, filter_size_second);
              %build A' matrix
              current_harmonic=squeeze(IR_matrix_fft_aligned(sp, mic, :)).*encoding_filter_fft_cut;
              A_first_order_aligned(sp, :)=A_first_order_aligned(sp, :)+ifft(current_harmonic)';
              
           end 
           A_tot_first_order_aligned=A_tot_first_order_aligned+A_first_order_aligned(sp, :)';
    end

    %saving folder
    folderPath = 'IR_aligned_first_order_roomParameters'; 
    if ~isfolder(folderPath)
        mkdir(folderPath);
    end

    wholePath= fullfile(folderPath, 'IR_time.wav');
    audiowrite(wholePath, rescale(A_tot_first_order_aligned, -1, 1),  fs);

%% Room parameters

   [rt,drr,cte, cte_mean, cfs,edt]=iosr.acoustics.irStats_toUse('sum_calibrated_whole.wav', 'graph', true, 'y_fit', [-5 -25], 'spec', 'full');

    figure();
    bar( rt);
    title({'Reverberation Time T20'});
    ylabel('time [s]');
    xticklabels({'62.5', '125', '250', '500', '1000', '2000', '4000', '8000'});
    xlabel('Hz');
    ylim([0 0.2])
    
    figure();
    bar( edt);
    title({'EDT'});
    xticklabels({'62.5', '125', '250', '500', '1000', '2000', '4000', '8000'});
    ylabel('time [s]');
    xlabel('Hz');
    
    figure();
    bar(cte);
    ylabel('dB');
    xticklabels({'62.5', '125', '250', '500', '1000', '2000', '4000', '8000'});
    title({'C50'});
    xlabel('Hz');




%% Decoding

    A_sumInSH=zeros(size(A_effective_fft, 2), size(A_effective_fft, 3));
    
    for i=1:49
        for u=1:25
        A_sumInSH(i,:)=A_sumInSH(i,:)'+squeeze(A_effective_fft(u,i,:));
        end    
    end
    
    [ ~, dirs_T] = getTdesign(21);
    %dirs_real=[dirs_T(:,1),  pi/2-dirs_T(:,2)];
    %Y = getSH(40, dirs_real, 'complex');
   
    cutoffs = [ 400 1000 1800];
    max_order = 4;
    D_eigen = zeros(size(dirs_T, 1),(max_order+1)^2, max_order);
    % f<400 Hz , 0 and 1st-order
    D_eigen(:,1:2^2,1) = ambiDecoder( rad2deg(dirs_T), 'sad', 0, 1);
    % 400<f<1000Hz, 2nd-order
    D_eigen(:,1:3^2,2) = ambiDecoder( rad2deg(dirs_T), 'sad', 1, 2);
    % 1000<f<1800Hz, 3rd-order
    D_eigen(:,1:4^2,3) = ambiDecoder( rad2deg(dirs_T), 'sad', 1, 3);
    % 1800<f, 4th-order
    D_eigen(:,1:5^2,4) = ambiDecoder( rad2deg(dirs_T), 'sad', 1, 4);
    %stop at 4th order
    y_eigen = decodeHOA_N3D(permute(A_sumInSH( 1:5^2, :), [2 1]), D_eigen, cutoffs, fs);
    
    [x, y, z] = sph2cart(dirs_T(:, 1), dirs_T(:, 2),1);
    f = (0: length(y_eigen))*fs/( length(y_eigen)); %asse delle frequenze 
    f_band=[ 1000, 2000, 4000, 8000];
    f_band_lowLimit=f_band/sqrt(2);
    f_band_upperLimit=f_band*sqrt(2);
    
    A_in_oct_band=zeros(size(A_sumInSH, 1), length(f_band) );
    for band=1:length(f_band)    %somma e divisione normale essendo valore gain lineare

        [~, sample_low] = min(abs(f - f_band_lowLimit(band)));
        [~, sample_high] = min(abs(f - f_band_upperLimit(band)));
        sfera=zeros(length(x), 1);
        for d=1:length(x)
            for i=sample_low:sample_high
                sfera(d)=sfera(d)+y_eigen(i, d);
            end
            sfera(d)=sfera(d)/(sample_high-sample_low);
        end
       A_in_oct_band(:, band)=sfera(d);

       figure()
       scatter3(x(:), y(:), z(:), 60, abs(sfera),  'filled');
       title({ 'Decoding', [num2str( f_band(band)) ' Hz octave band']});
       axis equal;
       grid on;
       colorbar;
       cb = colorbar(); 
       yl = ylabel(cb,'Amplitude Factor','FontSize',13);
       set(gca, 'XTickLabel', []);
       set(gca, 'YTickLabel', []);
       set(gca, 'ZTickLabel', []);
       clim([0 4*10^(-5)]);
    
    end
%% SH in octave bands to plot
   f = (0: size(A_effective_fft, 3))*fs/( size(A_effective_fft, 3)); 
   f_band=[ 250, 1000, 4000];
   f_band_lowLimit=f_band/sqrt(2);
   f_band_upperLimit=f_band*sqrt(2);
   A_octave_band=zeros(size(A_effective_fft, 1), size(A_effective_fft, 2), size(f_band, 2));

    for band=1:length(f_band)
         A_octave_band(:, :, band)= (sqrt(mean(abs(A_effective_fft(:, :, f>f_band_lowLimit(band) & f<=f_band_upperLimit(band))).^2, 3)));
    end
    v=  1;         % spherical harmonic to plot
 

     Plot_SH_polarPattern(A_octave_band, dirs, v);

%% Ambi Assessment 

colors=[0.01 0.36 0.6; 0.22 0.61 0.77; 0.72 0.27 1.0; 0.47 0.67 0.19; 0.94 0.38 0.14; 0.93 0.69 0.13; 0.91 0.91 0.06];
f = (0: size(A_effective_fft, 3))*fs/( size(A_effective_fft, 3)); 
 
% Load Y ideal = Y_N  
    [vecs_order(:,1), vecs_order(:,2), vecs_order(:,3)]=sph2cart(dirs(:,1), dirs(:,2), 1);
    
    dirs_real=[dirs(:,1),  pi/2-dirs(:,2)];
    
    Y_N = getSH(6, dirs_real, 'complex');

A_rescaled = A_effective_fft./max(abs(A_effective_fft), [], 'all');
Y_rescaled = Y_N./max(abs(Y_N),[], 'all');

% Spatial Correlation
    

    sc_v=zeros(n_sh,filter_size_second);
    
    f = (0:filter_size_second-1)*fs/(filter_size_second); 

    %fq=10;
   %sample= floor(fq/size(A_effective_fft, 3));
   plot(real(Y_rescaled(:, 1)))
   hold on 
   plot(squeeze(real(A_rescaled(:, 1, 1000))))
    
    plot(real(Y_rescaled(:, 5)))
    hold on 
    plot(squeeze(real(A_rescaled(:, 5, 1000))))

    for h=1:n_sh        
        for fr=1:floor(filter_size_second)
            num=0;
            den=0;

            for i=1:n_sp
       
               num=num+A_rescaled(i, h, fr)'.*Y_rescaled(i,h);
               den=den+sqrt(Y_rescaled(i, h)'.*Y_rescaled(i, h)).*sqrt (A_rescaled(i,h, fr)'.*A_rescaled(i,h, fr));
            end
            sc_v(h, fr)= num./den;
        end
    end


    sc_n=zeros(order-1,filter_size_second);
    for fr=1:floor(filter_size_second)
        last=0;
        for n=0:order 
            center=n+1;
            summation=0;
            for v=last+center-n:last+center+n
                
                summation=summation+abs(sc_v(v, fr));
            end
            last=v;
        sc_n(n+1, fr)=1/(2*n+1).*summation;
        end
    end


    Noct = 6;                                                           
    frequenze_verticali = [0, 30, 400, 1000, 1800];
    figure;

    colori_ordine = lines(order + 1);
    for i = 0:order
        Z = smoothSpectrum(sc_n(i+1,:), f, Noct);
        semilogx1=semilogx(f, Z, 'DisplayName', ['Order ' int2str(i)],  'Color', colors(i + 1, :), 'LineWidth', 1);
        hold on;
    end

    hold on
    for i = 1:length(frequenze_verticali)
        if i > 2
            xline(frequenze_verticali(i), 'k--', 'LineWidth', 1.5, 'DisplayName', ['Freq. cut order ' num2str((i-1))],  'Color',colors(i,:));
       
        else     
        end
    end

    xlim([80 20000]);
    ylim([0 1]);
    xlabel('Frequency [Hz]');
    title('SC');
    xticks([20 30 50 100 200 500 1000 2000 4000 8000 16000]);
    xticklabels({'20', '30', '50', '100', '200', '500', '1000', '2000', '4000', '8000', '16000'});
    legend('show');
    grid on;

%% Level Difference


A_rescaled = A_effective_fft./max(abs(A_effective_fft), [], 'all');
Y_rescaled = Y_N./max(abs(Y_N),[], 'all');

 ld_v=zeros(n_sh, filter_size_second);
 for h=1:n_sh
     for fr=1:filter_size_second
         summation=0;
         num=0;
         den=0;
  
         for i=1:n_sp

             num=(abs(Y_rescaled(i,h ))).^2;          
             den=A_rescaled(i, h, fr).*conj(A_rescaled(i, h, fr));
            
             summation=summation+num./den;
 
         end
         ld_v(h, fr)= 1/n_sp.*summation;
     end
 end
 ld_n=zeros(order-1, filter_size_second);
 for fr=1:filter_size_second
     last=0; 
     for n=0:order
         
         center=n+1;       
         summation=0;
         for v=last+center-n:last+center+n  
             
            summation=summation+abs(ld_v(v, fr));
         end
         last=v;
         ld_n(n+1, fr)=-10.*log((1/(2*n+1)).*summation);
     end
 end
 Noct = 5;
 figure;
 for i = 0:order
     Z = smoothSpectrum(ld_n(i+1,:), f, Noct);
     semilogx(f,Z, 'DisplayName', ['Order ' int2str(i)], 'Color', colors(i+1, :),  'LineWidth', 1);
     hold on;
 end
 hold on
 for i = 1:length(frequenze_verticali)
     if i > 2
         xline(frequenze_verticali(i), 'k--', 'LineWidth', 1.5, 'DisplayName', ['Freq. cut order ' num2str((i-1))],  'Color',colors(i,:));   
     else     
     end
 end
 xlim([80 20000]);
 xlabel('Frequency [Hz]');
 title('LD');
 xticks([20 30 50 100 200 500 1000 2000 4000 8000 16000]);
 xticklabels({'20', '30', '50', '100', '200', '500', '1000', '2000', '4000', '8000', '16000'});
 legend('show');
 ylabel('[dB]');
 grid on;
 ylim([ -100 0]);

 %% Tuning: extract first order for each speaker singularly (omni) - delays
 peaks=zeros(n_sp, 1);
 fs=48000;
 %omni_component=zeros( 574148, 25);
 omni_component=zeros( 25, size(A_effective_fft, 3));
 folder_savings_omni='\TESI_POLIMI\Thesis_Parrinelli_Sofia\Saved_measures\IR_Central\IR_em_center_Nofilter';
 for i=1: n_sp
 
     omni_component(i, :)=squeeze(ifft(A_effective_fft(i, 1, :)));
     %[omni_component(:, i), fs]=audioread(['Saved_measures\IR_Central\IR_pcb_central_Nofilter\IR', int2str(i),  '.wav']);
     [pks,locs] = findpeaks(abs(omni_component(i, :)));
     [~, direct_pos]=max(pks);
     sample_peak=locs(direct_pos);
     peaks(i)=sample_peak;
     % save omni 
     %audiowrite(fullfile(folder_savings_omni, ['IR', int2str(i), '.wav']), omni_component(i, :),  fs, 'BitsPerSample',32);
 %"C:\Users\User\Desktop\TESI_POLIMI\Thesis_Parrinelli_Sofia\Saved_measures\IR_Central\IR_pcb_central_Nofilter\IR1.wav"
 end 
 peaks(3)=704;   % nella posizione a sinistra ci sono riflessioni alte, quindi prendo picco a mano
 reference=max(peaks);
 sample_difference=zeros(n_sp, 1);
 
 
 for i=1:n_sp
     sample_difference(i)= reference-peaks(i);
 end
 
%figure();
%plot(omni_component(sample_difference==0,:));
%hold on
%plot(omni_component(sample_difference==max(sample_difference), :));

 figure()
 plot(sample_difference, 'o');
 hold on
 yline(0);
 ylabel('Samples');
 xlabel('Speaker');
 xticks([1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25  50 ]);
 xticklabels({'1', '2','3','4','5','6', '7','8', '9','10','11','12','13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', '25',  'FontSize', 13});
 
 time_diff=sample_difference./fs;
 
 figure()
 plot(time_diff, 'o');
 hold on
 yline(0);
 ylabel('Time [s]');
 xlabel('Speaker');
 xticks([1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25  50 ]);
 xticklabels({'1', '2','3','4','5','6', '7','8', '9','10','11','12','13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', '25',  'FontSize', 13});









