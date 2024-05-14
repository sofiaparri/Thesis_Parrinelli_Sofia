%% extract sample out of phase for time alignment
%compute IR from inv sweep and rec sweep
% use pcb measures tweeter girati e predistorto

addpath(genpath(pwd));

file_path='\TESI_POLIMI\Thesis_Parrinelli_Sofia\Ambisonics_assessment\2024.02.26 - Misure VR-PCBmic\MeasureTest\Sweep_22-22k_0.2_0.2_10s+2s_-28dB_fLow80Hz'; 
    
[inv_sweep, fs]=audioread('\TESI_POLIMI\Thesis_Parrinelli_Sofia\Ambisonics_assessment\2024.02.26 - Misure VR-PCBmic\invSweep_22-22k_0.2_0.2_10s+2s_-6dB.wav');

n_ls=25; %all speaker signals

peaks=zeros(n_ls, 1);
fs=48000;

for i=1: n_ls
    [morel, fs] = audioread(fullfile(file_path, ['recSweep_',  int2str(i), '.wav']));
    morel=morel(1:end, 1);

    filter_size=length(morel)+length(inv_sweep)-1;
    inv_sweep_fft = fft(inv_sweep, filter_size);
    morel_fft = fft(morel, filter_size);
    
    IR_fft= morel_fft.* inv_sweep_fft;
    
    IR=ifft(IR_fft);

    [pks,locs] = findpeaks(abs(IR));
    [~, direct_pos]=max(pks);
    sample_peak=locs(direct_pos);
    peaks(i)=sample_peak;
end 

reference=min(peaks);
sample_difference=zeros(n_ls, 1);

for i=1:n_ls
    sample_difference(i)= peaks(i)-reference;
end

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


