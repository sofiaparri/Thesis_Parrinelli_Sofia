function [xM, yM, zM]=       Em_capsules%% mic capsules
thetaM=zeros(64,1);
phiM=zeros(64,1);

thetaM(1)=deg2rad(16.7656);
thetaM(2)=deg2rad(21.9677);
thetaM(3)=deg2rad(42.3941);
thetaM(4)=deg2rad(13.2817);
thetaM(5)=deg2rad(22.6728);
thetaM(6)=deg2rad(52.6925);
thetaM(7)=deg2rad(37.806);
thetaM(8)=deg2rad(43.3944);
thetaM(9)=deg2rad(43.9386);
thetaM(10)=deg2rad(70.3132);

thetaM(11)=deg2rad(33.2231);
thetaM(12)=deg2rad(60.0257);
thetaM(13)=deg2rad(56.4763);
thetaM(14)=deg2rad(67.4936);
thetaM(15)=deg2rad(93.2735);
thetaM(16)=deg2rad(48.423);
thetaM(17)=deg2rad(78.0793);
thetaM(18)=deg2rad(62.0685);
thetaM(19)=deg2rad(38.7171);

thetaM(20)=deg2rad(63.8004);
thetaM(21)=deg2rad(70.1946);
thetaM(22)=deg2rad(96.246);
thetaM(23)=deg2rad(81.0992);
thetaM(24)=deg2rad(106.094);
thetaM(25)=deg2rad(67.7533);
thetaM(26)=deg2rad(91.7061);
thetaM(27)=deg2rad(39.9985);
thetaM(28)=deg2rad(68.7726);
thetaM(29)=deg2rad(60.8869);
thetaM(30)=deg2rad(82.2833);

thetaM(31)=deg2rad(63.0247);
thetaM(32)=deg2rad(89.794);
thetaM(33)=deg2rad(137.5166);
thetaM(34)=deg2rad(139.7604);
thetaM(35)=deg2rad(135.2133);
thetaM(36)=deg2rad(160.3628);
thetaM(37)=deg2rad(162.577);
thetaM(38)=deg2rad(142.0685);
thetaM(39)=deg2rad(161.1987);
thetaM(40)=deg2rad(162.577);

thetaM(41)=deg2rad(115.537);
thetaM(42)=deg2rad(86.8004);
thetaM(43)=deg2rad(116.0164);
thetaM(44)=deg2rad(95.3313);
thetaM(45)=deg2rad(90.0637);
thetaM(46)=deg2rad(111.4549);
thetaM(47)=deg2rad(85.8671);
thetaM(48)=deg2rad(130.8398);
thetaM(49)=deg2rad(102.5775);
thetaM(50)=deg2rad(142.6375);

thetaM(51)=deg2rad(117.032);
thetaM(52)=deg2rad(117.5631);
thetaM(53)=deg2rad(115.8884);
thetaM(54)=deg2rad(89.69);
thetaM(55)=deg2rad(118.4478);
thetaM(56)=deg2rad(93.9338);
thetaM(57)=deg2rad(106.3875);
thetaM(58)=deg2rad(81.0511);
thetaM(59)=deg2rad(135.9764);
thetaM(60)=deg2rad(142.6771);

thetaM(61)=deg2rad(120.6556);
thetaM(62)=deg2rad(133.8834);
thetaM(63)=deg2rad(116.3591);
thetaM(64)=deg2rad(107.464);

%-------------------------------------------------------

phiM(1)=deg2rad(197.4561);
phiM(2)=deg2rad(115.734);
phiM(3)=deg2rad(81.911);
phiM(4)=deg2rad(313.3592);
phiM(5)=deg2rad(43.1785);
phiM(6)=deg2rad(46.7324);
phiM(7)=deg2rad(335.9958);
phiM(8)=deg2rad(14.5398);
phiM(9)=deg2rad(204.4547);
phiM(10)=deg2rad(206.542);

phiM(11)=deg2rad(247.3219);
phiM(12)=deg2rad(233.817);
phiM(13)=deg2rad(264.5437);
phiM(14)=deg2rad(99.6669);
phiM(15)=deg2rad(104.6842);
phiM(16)=deg2rad(120.9227);
phiM(17)=deg2rad(126.513);
phiM(18)=deg2rad(148.2368);
phiM(19)=deg2rad(162.6381);
phiM(20)=deg2rad(178.5498);

phiM(21)=deg2rad(21.2715);
phiM(22)=deg2rad(25.7834);
phiM(23)=deg2rad(47.8607);
phiM(24)=deg2rad(55.9075);
phiM(25)=deg2rad(71.4285);
phiM(26)=deg2rad(78.4921);
phiM(27)=deg2rad(293.221);
phiM(28)=deg2rad(290.5683);
phiM(29)=deg2rad(318.1354);
phiM(30)=deg2rad(334.0042);

phiM(31)=deg2rad(352.0227);
phiM(32)=deg2rad(0);
phiM(33)=deg2rad(174.0335);
phiM(34)=deg2rad(212.7205);
phiM(35)=deg2rad(251.9179);
phiM(36)=deg2rad(150.6471);
phiM(37)=deg2rad(240.8266);
phiM(38)=deg2rad(293.0625);
phiM(39)=deg2rad(331.0098);
phiM(40)=deg2rad(60.8266);

