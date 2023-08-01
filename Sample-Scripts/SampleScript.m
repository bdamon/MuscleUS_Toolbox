%% Sample Processing Script
clear
close all
clc

%% Open file

% Can use either this
[image_data_struc, image_info_struc] = read_dicom_us(); 

% Or this (uncomment and then replace with local path and file names)
% input_structure.input_path_name = 'S:\Muscle_DTI\Data\Aim 1\Aim 1A\MuscleUS_Toolbox paper\230512_Dataset_Tentative_Selection\6_TA_15degrees_plantarflexion_0101';
% input_structure.input_file_name = 'M9NG1Q0C';
% input_structure.output_path_name = input_structure.input_path_name;
% input_structure.output_file_name = 'ExampleData.mat';
% input_structure.show_image = 1;                                             %set to 1 to show image
% [image_data_struc, image_info_struc] = read_dicom_us(input_structure);


%% Define muscle boundaries and aponeurosis position
close all

% set options for region/aponeurosis definition
dmr_options.roi_resolution = 1;
dmr_options.frame_num = 1;
dmr_options.def_roi = 1;
dmr_options.def_muscle = 1;

[image_data_struc, roi_struc] = define_muscleroi_us(image_data_struc, image_info_struc, dmr_options);

% to repeat the aponeurosis definition without repeating the mask definition, uncomment this code:
% dmr_options.def_muscle = 0;
% dmr_options.mask = image_data_struc.mask;
% dmr_options.muscle_c_pixels = roi_struc.muscle_c_pixels;
% dmr_options.muscle_r_pixels = roi_struc.muscle_r_pixels;
% 
% [image_data_struc, roi_struc] = define_muscleroi_us(image_data_struc, image_info_struc, dmr_options);

%% Model fascicle orientations

% set options - mask vesselness iamge using Otsu's method:
b2a_options_otsu.stdev_1 = 0.75;
b2a_options_otsu.stdev_2 = 2.5;
b2a_options_otsu.stdev_inc = 0.5;
b2a_options_otsu.gauss_size = 18; 
b2a_options_otsu.vessel_beta = 0.75;
b2a_options_otsu.vessel_c = 1 - b2a_options_otsu.vessel_beta;
b2a_options_otsu.wavelet_damp = 10;
b2a_options_otsu.wavelet_kernel = 18;
b2a_options_otsu.wavelet_freq = 5;
b2a_options_otsu.min_angle = 160;
b2a_options_otsu.max_angle = 200;
b2a_options_otsu.num_angles = 31;
b2a_options_otsu.num_pixels = [45 45];
b2a_options_otsu.otsu = 1;

[angle_image, masked_angle_image, angle_image_grid, vector_image, vesselness_mask, vesselness_max, max_cvn_image, cvn_images, sample_wavelet] = ...
    bmode2angle_us(image_data_struc.gray(:,:,1), image_data_struc.mask, b2a_options_otsu);


% set options - mask vesselness image using k-means clustering:
% b2a_options_kmeans.stdev_1 = 0.75;
% b2a_options_kmeans.stdev_2 = 2.5;
% b2a_options_kmeans.stdev_inc = 0.5;
% b2a_options_kmeans.gauss_size = 18; 
% b2a_options_kmeans.vessel_beta = 0.75;
% b2a_options_kmeans.vessel_c = 1 - b2a_options_kmeans.vessel_beta;
% b2a_options_kmeans.wavelet_damp = 10;
% b2a_options_kmeans.wavelet_kernel = 18;
% b2a_options_kmeans.wavelet_freq = 5;
% b2a_options_kmeans.min_angle = 160;
% b2a_options_kmeans.max_angle = 200;
% b2a_options_kmeans.num_angles = 31;
% b2a_options_kmeans.num_pixels = [45 45];
% b2a_options_kmeans.k = [3 1];
% 
% [angle_image, masked_angle_image, angle_image_grid, vector_image, vesselness_mask, vesselness_max, max_cvn_image, cvn_images, sample_wavelet] = ...
%     bmode2angle_us(image_data_struc.gray(:,:,1), image_data_struc.mask, b2a_options_kmeans);


%% fiber-track

% set fiber-tracking options:
ft_options.step_size = 30;
ft_options.angle_thrsh = 20;
ft_options.image_num = 1;
ft_options.show_image = 1;

% set fiber visualization options:
fv_options.plot_tracts = 1;
fv_options.plot_mask = 1;
fv_options.plot_roi = 1;
fv_options.tract_color = [1 0 1];
fv_options.mask_color = [0 1 1];
fv_options.roi_color = [1 1 0];
fv_options.skip_tracts = 2;

[fiber_all_pixels, stop_list] = fiber_track_us(vector_image, roi_struc, image_data_struc, ft_options, fv_options);


%% smooth fibers using 2nd-order polynomials
close all

% set smoothing options:
fs_options.interp_distance = 0.5;
fs_options.poly_order = [2 2];

[smoothed_fiber_all_pixels, smoothed_fiber_all_mm, coeff_c_pixels, coeff_r_pixels, coeff_x_mm, coeff_y_mm] = ...
    fiber_smoother_us(fiber_all_pixels, image_info_struc, fs_options, image_data_struc.gray(:,:,1), roi_struc, fv_options);

% to run the function without visualizing the tracts (not recommended):
% [smoothed_fiber_all_pixels, smoothed_fiber_all_mm, coeff_c_pixels, coeff_r_pixels, coeff_x_mm, coeff_y_mm] = ...
%     fiber_smoother_us(fiber_all_pixels, image_info_struc, fs_options, image_data_struc.gray(:,:,1), roi_struc);


%% quantify fiber properties
close all

[penn_mean, tract_lengths, curvature_mean, curvature_all] = fiber_quantifier_us(smoothed_fiber_all_mm, roi_struc, image_info_struc);

% to visualize curvature values using a color scale (green = 0, red = maximum)
fv_options.tract_color = zeros(length(curvature_mean), 3);
fv_options.tract_color(:,1) = curvature_mean/max(curvature_mean);
fv_options.tract_color(:,2) = 1 - fv_options.tract_color(:,1);

curvature_figure = fiber_visualizer_us(image_data_struc.gray(:,:,1), fv_options, smoothed_fiber_all_pixels, roi_struc);

