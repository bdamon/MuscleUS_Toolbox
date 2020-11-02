function [H] = get_hessian(img)
%
%FUNCTION get_hessian
%  [H] = get_hessian(img);
%
%USAGE
%  The function read_dicom_us is used to calculate the Hessian matrix of
%  image, based on its intensity gradients.
%
%INPUT ARGUMENT
%  img: The source image (assumed to be 2D).
%
%OUTPUT ARGUMENTS
%  H: Aspatial map of the Hassian matrices
%
%VERSION INFORMATION
%  v. 1.0
%
%ACKNOWLEDGEMENTS
%  People: Emily Bush, Ke Li
%  Grant support: NIH/NIAMS R01 AR050101, NIH/NIAMS R01 AR073831

%% calculate the Hessian matrix
H = zeros([size(img) 2 2]);

[Gx, Gy] = gradient(img);  % Gx is the gradient along column direction
[Gxx, Gxy] = gradient(Gx);
[Gyx, Gyy] = gradient(Gy);

H(:, :, 1, 1) = Gxx;
H(:, :, 1, 2) = Gxy;
H(:, :, 2, 1) = Gyx;
H(:, :, 2, 2) = Gyy;

%% end the function
return;

