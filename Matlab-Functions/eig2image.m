function [Lambda1,Lambda2,Ix,Iy]=eig2image(Dxx,Dxy,Dyy)
% 
%FUNCTION eig2image
%  [Lambda1,Lambda2,Ix,Iy]=eig2image(Dxx,Dxy,Dyy)
%
% USAGE
%  This function eig2image calculates the eigenvalues from the Hessian matrix: 
% 
%  | Dxx  Dxy |
%  |          |
%  | Dxy  Dyy |
%
%  sorted by abs value, and gives the direction of the ridge (eigenvector
%  smallest eigenvalue).
%  
%  The user does not interact with this function.  It is called by
%  bmode2angle_us.
%
% ACKNOWLEDGEMENTS
%  Downloaded from 
%  http://www.mathworks.com/matlabcentral/fileexchange/24409-hessian-based-frangi-vesselness-filter
%  by Ke Li, 2012-06-19

% Compute the eigenvectors of J, v1 and v2
tmp = sqrt((Dxx - Dyy).^2 + 4*Dxy.^2);
v2x = 2*Dxy; v2y = Dyy - Dxx + tmp;

% Normalize
mag = sqrt(v2x.^2 + v2y.^2); i = (mag ~= 0);
v2x(i) = v2x(i)./mag(i);
v2y(i) = v2y(i)./mag(i);

% The eigenvectors are orthogonal
v1x = -v2y; 
v1y = v2x;

% Compute the eigenvalues
mu1 = 0.5*(Dxx + Dyy + tmp);
mu2 = 0.5*(Dxx + Dyy - tmp);

% Sort eigen values by absolute value abs(Lambda1)<abs(Lambda2)
check=abs(mu1)>abs(mu2);

Lambda1=mu1; Lambda1(check)=mu2(check);
Lambda2=mu2; Lambda2(check)=mu1(check);

Ix=v1x; Ix(check)=v2x(check);
Iy=v1y; Iy(check)=v2y(check);
end


