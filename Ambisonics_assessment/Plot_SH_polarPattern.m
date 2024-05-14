function Plot_SH_polarPattern(A_octave_band, dirs, v)
%************************************************
%                Diagramma polare
%************************************************
num_punti = 100;
azimuth = linspace(0, 2*pi, num_punti)';    % se vogliamo plottare la sezione (elevation sarebbe 0), ci serve il valore esponenziale 
                                            % all'azimuth, quindi inverto
                                            % le direzioni per il calcolo
                                            % delle armoniche sferiche
elevazione = zeros( num_punti, 1);
%[azimuth, elevazione]=meshgrid(azimuth, elevazione);
%azimuth_colonna = reshape(azimuth, [], 1);
%elev_colonna = reshape(elevazione, [], 1);
%inclin_colonna=2/pi-elev_colonna;

dirsI = [azimuth, elevazione];

%indici_zero = find(elev_colonna == 0);


Y=zeros(size(azimuth, 1), 10);  %2 order+1 
Y(:, 1)=1;
Y(:, 2)=sin(azimuth)*cos(0);
Y(:, 3)=sin(0);
Y(:, 4)=cos(azimuth)*cos(0);
Y(:, 5)=sqrt(3/4).*sin(2.*azimuth)*cos(0).^2;
Y(:, 6)=sqrt(3/4).*sin(azimuth)*cos(2*0);
Y(:, 7)=(1/2).*(3.*(sin(0)).^2-1);
Y(:, 8)=sqrt(3/4).*cos(azimuth)*sin(2*0);
Y(:, 9)=sqrt(3/4).*cos(2.*azimuth)*cos(0).^2;
Y(:, 10)=sqrt(5/8).*sin(3.*azimuth)*cos(0).^3;

%Y = getSH(6, dirsI, 'real');
%[x, y, z]=sph2cart(azimuth_colonna, elev_colonna, (Y(:, 2)));
%scatter3(x, y, z)




dirA=8;%devo stampare solo quelle sul perimetro
thetaA= dirs(5:12, 1);    %Calcola base degli angoli
dirI=length(azimuth);%devo stampare solo quelle sul perimetro
thetaI= dirsI(:, 1);  
%theta=(0:2*pi/dir:2*pi)';   %
SPLmatrix_lin =abs(Y(:, v));% 10.^(SPLmatrix./20);
SPLmatrix_lin250 =(A_octave_band(5:12, v, 1));% 10.^(SPLmatrix./20);
SPLmatrix_lin2000 =(A_octave_band(5:12, v, 2));% 10.^(SPLmatrix./20);
SPLmatrix_lin4000 =(A_octave_band(5:12, v, 3));% 10.^(SPLmatrix./20);


maxVal = max(abs(Y(:, 1)));
maxVal_tot = max(max(max(A_octave_band(5:12, :, :))));


thetaI(end+1) = thetaI(1); % Aggiungi l'ultimo angolo uguale al primo
SPLmatrix_lin(end+1) = SPLmatrix_lin(1); % Aggiungi l'ultimo valore uguale al primo
thetaA(end+1)=thetaA(1); % Aggiungi l'ultimo angolo uguale al primo
SPLmatrix_lin250(end+1) =  SPLmatrix_lin250(1); % Aggiungi l'ultimo valore uguale al primo
SPLmatrix_lin2000(end+1) =  SPLmatrix_lin2000(1); % Aggiungi l'ultimo valore uguale al primo
SPLmatrix_lin4000(end+1) =  SPLmatrix_lin4000(1); % Aggiungi l'ultimo valore uguale al primo
%SPLmatrix_lin4000(end+1) =  SPLmatrix_lin4000(1); % Aggiungi l'ultimo valore uguale al primo
%SPLmatrix_lin8000(end+1) =  SPLmatrix_lin8000(1); % Aggiungi l'ultimo valore uguale al primo

figure('WindowState','maximized')
set(gca, 'FontSize', 26)
h = polarplot(thetaA,ones(dirA+1,1));
hold on
hI = polarplot(thetaI,ones(dirI+1,1));%Il primo grafico fissa la scala poi viene reso invisibile
set(gca, 'RColor', 'k');
set(gca, 'ThetaColor', 'k');
set(gca, 'GridColor', 'k');
set(gca, 'GridAlpha', 1);
set(h,{'LineStyle'}, {'none'})
set(hI,{'LineStyle'}, {'none'})
set(gca, 'FontSize', 26)
hold on 

h = polarplot(thetaI, [SPLmatrix_lin(:)]./ maxVal, '--m'); 
set(h,'LineWidth',2)
hold on
h = polarplot(thetaA, [SPLmatrix_lin250(:)]./ maxVal_tot, '--r'); 
set(h,'LineWidth',2)
h = polarplot(thetaA, [SPLmatrix_lin2000(:)]./ maxVal_tot, '--b'); 
set(h,'LineWidth',2)
h = polarplot(thetaA, [SPLmatrix_lin4000(:)]./ maxVal_tot, '--g'); 
set(h,'LineWidth',2)
%h = polarplot(thetaA, [SPLmatrix_lin4000(:)]./ maxVal_tot, '--y'); 
%set(h,'LineWidth',2)
%h = polarplot(thetaA, [SPLmatrix_lin8000(:)]./ maxVal_tot, '--cyan'); 
%set(h,'LineWidth',2)
legend('','', 'Ideal', '250 Hz', '1 kHz', '4 kHz', 'FontSize', 25);
%title([ ' Spherical Harmonic n. ', int2str(v), ' Polar Plot'], 'FontSize', 10);


