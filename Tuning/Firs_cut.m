%% cut the filters to send to innosonik
addpath(genpath(pwd));

fir_length=2048;
pre_peak=150;

file_path='\TESI_POLIMI\Thesis_Parrinelli_Sofia\Tuning\Left_Tuning\FIRs\';
n_ls=25; 

    folderPath_cut = 'FIRs_cut_new'; 
       if ~isfolder(folderPath_cut)
           mkdir(folderPath_cut);
       end
for i=1: n_ls
    i
    [fir, fs] = audioread(fullfile(file_path, ['Filters IR',  int2str(i), '.wav']));

    [pks,locs] = findpeaks(fir);
    [~, in]=max(pks);
    sample_peak=locs(in);
    sample_cut=sample_peak-pre_peak;
    fir_cut=fir(sample_cut:sample_cut+fir_length-1);
    audiowrite(fullfile(folderPath_cut, ['FIR_cut', int2str(i), '.wav']), fir_cut,  fs, 'BitsPerSample',32);
   

end 

