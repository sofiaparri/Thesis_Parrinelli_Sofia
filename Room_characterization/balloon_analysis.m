function balloon_analysis(file_path, calFactor, first_cut, second_cut )
    addpath(genpath(pwd));
    microphone='PCB.wav';
    folderPath_Ballons = 'IR_Balloons_cut'; 
       if ~isfolder(folderPath_Ballons)
           mkdir(folderPath_Ballons);
       end
    [cover_top, fs] = audioread(fullfile(file_path, 'Cover/Baloon_OnTOP', microphone));
    cover_back = audioread(fullfile(file_path, 'Cover/Baloon_OnBACk', microphone));
    cover_front = audioread(fullfile(file_path, 'Cover/Baloon_OnFRONT', microphone));
    uncover_top = audioread(fullfile(file_path, 'NoCover/Baloon_OnTOP', microphone));
    uncover_back= audioread(fullfile(file_path, 'NoCover/Baloon_OnBACk', microphone));
    uncover_front = audioread(fullfile(file_path, 'NoCover/Baloon_OnFRONT', microphone));
    
    nfft     = 5001;
    min_length=length(uncover_front);
    files=zeros(6, min_length);
    %  window fade
    fade                    = 10;
    fadeWin                 = hann( 2 * fade );
    fadeIn                  = fadeWin( 1 : end/2 );
    fadeOut                 = fadeWin( end/2+1 : end );
    zeroSamples             = nfft - 2*fade;
    win                     = [ fadeIn ; ones( zeroSamples, 1 ) ; fadeOut ];
  
    files(4, :) = cover_top(1:min_length)  * calFactor;
    files(2, :) = cover_back(1:min_length) * calFactor;
    files(3, :) = cover_front(1:min_length) * calFactor;
    files(1, :) = uncover_top(1:min_length) * calFactor;
    files(5, :) = uncover_back(1:min_length) * calFactor;
    files(6, :) = uncover_front(1:min_length) * calFactor;
    %1= cover centrale
    %2= cover dietro
    %3= cover avanti
    %4-6 uguali non cover

    files_cut=zeros(6, nfft);
    %cut
    for i=1:6
     [pks,locs] = findpeaks(files(i, :));
     [M, in]=max(pks);
     sample_peak=locs(in);
     sample_cut=sample_peak-first_cut;
     files_cut(i, :)=files(i, sample_cut:sample_cut+second_cut);
    end
   %save to plot together
   central=zeros(nfft, 2);
   central( :, 1)=files_cut(1, :);
   central(:, 2)=files_cut(4, :);
   back=zeros(nfft, 2);
   back( :, 1)=files_cut(2, :);
   back(:, 2)=files_cut(5, :);
   front=zeros(nfft, 2);
   front( :, 1)=files_cut(3, :);
   front(:, 2)=files_cut(6, :);
   audiowrite(fullfile(folderPath_Ballons, 'central_cover.wav'), rescale(central(:,1), -1, 1), fs);
   audiowrite(fullfile(folderPath_Ballons, 'back_cover.wav'), rescale(back(:, 1), -1, 1),  fs);
   audiowrite(fullfile(folderPath_Ballons,'front_cover.wav'), rescale(front(:, 1), -1, 1), fs);
   audiowrite(fullfile(folderPath_Ballons,'central_NOcover.wav'), rescale(central(:,2), -1, 1), fs);
   audiowrite(fullfile(folderPath_Ballons,'back_NOcover.wav'), rescale(back(:, 2), -1, 1),  fs);
   audiowrite(fullfile(folderPath_Ballons,'front_NOcover.wav'), rescale(front(:, 2), -1, 1), fs);

  
      
   for i=1:3

       irALLWinPad             = files_cut(i, :) .* win';
 
       irFft                   = fft( irALLWinPad, nfft )/nfft; 
       irFft                   = 2*irFft( 1 : nfft / 2 + 1 ); 

       p0                      = 0.00002; % [Pa]
       irFftDbCorrected        = 20*log10( abs( irFft ) / p0 );

    % PLOT
    
       f = ((1:floor(nfft)/2+1)'./nfft).*fs;
      Noct = 5; %1/Noct octave band
      %Z_all_cal=abs(irFftDbCorrected)
      Z_all_cal = iosr.dsp.smoothSpectrum(abs(irFftDbCorrected),f',Noct);
    
      % plot ir
      time=linspace(0, length(irALLWinPad)/fs, length(irALLWinPad));
      subplot( 2, 1, 1 )
      plot(time, irALLWinPad )
      title( 'IR trimmed, windowed, padded' )
      grid on
      hold on
      legendInfo{i} = ['posizione', num2str(i)];
      
      subplot( 2, 1, 2 )
      semilogx( f, Z_all_cal)
      grid on
      xlabel('Hz')
      xlim([50, 10000])
      xticks([ 100 200 500 1000 2000 4000 10000])
      xticklabels({'100','200','500','1000','2000', '4000', '10000'})
      hold on
    end 

legend(legendInfo);
title('Plot covers');
hold off;

figure()
    for i=4:6

       irALLWinPad             = files_cut(i, :) .* win';
 
       irFft                   = fft( irALLWinPad, nfft )/nfft; 
       irFft                   = 2*irFft( 1 : nfft / 2 + 1 ); 

       p0                      = 0.00002; % [Pa]
       irFftDbCorrected        = 20*log10( abs( irFft ) / p0 );

    % PLOT
    %non cover in 3 pos
       f = ((1:floor(nfft)/2+1)'./nfft).*fs;
      Noct = 5; %1/Noct octave band
      Z_all_cal = iosr.dsp.smoothSpectrum(abs(irFftDbCorrected(1:length(irFftDbCorrected))),f',Noct);
    
      % plot ir
      time=linspace(0, length(irALLWinPad)/fs, length(irALLWinPad));
      subplot( 2, 1, 1 )
      plot(time, irALLWinPad )
      title( 'IR trimmed, windowed, padded' )
      grid on
      hold on
      legendInfo{i} = ['posizione', num2str(i)];
      
      subplot( 2, 1, 2 )
      semilogx( f, Z_all_cal)
      grid on
      xlabel('Hz')
      xlim([50, 10000])
      xticks([ 100 200 500 1000 2000 4000 10000])
      xticklabels({'100','200','500','1000','2000', '4000', '10000'})
      hold on
    end 

legend(legendInfo);
title('Plot non covers');
hold off;

figure() %position on top
    for i=1:3:6

       irALLWinPad             = files_cut(i, :) .* win';
 
       irFft                   = fft( irALLWinPad, nfft )/nfft; 
       irFft                   = 2*irFft( 1 : nfft / 2 + 1 ); 

       p0                      = 0.00002; % [Pa]
       irFftDbCorrected        = 20*log10( abs( irFft ) / p0 );

    % PLOT
       f = ((1:floor(nfft)/2+1)'./nfft).*fs;
      Noct = 5; %1/Noct octave band
      Z_all_cal = iosr.dsp.smoothSpectrum(abs(irFftDbCorrected(1:length(irFftDbCorrected))),f',Noct);
    
      % plot ir
      %time=linspace(0, length(irALLWinPad)/fs, length(irALLWinPad));
      %subplot( 2, 1, 1 )
      %plot(time, irALLWinPad )
      %title( 'IR trimmed, windowed, padded' ) 
      %grid on
      %hold on
      %legendInfo{i} = [ num2str(i)];
      
      %subplot( 2, 1, 2 )
      semilogx( f, Z_all_cal)
      grid on
      xlabel('Hz')
      xlim([50, 10000])
      xticks([ 100 200 500 1000 2000 4000 10000])
      xticklabels({'100','200','500','1000','2000', '4000', '10000'})
      hold on
    end 

legend(legendInfo);
title('Plot posizione centrale coperta e non');
hold off;


%% time plots
     
figure() %covered
    for i=1:3

       irALLWinPad             = files_cut(i, :) .* win';
 
      % plot ir
      time=linspace(0, length(irALLWinPad)/fs, length(irALLWinPad));
      subplot( 3, 1, i )
      plot(time, irALLWinPad )
      title( 'Covered TV Door, position', num2str(i) )
      xlim([0 0.08])
      grid on
      hold on
    end 
 
figure() %non covered
    for i=4:6
       [pks,locs] = findpeaks(files(i, :));
       [M, in]=max(pks);
       sample_peak=locs(in);
       sample_cut=sample_peak-first_cut;
       cover_top_cal_cut=files(i, sample_cut:sample_cut+second_cut);
 
       irALLWinPad             = cover_top_cal_cut .* win';
 
      % plot ir
      time=linspace(0, length(irALLWinPad)/fs, length(irALLWinPad));
      subplot( 3, 1, i-3 )
      plot(time, irALLWinPad )
      title( 'non covered TV Door, position', num2str(i) )
      xlim([0 0.08])
      grid on
      hold on
    end 

figure() %centrale
j=1;
    for i=1:3:6 

       irALLWinPad             = files_cut(i, :) .* win';
 
      % plot ir
      time=linspace(0, length(irALLWinPad)/fs, length(irALLWinPad));
      subplot( 2, 1, j )
      plot(time, irALLWinPad )
      title( num2str(i) )
      set(gca,'YTick',[])
      xlim([0 0.08])
      xlabel('time [s]')
      grid on
      hold on
      j=j+1;
    end 
end