function [angle_image, masked_angle_image, angle_image_grid, vector_image, vesselness_mask, vesselness_max, max_cvn_image, cvn_images, sample_wavelet] = bmode2angle_us(image_gray, mask, b2a_options)
%
%FUNCTION bmode2angle_us
%  [angle_image, masked_angle_image, angle_image_grid, vector_image, vesselness_mask, vesselness_max, max_cvn_image, cvn_images, sample_wavelet] = 
%    bmode2angle_us(image_gray, mask, b2a_options)
% 
%USAGE
%  The function bmode2angle_us is used to estimate muscle fascicle
%  orientations in the MuscleUS_Toolbox. The user provides a B-mode image,
%  the mask defining the region of interest in the image, and a structure
%  containing options for estimating the fascicle orientations. The
%  fascicle orientations are estimated using an algorithm presented by Rana
%  et al., (J Biomech, 42:2068, 2009), in which the images are processed using
%    -Vesselness filtering:
%      -A series of Gaussian blurring steps with increasing std. deviations
%       for the Gaussian function; for each one, the vesselness response of
%       the structures is calculated.
%      -Determination of the maximum vesselness resprose
%    -Determination of local fasicle orientation
%      -An anisotropic wavelet is convolved with the vesselness-filtered
%       image at a user-specified range of orientations
%      -The angle at which the maximum convolution of the wavelet with the image
%       is taken as the fascicle orientation.
%  A mask is formed from the vesselness image and used to eliminate signals
%  from areas of low vesselness response. The median angle, across 
%  grid squares of user-defined dimensions, is taken and its vector 
%  components are calculated.
%
%  The function returns the vesselness images, spatial maps of fascicle
%  orientations, and images for quality assurance/inspection, as described
%  below.
%    -Spatial maps of fascicle orientations, including
%      -An image of fascicle oreintations within the user-defined ROI, at
%       the original image resolution
%      -A vesselness-masked masked angle image image at the original resolution
%      -An image containing the median angles within the grid squares
%    -An image with the components of unit vectors indicating the fascicle
%     orientations, within the grid squares.
%    -Images for QA purposes:
%       -The convolution images
%       -A sample wavelet
%
%INPUT ARGUMENTS
%  image_doub: A grayscale, B-mode image at double-precision
%
%  mask: The output of define_muscleroi_us
%
%  b2a_options: A structure containing the following processing options:
%   -.stdev_1: The minimum standard deviation of the Gaussian blurring window,
%     in pixels
%   -.stdev_2: The maximum standard deviation of the Gaussian blurring window,
%     in pixels
%   -.stdev_inc: The amount to increase the Gaussian blurring window per
%     iteration, in pixels
%   -.gauss_size: The row x column dimensions of the Gaussian blurring window,
%     in pixels
%   -.vessel_beta: The beta value in the vesselness response function
%   -.vessel_c: The C value in the vesselness response function
%   -.wavelet_damp: The damping coefficient D of the wavelet
%   -.wavelet_kernel: The kernel size of the wavelet, in pixels
%   -.wavelet_freq: The expected spatial frequency of the fascicles, in
%     pixels^-1
%   -.min_angle: The minimum angle to use when convolving the wavelets with
%     the image, in degrees (note that the right side of the image = 0 degrees and
%     angles increase in a CCW manner).
%   -.max_angle: The maximum angle to use when convolving the wavelets with
%     the image, in degrees
%   -.num_angles: The number of angles to use when convolving the wavelets with
%     the image
%   -.num_pixels: A P x 2 matrix defining the grid square sizes to be analyzed.
%     Each row of num_pixels defines the row and column sizes of the grid
%     squares, in pixels (i.e., n x m). The averaging is repeated for each
%     row, p, of num_pixels.
%   -.otsu: the multiplier for Otsu's threshold in the vesselness-masked
%     images, when Otsu's method is used to filter the image
%   -.k: a two-element vector with the number of clusters and the ordinal rank,
%     of the cluster to be used, when k-means clustering is used to filter the image
%
%OUTPUT ARGUMENTS
%  angle_image: An image with per-pixel fasicle orientations, within the
%   user-defined region of interest
%
%  masked_angle_image: A vesselness-masked masked angle image image at the
%   original resolution
%
%  angle_image_grid: An image containing the median values of the vesselness-
%   filtered angles within the grid squares
%
%  vector_image: The X and Y components of the angles in the gridded image
%
%  vesselness_mask: The mask calculated fromteh vesselness image
%
%  vesselness_max: The maximum vesselness response image
%
%  max_cvn_image: An image showing trhe maximum value of the convolution of
%   wavelet with the pixels
%
%  cvn_images: All of the convolution images
%
%  sample_wavelet: The wavelet use to determine fascicle orientation
%
%VERSION INFORMATION
%  v. 1.0.0 (August 1, 2023): Initial release after paper accepted by J Appl Biomch
%
%ACKNOWLEDGEMENTS
%  People: Emily Bush, Ke Li, Hannah Kilpatrick, Bruce Damon, Zhaohua Ding
%  Grant support: NIH/NIAMS R01 AR073831

