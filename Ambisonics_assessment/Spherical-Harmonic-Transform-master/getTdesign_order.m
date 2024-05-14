function [ vecs, dirs_order] = getTdesign_order(degree)
%GETTDESIGN Returns the spherical coordinates of minimal T-designs
%
%   GETTDESIGN returns the unit vectors and the spherical coordinates
%   of t-designs, which constitute uniform arrangements on the sphere for
%   which spherical polynomials up to degree t can be integrated exactly by
%   summation of their values at the points defined by the t-design.
%   Designs for order up to t=21 are stored and returned. Note that for the
%   spherical harmonic transform (SHT) of a function of order N, a spherical
%   t-design of t>=2N should be used (or equivalently N=floor(t/2) ), since 
%   the integral evaluates the product of the spherical function with 
%   spherical harmonics of up to order N. The spherical coordinates are 
%   given in the [azi1 elev1; azi2 elev2; ...; aziQ elevQ] convention.
%
%   The designs have been copied from:
%       http://neilsloane.com/sphdesigns/
%   and should be referenced as:
%       "McLaren's Improved Snub Cube and Other New Spherical Designs in 
%       Three Dimensions", R. H. Hardin and N. J. A. Sloane, Discrete and 
%       Computational Geometry, 15 (1996), pp. 429-441.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Archontis Politis, archontis.politis@aalto.fi, 10/11/2014
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load('t_designs_1_21.mat');

if degree>21
    error('Designs of order greater than 21 are not implemented.')
elseif degree<1
    error('Order should be at least 1.')
end

vecs = t_designs{degree};
[dirs(:,1), dirs(:,2)] = cart2sph(vecs(:,1), vecs(:,2), vecs(:,3));

%add north pole (out of t_design)
dirs(25, 1)=0;
dirs(25, 2)=3.14/2;
[vecs(25,1), vecs(25,2), vecs(25,3)]=sph2cart(dirs(25,1), dirs(25,2), 1);
% Plot dei punti discretizzati
scatter3(vecs(:,1), vecs(:,2), vecs(:,3), 100, 'r', 'filled');
ordine_punti = 1:size(vecs, 1);
for i = 1:size(vecs, 1)
    text(vecs(i, 1), vecs(i, 2), vecs(i, 3), num2str(ordine_punti(i)), 'FontSize', 10, 'HorizontalAlignment', 'center');
end
dirs_order=zeros(25, 2);
dirs_order(1, 1)=dirs(23, 1);
dirs_order(2, 1)=dirs(21, 1);
dirs_order(3, 1)=dirs(24, 1);
dirs_order(4, 1)=dirs(22, 1);
dirs_order(5, 1)=dirs(3, 1);
dirs_order(6, 1)=dirs(2, 1);
dirs_order(7, 1)=dirs(14, 1);
dirs_order(8, 1)=dirs(16, 1);
dirs_order(9, 1)=dirs(8, 1);
dirs_order(10, 1)=dirs(5, 1);
dirs_order(11, 1)=dirs(10, 1);
dirs_order(12, 1)=dirs(12, 1);
dirs_order(13, 1)=dirs(1, 1);
dirs_order(14, 1)=dirs(4, 1);
dirs_order(15, 1)=dirs(15, 1);
dirs_order(16, 1)=dirs(13, 1);
dirs_order(17, 1)=dirs(6,1);
dirs_order(18, 1)=dirs(7,1);
dirs_order(19, 1)=dirs(11,1);
dirs_order(20, 1)=dirs(9,1);
dirs_order(21, 1)=dirs(17,1);
dirs_order(22, 1)=dirs(19,1);
dirs_order(23, 1)=dirs(18,1);
dirs_order(24, 1)=dirs(20,1);
dirs_order(25, 1)=dirs(25,1);

dirs_order(1, 2)=dirs(23, 2);
dirs_order(2, 2)=dirs(21, 2);
dirs_order(3, 2)=dirs(24, 2);
dirs_order(4, 2)=dirs(22, 2);
dirs_order(5, 2)=dirs(3, 2);
dirs_order(6, 2)=dirs(2, 2);
dirs_order(7, 2)=dirs(14, 2);
dirs_order(8, 2)=dirs(16, 2);
dirs_order(9, 2)=dirs(8, 2);
dirs_order(10, 2)=dirs(5, 2);
dirs_order(11, 2)=dirs(10, 2);
dirs_order(12, 2)=dirs(12, 2);
dirs_order(13, 2)=dirs(1, 2);
dirs_order(14, 2)=dirs(4, 2);
dirs_order(15, 2)=dirs(15, 2);
dirs_order(16, 2)=dirs(13, 2);
dirs_order(17, 2)=dirs(6,2);
dirs_order(18, 2)=dirs(7,2);
dirs_order(19, 2)=dirs(11,2);
dirs_order(20, 2)=dirs(9,2);
dirs_order(21, 2)=dirs(17,2);
dirs_order(22, 2)=dirs(19,2); %20
dirs_order(23, 2)=dirs(18,2);
dirs_order(24, 2)=dirs(20,2);
dirs_order(25, 2)=dirs(25,2);


[vecs_order(:,1), vecs_order(:,2), vecs_order(:,3)]=sph2cart(dirs_order(:,1), dirs_order(:,2), 1);
% Plot dei punti discretizzati
figure()
scatter3(vecs_order(:,1), vecs_order(:,2), vecs_order(:,3), 100, 'r', 'filled');
ordine_punti = 1:size(vecs_order, 1);
for i = 1:size(vecs_order, 1)
    text(vecs_order(i, 1), vecs_order(i, 2), vecs_order(i, 3), num2str(ordine_punti(i)), 'FontSize', 10, 'HorizontalAlignment', 'center');
end

end
