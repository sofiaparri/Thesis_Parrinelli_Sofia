%% trovare armoniche sferiche SH= sum( x*h)
addpath(genpath(pwd));
invSweep=audioread('InvSineSweepMono32Bit48000_5sec_3secSilence.wav');
%invSweep=audioread('InvSineSweep_22_22k_1s_3sSilence_fadein_fadeout.wav');   %for predist signals
encoding_matrix=audioread('em64-4096-64ch-24bits-lownoise-6thOrd.wav');
encoding_dim=size(encoding_matrix);
encod_filter_length=encoding_dim(1)/64;



first_cut=290681-212; %NON predistorted
%first_cut=98998-212;%predistorted
%first_cut=97519%predistorted
second_cut=4096;
order=6;
n_sh=49;
n_sp=25;
n_mic=64;   
fs=48000;
%aliasing frequency
l=0.025; %capsule distance
f_al=343/(4*l);
filter_size_second=(second_cut+1)+encod_filter_length-1; %SH convolution
IR_matrix_fft=zeros(n_sp, n_mic, filter_size_second);

%% build IR matrix [sp x mic x f]
for sp=1:n_sp      %for each speaker  
    %filename = strcat('\Measurement_20240108\VR_em64_Measure_20240108_Gain_-9dBMeasureType_1_20240108\-Channel_', int2str(sp), '.wav');
    filename = strcat('\Measurement_20240108\VR_em64_Measure_20240108_Gain_-15dB_NoPreDISTMeasureType_1_20240108\-Channel_', int2str(sp), '.wav');
    
    %filename = strcat('VirtualRoomChannel_', int2str(sp), '.wav');
    audioData = audioread(filename);   
    for mic=1:n_mic  %for each microphone
        
        filter_size=length(audioData)+length(invSweep)-1;
        audioData_fft=fft(audioData(:,mic), filter_size);
        invSweep_fft=fft(invSweep, filter_size);
        IRaudioData_fft=audioData_fft.*invSweep_fft;
        IRaudioData=ifft(IRaudioData_fft);
    
        %cut IR
        IRaudioData_cut=IRaudioData(first_cut:first_cut+second_cut);
        IRaudioData_fft_cut=fft(IRaudioData_cut, filter_size_second);
        IR_matrix_fft(sp, mic, :)=IRaudioData_fft_cut;        
     end
 end



%% build A' [sp x mic x f]

A_effective=zeros(n_sp, n_sh, filter_size_second);
A_effective_fft=zeros(n_sp, n_sh, filter_size_second);
mic_enc=zeros(49, 64, encod_filter_length);
for sp=1:n_sp      %for each speaker
    for sh=1:n_sh
       for mic=1:n_mic  %for each microphone
          
          %extract proper filter and cut as length of IR_matrix
          start_filter=((mic-1)*encod_filter_length)+1;
          encoding_filter=encoding_matrix(start_filter:start_filter+encod_filter_length-1, sh);
          encoding_filter_fft_cut=fft(encoding_filter, filter_size_second);
          %build A' matrix
          current_harmonic=squeeze(IR_matrix_fft(sp, mic, :)).*encoding_filter_fft_cut;
          toSum=squeeze(A_effective_fft(sp, sh, :));
          A_effective_fft(sp, sh, :)=toSum+(current_harmonic);
          %A_effective_fft(sp, sh, :)=fft(A_effective(sp, sh, :));
          %mic_enc(sh,mic,  :)=encoding_filter_fft_cut;
      end  
    end
end


%%% prova x filter_evaluation
%for kk=1:nBins
%    %[49x64] x [64 x 25]
%    IRfft = squeeze(IR_matrix_fft(:,:,kk)); 
%    IRfft = permute(IRfft, [2 1]);
%    y_recon_kk = mic_enc(:,:,kk) * IRfft;   %[49x64
%    % ] x [64 x 25]
%end
%% load A ideal =Y_N
%[~, dirs] = getTdesign_order(6); %6=degree of the t-design
azimuth=load("misure_set_prova\azimuth_Vroom.mat");
azimuth=azimuth.azimuth;
elevation=load('misure_set_prova\elevation_Vroom.mat');
elevation=elevation.elevation;
dirs=zeros(25, 2);
dirs(:, 1)=deg2rad(azimuth);
dirs(:, 2)=deg2rad(elevation);

[vecs_order(:,1), vecs_order(:,2), vecs_order(:,3)]=sph2cart(dirs(:,1), dirs(:,2), 1);
 %Plot dei punti discretizzati
figure()
scatter3(vecs_order(:,1), vecs_order(:,2), vecs_order(:,3), 100, 'blue');
ordine_punti = 1:size(vecs_order, 1);
for i = 1:size(vecs_order, 1)
    text(vecs_order(i, 1), vecs_order(i, 2), vecs_order(i, 3), num2str(ordine_punti(i)), 'FontSize', 10, 'HorizontalAlignment', 'center');
end
xlabel('X');
ylabel('Y');
zlabel('Z');
hold on 
% Aggiunta del rettangolo in posizione (0, 0, altezza_fino_a_metà)
altezza = max(vecs_order(:, 3)) / 2;
scatter3(0,0,0,150, 'r');
hold on 
sphere()
s = findall(gca, 'type', 'surf');
set(s, 'FaceColor', 'k', 'FaceAlpha', 0.01, 'EdgeAlpha', 0.1)




[ ~, dirs_T] = getTdesign(7);
[ ~, dirs_T7] = getTdesign(8);
[ ~, dirs_T9] = getTdesign(9);