%% MAIN FUNCTION is bmode2angle

% Preparation: get options from the input structure

% for vesselness calculations
stdev_1 = b2a_options.stdev_1;
stdev_2 = b2a_options.stdev_2;
stdev_inc = b2a_options.stdev_inc;
gauss_size = b2a_options.gauss_size;
vessel_beta = b2a_options.vessel_beta;
vessel_c = b2a_options.vessel_c;

% for wavelet function
wavelet_damp = b2a_options.wavelet_damp;
wavelet_kernel = b2a_options.wavelet_kernel;
wavelet_freq = b2a_options.wavelet_freq;

% angle range and precision
min_angle = b2a_options.min_angle;
max_angle = b2a_options.max_angle;
num_angles = b2a_options.num_angles;

% median filtering options
num_pixels = b2a_options.num_pixels;


% 1. Calculate the vesselness response

% 1a. Convolution with Gaussian kernels and Hessian matrix
stdev_values = stdev_1:stdev_inc:stdev_2;                                    % create array of st. dev. values
convs = zeros([size(image_gray) length(stdev_values)]);                       % initialize matrices as zeros
hesmat = zeros([size(image_gray) 2 2 length(stdev_values)]);

for ns=1:length(stdev_values)

    h1 = fspecial('gaussian', [gauss_size gauss_size], stdev_values(ns));     % define the Gaussian filter

    temp_convs = conv2(image_gray.*mask, h1,'valid');                             % convolve image with Gaussian filter

    % first time, get difference in size between image_gray and convolution image
    if ns==1
        row_diff = length(image_gray(:,1)) - length(temp_convs(:,1));
        row_1 = floor(1 + row_diff/2);
        row_end = length(image_gray(:,1)) - ceil(row_diff/2);

        col_diff = length(image_gray(:,1)) - length(temp_convs(:,1));
        col_1 = floor(1 + col_diff/2);
        col_end = length(image_gray(1,:)) - ceil(col_diff/2);
    end

    convs(row_1:row_end,col_1:col_end,ns) = temp_convs;                     % paste convolved image for this loop into the larger matrix
    hesmat(:,:,:,:,ns)=get_hessian(convs(:,:,ns));                          % take hessian of the convolution

end
[n_rows, n_co1]=size(convs(:,:,1));

% 1b. Calculate maximum vesselness for each convolved image
vesselness_all=zeros(n_rows,n_co1, length(stdev_values));                   % initialize the vesselness images as zeros
vec_all = zeros(2,n_rows,n_co1, length(stdev_values));
vesselness_max=zeros(n_rows,n_co1);
vesselness_dir = zeros(2,n_rows,n_co1);

for ns=1:length(stdev_values)

    Dxx = hesmat(:,:,1,1,ns);
    Dxy = hesmat(:,:,1,2,ns);
    Dyy = hesmat(:,:,2,2,ns);

    % Calculate (abs sorted) eigenvalues and vectors
    [Lambda1, Lambda2, Ix, Iy] = eig2image(Dxx,Dxy,Dyy);
    Lambda2(Lambda2==0) = eps;
    Rb = (Lambda1./Lambda2).^2;                                             % defined as in Rana et al
    Sc = sqrt(Lambda1.^2 + Lambda2.^2);


    % Compute the vesselness response
    I_filtered = exp(-Rb/(2*vessel_beta^2)) .*(ones(size(Dxx))-exp(-Sc/(2*vessel_c^2)));
    I_filtered(Lambda2>0)=0;
    vesselness_all(:,:,ns) = I_filtered;
    vec_all(1,:,:,ns) = Ix;
    vec_all(2,:,:,ns) = Iy;

end

% calculate the maximum vesselness response matrix
for nr=1:n_rows
    for nc=1:n_co1

        [vesselness_max(nr,nc), index_1] = max(squeeze(vesselness_all(nr,nc,:)));
        vesselness_dir(:, nr, nc) = vec_all(:,nr,nc, index_1(1));

    end
end

% 2. Find fascicle orientation

% 2a. Form anisotropic wavelet

% account for frame of reference for images vs wavelet
min_angle = -min_angle + 180;
max_angle = -max_angle + 180;

% calculate function parameters from input arguments
kernel_radius = ceil(wavelet_kernel + 0.5);
angle_vector = linspace(min_angle, max_angle, num_angles);

% calculate the wavelet
wavelet_function = zeros((kernel_radius*2+1),(kernel_radius*2+1),num_angles);
for x = -kernel_radius:kernel_radius
    for y = -kernel_radius:kernel_radius
        for n=1:length(angle_vector)

            alpha_level = angle_vector(n);
            wavelet_function((kernel_radius+1+x),(kernel_radius+1+y),n) = ...
                exp((x^2+y^2)/(-wavelet_damp*wavelet_kernel))*cos((2*pi*(x*cos(alpha_level*pi/180)-y*sin(alpha_level*pi/180)))/wavelet_freq)+0;

        end
    end
