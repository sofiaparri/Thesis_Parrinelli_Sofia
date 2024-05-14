% sommo tutte le armoniche sferiche A misurate   [25x49]

[ ~, dirs_T] = getTdesign(21);
dirs_real=[dirs_T(:,1),  pi/2-dirs_T(:,2)];
Y = getSH(40, dirs_real, 'complex');

Y_tot=zeros(49,1);
for i=1:49
    for u=1:size(dirs_real,1)
    Y_tot(i)=Y_tot(i)+Y(u,i);
    end
end


%Y_totSH=zeros(numel(dirs_real),1)
%v=(order+1)^2;
%for u=1:numel(dirs_real)
%    for x=1:v
%    Y_totSH(u)=Y_totSH(u)+Y(u,x);
%    end
%end

load('A''_NONpredist.mat');
A_sumInSH=zeros(49,8192);

for i=1:49 %sommo speaker
    for u=1:25
    A_sumInSH(i,:)=A_sumInSH(i,:)'+squeeze(A_effective_fft(u,i,:));
    end
    
end


[D, order] = ambiDecoder( rad2deg(dirs_T), 'MMD', true, 6); 
%analyzeDecoder(D, rad2deg(dirs_T), 'decoder', [1 1], 1, 1);
%h = gcf; h.Position(3) = 2*h.Position(3); h.Position(4) = 1.5*h.Position(4);
%subtitle(['Sampling Decoder - ' num2str(N) 'st-order - tetrahedral layout'])


decodedSumSH= A_sumInSH'*D';
decodedSumSH=permute(decodedSumSH, [ 2 1]);

[x, y, z] = sph2cart(dirs_T(:, 1), dirs_T(:, 2),1);
%figure()

%scatter3(x(:), y(:), z(:), 30, 'filled');
%ordine_punti = 1:size(x, 1);
%for i = 1:numel(x)
%    text(x(i), y(i), z(i), num2str(ordine_punti(i)), 'FontSize', 10, 'HorizontalAlignment', 'center');
%end

f = (0: length(decodedSumSH))*fs/( length(decodedSumSH)); %asse delle frequenze 
f_band=[63, 125, 500, 1000, 2000];
f_band_lowLimit=f_band/2;
f_band_upperLimit=f_band*2;

    
for band=1:length(f_band)
    [~, sample_low] = min(abs(f - f_band_lowLimit(band)));
    [~, sample_high] = min(abs(f - f_band_upperLimit(band)));
    sfera=zeros(length(x), 1);
    for d=1:length(x)
        for i=sample_low:sample_high
            sfera(d)=sfera(d)+decodedSumSH(d, i);
        end
        sfera(d)=sfera(d)/(sample_high-sample_low);
    end
%sfera=normalize(sfera, 'norm');
sfera  = 20*log10( abs( sfera ) / p0 );

    figure()
    scatter3(x(:), y(:), z(:), 60, abs(sfera),  'filled');
    title({['Reconstruction decoding in ' num2str(size(dirs_real,1)) ' t-design'] [num2str( f_band(band)) ' Hz octave band']});  
    axis equal;
    grid on;
    cb = colorbar(); 
    yl = ylabel(cb,'dB','FontSize',13);
    set(gca, 'XTickLabel', []);
    set(gca, 'YTickLabel', []);
    set(gca, 'ZTickLabel', []);
    clim([50 100])

    
end


%% freq dependent stop at 4th order
cutoffs = [ 400 1000 1800];
max_order = 4;
D_eigen = zeros(size(dirs_T, 1),(max_order+1)^2, max_order);
% f<400 Hz , 0 and 1st-order
D_eigen(:,1:2^2,1) = ambiDecoder( rad2deg(dirs_T), 'EPAD', 0, 1);
% 400<f<1000Hz, 2nd-order
D_eigen(:,1:3^2,2) = ambiDecoder( rad2deg(dirs_T), 'ALLRAD', 1, 2);
% 1000<f<1800Hz, 3rd-order
D_eigen(:,1:4^2,3) = ambiDecoder( rad2deg(dirs_T), 'ALLRAD', 1, 3);
% 1800<f, 4th-order
D_eigen(:,1:5^2,4) = ambiDecoder( rad2deg(dirs_T), 'ALLRAD', 1, 4);
% f>1800, 5th-order
%D_eigen(:,1:6^2,5) = ambiDecoder( rad2deg(dirs_T), 'allrad', 1, 5);
% f>1800, 6th-order
%D_eigen(:,1:7^2,6) = ambiDecoder( rad2deg(dirs_T), 'allrad', 1, 6);
%stop at 4th order
y_eigen = decodeHOA_N3D(permute(A_sumInSH( 1:5^2, :), [2 1]), D_eigen, cutoffs, fs);

[x, y, z] = sph2cart(dirs_T(:, 1), dirs_T(:, 2),1);
f = (0: length(y_eigen))*fs/( length(y_eigen)); %asse delle frequenze 
f_band=[63, 125, 500, 1000, 2000];
f_band_lowLimit=f_band/2;
f_band_upperLimit=f_band*2;