[dirs_T_c(:,1), dirs_T_c(:,2), dirs_T_c(:,3)]=sph2cart(dirs_T(:,1), dirs_T(:,2), 1);
[dirs_T_c7(:,1), dirs_T_c7(:,2), dirs_T_c7(:,3)]=sph2cart(dirs_T7(:,1), dirs_T7(:,2), 1);
[dirs_T_c9(:,1), dirs_T_c9(:,2), dirs_T_c9(:,3)]=sph2cart(dirs_T9(:,1), dirs_T9(:,2), 1);

triangulationObject = delaunay(dirs_T_c7(:,1), dirs_T_c7(:,2), dirs_T_c7(:,3));


% convert from azi-elev to azi-inclination
%[ ~, dirs_T] = getTdesign_order(7);
%tdesign_dirs = [dirs_T(:,1) pi/2-dirs_T(:,2)];
%Y_tD = getSH(6, tdesign_dirs, 'complex');

% convert from azi-elev to azi-inclination
dirs_real=[dirs(:,1),  pi/2-dirs(:,2)];

Y_N = getSH(6, dirs_real, 'complex');


%% spatial correlation
minA=min(real(A_effective_fft(:)));
maxA=max(real(A_effective_fft(:)));
Y_N_real=rescale(real(Y_N), (minA), (maxA));
Y_N_rescaled=complex(Y_N_real, angle(Y_N));

sc_v=zeros(n_sh,filter_size_second);

for h=1:n_sh
    
    for f=1:floor(filter_size_second)
        num=0;
        den=0;
        for i=1:n_sp
            num=num+A_effective_fft(i, h, f)'.*Y_N(i,h);
            %num=num+Y_tD(i, h)'.*Y_N(i,h);
            den=den+sqrt(Y_N(i, h)'.*Y_N(i, h)).*sqrt (A_effective_fft(i,h, f)'.*A_effective_fft(i,h, f));
            %den=den+sqrt(Y_N(i, h)'.*Y_N(i, h)).*sqrt (Y_tD(i,h)'.*Y_tD(i,h));
        end
        sc_v(h, f)= num./den;
    end
end
sc_n=zeros(order-1,filter_size_second);
for f=1:floor(filter_size_second)
    last=0;
    for n=0:order 
        center=n+1;
        summation=0;
        for v=last+center-n:last+center+n
            
            summation=summation+abs(sc_v(v, f));
        end
        last=v;
    sc_n(n+1, f)=1/(2*n+1).*summation;
    end
end


f = (0:filter_size_second-1)*fs/(filter_size_second);        %asse delle frequenze 

Noct = 4; % octave band
frequenze_verticali = [0, 30, 400, 1000, 1800];
figure;

colori_ordine = lines(order + 1);
for i = 0:order
    Z = smoothSpectrum(sc_n(i+1,:), f, Noct);
    semilogx(f, Z, 'DisplayName', ['Order ' int2str(i)],  'Color', colori_ordine(i + 1, :));
    hold on;
end

hold on
for i = 1:length(frequenze_verticali)
    if i > 1
        xline(frequenze_verticali(i), 'k--', 'LineWidth', 1.5, 'DisplayName', [' Cutoff frequency for order ' num2str((i))],  'Color',colori_ordine(i,:));
   
    else     
    end
end

xlim([20 f_al]);
ylim([0 1]);
xlabel('Hz', 'FontSize', 13);
title('Spatial Correlation', 'FontSize', 13);
xticks([20 30 50 100 200 500 1000 2000]);
xticklabels({'20', '30', '50', '100', '200', '500', '1000', '2000'});
legend('show', 'FontSize', 13);

%% level difference


%A_effective_fft_rescaled=normalize(A_effective_fft, "norm");
%Y_N_rescaled=normalize(Y_N, "norm");
%Y_tD_resc=normalize(Y_tD, "norm");
ld_v=zeros(n_sh, filter_size_second);

for h=1:n_sh
    
    for f=1:filter_size_second
        summation=0;
        num=0;
        den=0;
        for i=1:n_sp-1
            %power of Y= |Y|^2= real(Y)^2+ imag(Y)^2 = abs(Y)^2
            num=(abs(Y_N(i,h ))).^2;          
            den=A_effective_fft_rescaled(i, h, f).*conj(A_effective_fft_rescaled(i, h, f));
           
            summation=summation+num./den;

        end
        ld_v(h, f)= 1/n_sp.*summation;
    end
end

ld_n=zeros(order-1, filter_size_second);

for f=1:filter_size_second
    last=0; 
    for n=0:order
        
        center=n+1;       
        summation=0;
        for v=last+center-n:last+center+n  
            
           summation=summation+abs(ld_v(v, f));
        end
        last=v;
    ld_n(n+1, f)=-10.*log((1/(2*n+1)).*summation);
    end
end


nBins=size(A_effective_fft, 3);
nFFT = 2*(nBins-1);

f = (0:nBins-1)*fs/nBins;
frequenze_verticali = [0, 30, 400, 1000, 1800];

Noct = 4; % octave band

figure;
for i = 0:order
    Z = smoothSpectrum(ld_n(i+1,:), f, Noct);
    semilogx(f,Z, 'DisplayName', ['Order ' int2str(i)]);
    hold on;
end
hold on
for i = 1:length(frequenze_verticali)
    if i > 1
        xline(frequenze_verticali(i), 'k--', 'LineWidth', 1.5, 'DisplayName', [' Cutoff frequency for order ' num2str((i))],  'Color',colori_ordine(i,:));   
    else     
    end
end
xlim([f(1) f_al]);
xlabel('Hz',  'FontSize', 13);
ylabel('dB',  'FontSize', 13);
xticks([20  50  100 200 500 1000 2000]);
xticklabels({'20', '50','100','200','500','1000', '2000',  'FontSize', 13});
ylim([ -120 0]);
title('Level Difference',  'FontSize', 13)
legend('show',  'FontSize', 13);






