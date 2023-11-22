addpath(genpath(pwd));

load('sum_1.mat');
sum_1=Z_sum_cal;

load('sum_2.mat');
sum_2=Z_sum_cal;

load('sum_3.mat');
sum_3=Z_sum_cal;

load('sum_4.mat');
sum_4=Z_sum_cal;

load('sum_5.mat');
sum_5=Z_sum_cal;

load('sum_6.mat');
sum_6=Z_sum_cal;

nfft=5001;
f = ((1:floor(nfft)/2+1)'./nfft).*fs;
freqs= ((1:length(Z_sum_cal))'./length(Z_sum_cal)).*fs;
figure()
loglog(f, sum_1, f, sum_2, f, sum_3, f, sum_4, f, sum_5, f, sum_6); 
title('calibrated')
legend(' TV ',  'cover TV', 'no TV', 'no TV cover door' ,' no seat' ,'no seat no pedal');
xlabel('Hz');
ylabel('HZ');
ylim( [ 70 120] )
xticks([ 100 200 500 1000 2000 4000 10000])
xticklabels({'100','200','500','1000','2000', '4000', '10000'})
xlim([20 20000])