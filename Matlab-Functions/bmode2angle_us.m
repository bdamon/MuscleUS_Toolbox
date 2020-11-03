function [angle_image, masked_angle_image, angle_image_grid, vector_image] = bmode2angle_us(image_doub, mask, b2a_options)
%
%FUNCTION bmode2angle_us
%  [angle_image, masked_angle_image, angle_image_grid, vector_image] = bmode2angle_us(image_doub, mask, b2a_options)
%
%USAGE
%  The function bmode2angle_us is used to estimate muscle fascicle
%  orientations in the MuscleUS_Toolbox. The user provides a b-mode image,
%  the mask defining the region of interest in the image, and a structure
%  containing options for estimating the fascicle orientations. The
%  fascicle orientations are estimated using the algorithm presented by Rana
%  et al., (J Biomech, 42:2068,2009), in which the images are processed using 
%    -A series of Gaussian blurring steps of varying sizes  
%    -Calculation of the vesselness response of the structures
%    -Calculation of the Hessian matrix of the vesselness response 
%    -An anisotropic wavelet is convolved with the image at a range of
%     orientations
%    -The angle at which the maximum convolution of the wavelet with the image
%     is taken as the fascicle orientation.  
%  The angles are averaged across grid squares of user-defined dimensions.  
%  The function returns an image at the original resolution, a masked image at
%  the original resolution, a gridded image of angles, and a masked image
%  with the components of unit vectors indicating the fascicle
%  orientations.
%
%INPUT ARGUMENTS
%  image_doub: A double-precision, B-mode image
%
%  mask: The output of define_muscleroi_us
%
%  b2a_options: A structure containing the following fields:
%   -stdev_1: The minimum standard deviation of the Gaussian blurring window, 
%     in pixels
%   -stdev_2: The maximum standard deviation of the Gaussian blurring window, 
%     in pixels
%   -stdev_inc: The amount to increase the Gaussian blurring window per 
%     iteration, in pixels
%   -gauss_size: The row x column dimensions of the Gaussian blurring window,  
%     in pixels
%   -vessel_beta: The beta value in the vesselness response function
%   -vessel_c: The C value in the vesselness response function
%   -wavelet_damp: The damping coefficient D of the wavelet
%   -wavelet_kernel: The kernel size of the wavelet
%   -wavelet_freq: The expected spatial frequency of the fascicles
%   -min_angle: The minimum angle to use when convolving the wavelets with
%     the image (note that the east side of the image = 0 degrees and
%     angles increase in a CCW manner).
%   -max_angle: The maximum angle to use when convolving the wavelets with
%     the image
%   -num_angles: The number of angles to use when convolving the wavelets with
%     the image
%   -num_pixels: the size of the grid squares
%
%OUTPUT ARGUMENTS
%  angle_image: An image with per-pixel fasicle orientations
%
%  masked_angle_image: angle_image with the mask applied
%
%  angle_image_grid: The gridded angle image 
%
%  vector_image: The X and Y components of the gridded angle image
%
%VERSION INFORMATION
%  v. 0.1
%
%ACKNOWLEDGEMENTS
%  Grant support: NIH/NIAMS R01 AR073831

%% get options from input structure

% for vesselness calculations
stdev_1 = b2a_options.stdev_1;
stdev_2 = b2a_options.stdev_2; 
stdev_inc = b2a_options.stdev_inc;
gauss_size = b2a_options.gauss_size;
vessel_beta = b2a_options.vessel_beta; 
vessel_c = b2a_options.vessel_c;

%for wavelet function
wavelet_damp = b2a_options.wavelet_damp; 
wavelet_kernel = b2a_options.wavelet_kernel; 
wavelet_freq = b2a_options.wavelet_freq; 

%angle precision
min_angle = b2a_options.min_angle;
max_angle = b2a_options.max_angle;
num_angles = b2a_options.num_angles;

%median filtering options
num_pixels = b2a_options.num_pixels;

%% Calculate vesselness

%Convolution and get Hessian matrix
stdev_values= stdev_1:stdev_inc:stdev_2;
for ns=1:length(stdev_values)
    
    h1=fspecial('gaussian', [gauss_size gauss_size], stdev_values(ns)) ;        %first gaussian filter

    % size changes, so no pre-allocation of memory space 
    convs(:,:,ns)=conv2(image_doub, h1,'valid');                              	%convolve image with filter,
    hesmat(:,:,:,:,ns)=get_hessian(convs(:,:,ns));                              %take hessian of the convolution
    
end
[n_rows, n_co1]=size(convs(:,:,1));

% Calculate maximum vesselness
vesselness_all=zeros(n_rows,n_co1, length(stdev_values)); % vesselness
vec_all = zeros(2,n_rows,n_co1, length(stdev_values));
vesselness_max=zeros(n_rows,n_co1);
vesselness_dir = zeros(2,n_rows,n_co1);