end
sample_wavelet = zeros((kernel_radius*2+1),(kernel_radius*2+1));
alpha_level = 0;
for x = -kernel_radius:kernel_radius
    for y = -kernel_radius:kernel_radius

        sample_wavelet((kernel_radius+1+x),(kernel_radius+1+y)) = ...
            exp((x^2+y^2)/(-wavelet_damp*wavelet_kernel))*cos((2*pi*(x*cos(alpha_level*pi/180)-y*sin(alpha_level*pi/180)))/wavelet_freq)+0;
    end
end

% 2b. Convolve wavelet with vesselness image; form angle image
cvn_images = zeros([size(vesselness_max) size(wavelet_function,3)]);
for n=1:num_angles
    cvn_images(:,:,n) = conv2(vesselness_max, squeeze(wavelet_function(:,:,n)), 'same');
end

n_rows = size(vesselness_max,1);
n_cols = size(vesselness_max,2);
angle_image = zeros(n_rows,n_cols);
max_cvn_image = zeros(n_rows, n_cols);

for nr=1:n_rows
    for nc=1:n_cols
        if mask(nr,nc)
            [max_cvn_image(nr,nc), index_3] = max(cvn_images(nr, nc,:));
            angle_image(nr,nc) = angle_vector(index_3);
        end
    end
end
angle_image = -(angle_image - 180);                                              %converts back to ccw rotation from image right=0;

% 3. Process angle image
col_diff = (size(image_gray,2)-size(vesselness_all,2))/2;
col_index_1 = 1 + col_diff;
row_diff = (size(image_gray,1)-size(vesselness_all,1))/2;
row_index_1 = 1 + row_diff;

% mask image based on vesselness images
vesselness_mask = zeros(size(image_gray));
vesselness_end = zeros(size(image_gray));
vesselness_end((row_index_1:end-row_diff), (col_index_1:end-col_diff)) = squeeze(vesselness_all(:,:,end));
vesselness_end = vesselness_end.*mask;
if isfield(b2a_options, 'otsu')
    vesselness_mask(vesselness_end > (b2a_options.otsu*(graythresh(vesselness_end)*max(max(vesselness_end))))) = 1;
    vesselness_mask = vesselness_mask.*bwmorph(mask, 'erode', 2);
else
    [vesselness_clusters, vesselness_centers] = imsegkmeans(int16(vesselness_end), b2a_options.k(1));
    vesselness_centers = [vesselness_centers (1:b2a_options.k(1))'];
    vesselness_centers = sortrows(vesselness_centers, 1, "descend");
    vesselness_mask(vesselness_clusters==vesselness_centers(b2a_options.k(2),2))=1;
    vesselness_mask = bwmorph(vesselness_mask, 'dilate', 1);
    vesselness_mask = bwmorph(vesselness_mask, 'erode', 2);
end




% apply mask to angle_image
masked_angle_image = mask.*vesselness_mask.*angle_image;

% 4 Grid image by taking tme median over small chunks of the image
angle_image_grid = zeros([size(image_gray) length(num_pixels(:,1))]);
first_row = find(sum(mask,2), 1);
first_col = find(sum(mask,1), 1);
last_row = find(sum(mask,2), 1, 'last');
last_col = find(sum(mask,1), 1, 'last');

%calculate median orientations from upper left of masked region to bottom right edge of region.
for np=1:length(num_pixels(:,1))
    for nr = first_row:num_pixels(np,1):(last_row + num_pixels(1) + 1)
        for nc = first_col:num_pixels(np,2):(last_col + num_pixels(2) + 1)

            loop_data = masked_angle_image(nr:min(n_rows, (nr+num_pixels(np,1)-1)), min(n_cols, nc:(nc+num_pixels(np,2)-1)));
            if sum(sum(loop_data))~=0
                loop_data = nonzeros(loop_data);
                angle_image_grid(nr:(nr+num_pixels(np,1)-1), nc:(nc+num_pixels(np,2)-1),np) = median(loop_data);
            end

        end
    end
end




% Calculate vector images: Frame of reference is origin at row 1, column 1 and positively increasing from there
vector_image = zeros([size(image_gray) 2 length(num_pixels(:,1))]);
for np=1:length(num_pixels(:,1))
    vector_image(:,:,1,np) = -sind(angle_image_grid(:,:,np)).*mask;                              %holds row increments
    vector_image(:,:,2,np) = cosd(angle_image_grid(:,:,np)).*mask;                        %holds column increments
end

% end of main function
return;


%% function definition for eig2image (called by bmode2angle)
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

% end the function
return


%% function definition for get_hessian (called by bmode2angle)
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
%  H: A spatial map of the Hassian matrices
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