for band=1:length(f_band)
    [~, sample_low] = min(abs(f - f_band_lowLimit(band)));
    [~, sample_high] = min(abs(f - f_band_upperLimit(band)));
    sfera=zeros(length(x), 1);
    for d=1:length(x)
        for i=sample_low:sample_high
            sfera(d)=sfera(d)+y_eigen(i, d);
        end
        sfera(d)=sfera(d)/(sample_high-sample_low);
    end
%sfera=normalize(sfera, 'norm');
sfera  = 20*log10( abs( sfera ) / p0 );

        
    figure()
    scatter3(x(:), y(:), z(:), 60, abs(sfera),  'filled');
    title({ [num2str( f_band(band)) ' Hz octave band'], 'Decoding'});
    axis equal;
    grid on;
    colorbar;
    cb = colorbar(); 
    yl = ylabel(cb,'dB','FontSize',13);
    set(gca, 'XTickLabel', []);
    set(gca, 'YTickLabel', []);
    set(gca, 'ZTickLabel', []);
    clim([50 100])
end

%% trovare armoniche sferiche SH=sum( x*h)
addpath(genpath(pwd));
invSweep=audioread('InvSineSweepMono32Bit48000_5sec_3secSilence.wav');
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
IR_matrix_fft=zeros( n_mic, filter_size_second);
IR_matrix_time=zeros(n_sp, n_mic, encod_filter_length+1);
IRaudioData_fft_cut=zeros(n_mic, filter_size_second);

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
        IR_matrix_time(sp, mic, :)=IRaudioData_cut;
       
     end
end


IR_matrix_sumL=zeros(n_mic, encod_filter_length+1);
for mic=1:n_mic 
    for sp=1:n_sp
        toSum=squeeze(IR_matrix_time(sp, mic, :));
        IR_matrix_sumL(mic, :)=IR_matrix_sumL(mic, :)+toSum';
    end
        IRaudioData_fft_cut=fft(IR_matrix_sumL(mic, :), filter_size_second);
        IR_matrix_fft(mic, :)=IRaudioData_fft_cut; 
end

%% pressione sul mic
p0                      = 0.00002; % [Pa]
[xM, yM, zM]=Em_capsules;
f = (0: length(IR_matrix_fft))*fs/( length(IR_matrix_fft)); %asse delle frequenze 
f_band=[63, 125, 500, 1000, 2000];
f_band_lowLimit=f_band/2;
f_band_upperLimit=f_band*2;

figure()
for band=1:length(f_band)
    [~, sample_low] = min(abs(f - f_band_lowLimit(band)));
    [~, sample_high] = min(abs(f - f_band_upperLimit(band)));
    IR_average_octave_band=zeros(n_mic, 1);
    IR_average_octave_band_dB=zeros(n_mic, 1);
    for m=1:mic
        for i=sample_low:sample_high
            IR_average_octave_band(m)=IR_average_octave_band(m)+IR_matrix_fft(m, i);
        end
        IR_average_octave_band(m)=IR_average_octave_band(m)/(sample_high-sample_low);
        IR_average_octave_band_dB(m)  = 20*log10( abs( IR_average_octave_band(m) ) / p0 );

        
    end
%IR_average_octave_band=normalize(IR_average_octave_band, 'norm')
    [X, Y, Z]=sphere;
    r=4.2;
    X2 = X * r;
    Y2 = Y * r;
    Z2 = Z * r;
    
    figure()
    scatter3(xM, yM, zM, 100, abs(IR_average_octave_band_dB), 'filled');
    title({'Pressure perceived on 64 microphones',[ num2str( f_band(band)) ' Hz octave band']});
    axis equal;
    grid on;
    colorbar;
    clim([120 152])
    cb = colorbar(); 
    yl = ylabel(cb,'dB','FontSize',13);
    hold on
    surf(X2,Y2,Z2)
    s = findall(gca, 'type', 'surf');
    set(s, 'FaceColor', 'k', 'FaceAlpha', 0.01, 'EdgeAlpha', 0.1)
    set(gca, 'XTickLabel', []);
    set(gca, 'YTickLabel', []);
    set(gca, 'ZTickLabel', []);


end

 
%%  find A
A=zeros(n_sh, filter_size_second);
A_fft_sumInTime=zeros(n_sh, filter_size_second);
mic_enc=zeros(49, 64, encod_filter_length);
 for sh=1:n_sh
    for mic=1:n_mic  %for each microphone
       
       %extract proper filter and cut as length of IR_matrix
       start_filter=((mic-1)*encod_filter_length)+1;
       encoding_filter=encoding_matrix(start_filter:start_filter+encod_filter_length-1, sh);
       encoding_filter_fft_cut=fft(encoding_filter, filter_size_second);
       %build A' matrix
       current_harmonic=(IR_matrix_fft(mic, :))'.*encoding_filter_fft_cut;   
       A(sh, :)=A(sh, :)+ifft(current_harmonic)';
       A_fft_sumInTime(sh, :)=fft(A(sh, :));
       %mic_enc(sh,mic,  :)=encoding_filter_fft_cut;
   end  
 end
    