for ns=1:length(stdev_values)
    
    Dxx = hesmat(:,:,1,1,ns);
    Dxy = hesmat(:,:,1,2,ns);
    Dyy = hesmat(:,:,2,2,ns);
    
    % Calculate (abs sorted) eigenvalues and vectors
    [Lambda1,Lambda2,Ix,Iy]=eig2image(Dxx,Dxy,Dyy); 
    Lambda2(Lambda2==0) = eps;
    Rb = (Lambda1./Lambda2).^2;
    S2 = sqrt(Lambda1.^2 + Lambda2.^2);   
    
    % Compute the output image
    I_filtered = exp(-Rb/vessel_beta) .*(ones(size(Dxx))-exp(-S2/vessel_c));
    I_filtered(Lambda2>0)=0;
	vesselness_all(:,:,ns) = I_filtered;
    vec_all(1,:,:,ns) = Ix;
    vec_all(2,:,:,ns) = Iy;
    
end

%calculate vesselness response matrix
for nr=1:n_rows
    for nc=1:n_co1
        
       [vesselness_max(nr,nc), index_1] = max(squeeze(vesselness_all(nr,nc,:)));
       vesselness_dir(:, nr, nc) = vec_all(:,nr,nc, index_1(1));
       
    end
end


%% Form anisotropic wavelet

%account for frame of reference for images vs wavelet
min_angle = min_angle+180;
max_angle = max_angle+180;

%calculate function parameters from input arguments
kernel_radius = ceil(wavelet_kernel + 0.5);
angle_prec = (max_angle-min_angle)/num_angles;

%calculate the wavelet
wavelet_function = zeros((kernel_radius*2+1),(kernel_radius*2+1),num_angles);
for x = -kernel_radius:kernel_radius
    for y = -kernel_radius:kernel_radius

        n = 1;
        for alpha_level = min_angle:angle_prec:max_angle
            
            wavelet_function((kernel_radius+1+x),(kernel_radius+1+y),n) = ...
                exp((x^2+y^2)/(-wavelet_damp*wavelet_kernel))*cos((2*pi*(x*cos(alpha_level*pi/180)-y*sin(alpha_level*pi/180)))/wavelet_freq)+0;

            n = n+1;
            
        end
        
    end
end

            
%% form angle image

cvn_images = zeros([size(image_doub) size(wavelet_function,3)]);
for n=1:num_angles
    cvn_images(:,:,n) = conv2(image_doub,squeeze(wavelet_function(:,:,n)),'same');
end

n_rows = size(image_doub,1);
n_cols = size(image_doub,2);
angle_image = zeros(n_rows,n_cols);

for nr=1:n_rows
    for nc=1:n_cols
        
        [~,index_3] = max(cvn_images(nr, nc,:));
        angle_image(nr,nc) = min_angle + (index_3-1)*angle_prec;
        
    end
end

angle_image = 180-angle_image;                                              %converts to ccw rotation from east=0;

%% Process angle image

col_diff = (size(image_doub,2)-size(vesselness_all,2))/2;
col_index_1 = 1 + col_diff;
row_diff = (size(image_doub,1)-size(vesselness_all,1))/2;
row_index_1 = 1 + row_diff;

%mask image based on Gaussian-convolved images
noise_mask = zeros(size(image_doub));
vesselness_end = zeros(size(image_doub));
vesselness_end((row_index_1:end-row_diff), (col_index_1:end-col_diff)) = squeeze(vesselness_all(:,:,end));
vesselness_end = vesselness_end.*mask;
noise_mask(vesselness_end > ((graythresh(vesselness_end)*max(max(vesselness_end))))) = 1;

%apply mask to angle_image
masked_angle_image = mask.*noise_mask.*angle_image;

%median filter the image in small chunks
angle_image_grid = zeros(size(image_doub));
first_row = find(sum(mask,2), 1);
first_col = find(sum(mask,1), 1);

for nr = first_row:num_pixels:(n_rows - num_pixels - 1)
    for nc = first_col:num_pixels:(n_cols - num_pixels - 1)
        
        loop_data = masked_angle_image(nr:(nr+num_pixels-1),nc:(nc+num_pixels-1));
        if sum(sum(loop_data))>0
            loop_data = reshape(loop_data, numel(loop_data), 1);
            loop_data = loop_data(loop_data~=0);
            angle_image_grid(nr:(nr+num_pixels-1),nc:(nc+num_pixels-1)) = median(loop_data);
        end
        
    end
end
% angle_image_median = medfilt2(angle_image, [num_pixels num_pixels]);
angle_image_grid = angle_image_grid.*mask;

%% Calculate vector images: Frame of reference is origin at row 1, column 1 and positively increasing from there

vector_image = sind(angle_image_grid).*mask;                              %holds row increments
vector_image(:,:,2) = cosd(angle_image_grid).*mask;                       %holds column increments
vector_image(:,:,1) = -vector_image(:,:,1);


%% end of function

return;