phiM(41)=deg2rad(226.9135);
phiM(42)=deg2rad(233.9255);
phiM(43)=deg2rad(193.6382);
phiM(44)=deg2rad(209.6696);
phiM(45)=deg2rad(183.169);
phiM(46)=deg2rad(163.7105);
phiM(47)=deg2rad(156.9524);
phiM(48)=deg2rad(139.4318);
phiM(49)=deg2rad(135.9729);
phiM(50)=deg2rad(102.3273);

phiM(51)=deg2rad(112.5511);
phiM(52)=deg2rad(83.1464);
phiM(53)=deg2rad(307.7078);
phiM(54)=deg2rad(309.1392);
phiM(55)=deg2rad(278.2519);
phiM(56)=deg2rad(282.9735);
phiM(57)=deg2rad(253.147);
phiM(58)=deg2rad(260.0688);
phiM(59)=deg2rad(59.7394);
phiM(60)=deg2rad(14.2241);

phiM(61)=deg2rad(32.4901);
phiM(62)=deg2rad(334.0753);
phiM(63)=deg2rad(2.0842);
phiM(64)=deg2rad(335.0677);
%% ---------------------------------------------------------------------------------------------------------------------------
xM=zeros(64,1);
yM=zeros(64,1);
zM=zeros(64,1);

xM(1)=-1.1557241;
xM(2)=-0.6821829;
xM(3)=0.3984595;
xM(4)=0.6624713;
xM(5)=1.180592;
xM(6)=2.2897066;
xM(7)=2.3518981;
xM(8)=2.7930555;
xM(9)=-2.6528792;
xM(10)=-3.537724;

xM(11)=-0.8872276;
xM(12)=-2.147899;
xM(13)=-0.3329298;
xM(14)=-0.6515458;
xM(15)=-1.0629237;
xM(16)=-1.6145501;
xM(17)=-2.4451299;
xM(18)=-3.154981;
xM(19)=-2.5073092;
xM(20)=-3.7672903;

xM(21)=3.6823528;
xM(22)=3.7594201;
xM(23)=2.783995;
xM(24)=2.2619641;
xM(25)=1.2380765;
xM(26)=0.837538;
xM(27)=1.0644033;
xM(28)=1.3754457;
xM(29)=2.7326723;
xM(30)=3.7408815;

xM(31)=3.7068295;
xM(32)=4.1999728;
xM(33)=-2.8212155;
xM(34)=-2.2826123;
xM(35)=-0.9183428;
xM(36)=-1.2302547;
xM(37)=-0.6130139;
xM(38)=1.0113875;
xM(39)=1.1840051;
xM(40)=0.6130139;

xM(41)=-2.5887652; 
xM(42)=-2.24678452;
xM(43)=-3.6679849;
xM(44)=-3.6335686;
xM(45)=-4.1935747;
xM(46)=-3.37520459;
xM(47)=-3.8547052;
xM(48)=-2.4137073;
xM(49)=-2.9473784;
xM(50)=0.544157;

xM(51)=-1.434762; 
xM(52)=0.44431;
xM(53)=2.3110697;
xM(54)=2.6510308;
xM(55)=0.5300179;
xM(56)=0.9406824;
xM(57)=-1.1681846;
xM(58)=-0.7155393;
xM(59)=1.4708897;
xM(60)=2.4684172;

xM(61)=3.0475416; 
xM(62)=2.7225321;
xM(63)=3.7608328;
xM(64)=3.6330318;
%-----------------------------------------------------------------------

yM(1)=-0.3634259;
yM(2)=1.4153239;
yM(3)=2.8035747;
yM(4)=-0.7015439;
yM(5)=1.1078169;
yM(6)=2.432533;
yM(7)=-1.0473407;
yM(8)=0.7244038;
yM(9)=-1.2064556;
yM(10)=-1.7670872;

yM(11)=-2.1232674;
yM(12)=-2.9365592;
yM(13)=-3.4854965;
yM(14)=3.8250201;
yM(15)=4.0561896;
yM(16)=2.6952875;
yM(17)=3.3028326;
yM(18)=1.9533694;
yM(19)=0.7839137;
yM(20)=0.0953744;

yM(21)=1.4335781;
yM(22)=1.8160279;
yM(23)=3.0768616;
yM(24)=3.3418436;
yM(25)=3.6849368;
yM(26)=4.1137444;
yM(27)=-2.4809284;
yM(28)=-3.6654662;
yM(29)=-2.4488403;
yM(30)=-1.8242135;

yM(31)=-0.5194603;
yM(32)=0;
yM(33)=0.2948551;
yM(34)=-1.4665642;
yM(35)=-2.8126445;
yM(36)=0.6918823;
yM(37)=-1.0980567;
yM(38)=-2.3754736;
yM(39)=-0.6560409;
yM(40)=1.0980566;

