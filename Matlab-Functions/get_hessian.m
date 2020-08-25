function [H] = get_hessian(img)
% assume img is 2D input image

H = zeros([size(img) 2 2]);

[Gx, Gy] = gradient(img);  % Gx is the gradient along column direction
[Gxx, Gxy] = gradient(Gx);
[Gyx, Gyy] = gradient(Gy);

H(:, :, 1, 1) = Gxx;
H(:, :, 1, 2) = Gxy;
H(:, :, 2, 1) = Gyx;
H(:, :, 2, 2) = Gyy;

return;