yM(41)=-2.7677307;
yM(42)=-3.387427;
yM(43)=-0.8899681;
yM(44)=-2.0699981;
yM(45)=-0.2321812;
yM(46)=1.0964305;
yM(47)=1.6400072;
yM(48)=2.066478;
yM(49)=2.8489432;
yM(50)=2.4900315;

yM(51)=3.4551056;
yM(52)=3.6967039;
yM(53)=-2.9893349;
yM(54)=-3.2575329;
yM(55)=-3.6546219;
yM(56)=-4.0831477;
yM(57)=-3.8563231;
yM(58)=-4.0867068;
yM(59)=2.5211;
yM(60)=0.6257108;

yM(61)=1.9407585;
yM(62)=-1.3234437;
yM(63)=0.1368636;
yM(64)=-1.6888911;
%----------------------------------------------------------------------
zM(1)=4.0214702;
zM(2)=3.8950591;
zM(3)=3.1018059;
zM(4)=4.0876603;
zM(5)=3.8754281;
zM(6)=2.5455896;
zM(7)=3.3183809;
zM(8)=3.0518977;
zM(9)=3.0243505;
zM(10)=1.4148888;

zM(11)=3.5134829;
zM(12)=2.0983685;
zM(13)=2.3195849;
zM(14)=1.607703;
zM(15)=-0.2398308;
zM(16)=2.7872303;
zM(17)=0.8675458;
zM(18)=1.9673441;
zM(19)=3.277023;
zM(20)=1.8542999;

zM(21)=1.4230711;
zM(22)=-0.4569489;
zM(23)=0.649841;
zM(24)=-1.1643021;
zM(25)=1.5900971;
zM(26)=-0.1250487;
zM(27)=3.2174585;
zM(28)=1.520693;
zM(29)=2.0434489;
zM(30)=0.563958;

zM(31)=1.95051444;
zM(32)=0.0150987;
zM(33)=-3.0973868;
zM(34)=-3.2060679;
zM(35)=-2.9808853;
zM(36)=-3.9557265;
zM(37)=-4.0073042;
zM(38)=-3.312736;
zM(39)=-3.9758953;
zM(40)=-4.0073039;

zM(41)=-1.8105291;
zM(42)=0.2740042;
zM(43)=-1.8422388;
zM(44)=-0.3902395;
zM(45)=-4.67155*10^(-3);
zM(46)=-1.5362267;
zM(47)=0.3026973;
zM(48)=-2.746577;
zM(49)=-0.914577;
zM(50)=-3.3382085;

zM(51)=-1.9088482;
zM(52)=-1.9434429;
zM(53)=-1.8338031;
zM(54)=0.0227251;
zM(55)=-2.0007047;
zM(56)=-0.2881338;
zM(57)=-1.1849547;
zM(58)=0.6533236;
zM(59)=-3.020023;
zM(60)=-3.3399704;

zM(61)=-2.1414822;
zM(62)=-2.9114115;
zM(63)=-1.86478;
zM(64)=-1.2604466;

%plot della configurazione
%load dirs
azimuth=load("Directions_em_speakers\azimuth_Vroom.mat");
azimuth=azimuth.azimuth;
elevation=load('Directions_em_speakers\elevation_Vroom.mat');
elevation=elevation.elevation;
dirs=zeros(25, 2); 
dirs(:, 1)=deg2rad(azimuth);
dirs(:, 2)=deg2rad(elevation);

    [X, Y, Z]=sphere;
    r1=4.2;
    X1 = X * r1;
    Y1 = Y * r1;
    Z1 = Z * r1;
    r2=10;
    X2 = X * r2;
    Y2 = Y * r2;
    Z2 = Z * r2;

figure()
scatter3(xM(:), yM(:), zM(:), 30, 'filled', 'red');
ordine_punti = 1:size(xM, 1);
for i = 1:size(xM, 1)
    text(xM(i), yM(i), zM(i), num2str(ordine_punti(i)), 'FontSize', 20, 'HorizontalAlignment', 'center');
end
hold on
[vecs_order(:,1), vecs_order(:,2), vecs_order(:,3)]=sph2cart(dirs(:,1), dirs(:,2), 10);

scatter3(vecs_order(:,1), vecs_order(:,2), vecs_order(:,3), 100, 'blue');
ordine_punti = 1:size(vecs_order, 1);
for i = 1:size(vecs_order, 1)
    text(vecs_order(i, 1), vecs_order(i, 2), vecs_order(i, 3), num2str(ordine_punti(i)), 'FontSize', 13, 'HorizontalAlignment', 'center');
end
hold on
surf(X1,Y1,Z1)
s = findall(gca, 'type', 'surf');
set(s, 'FaceColor', 'k', 'FaceAlpha', 0.01, 'EdgeAlpha', 0.1)
hold on
surf(X2,Y2,Z2)
s = findall(gca, 'type', 'surf');
set(s, 'FaceColor', 'k', 'FaceAlpha', 0.01, 'EdgeAlpha', 0.1)
axis equal;
grid on;
xlabel('X');
ylabel('Y');
zlabel('Z');
set(gca, 'XTickLabel', []);
set(gca, 'YTickLabel', []);
set(gca, 'ZTickLabel', []);



