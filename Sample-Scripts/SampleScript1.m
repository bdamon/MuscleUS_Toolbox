%% Initialize workspace
clear
close all
clc

%% Open file
input_structure.input_path_name = 'C:\Users\damonbm\Documents\Research\Data and Data Analysis\Ultrasound\DICOM';
input_structure.input_file_name = 'IM_0013.DCM';
input_structure.output_path_name = input_structure.input_path_name;
input_structure.output_file_name =  'IM_0013.mat';
input_structure.show_image = 1;

[image_data_struc, image_info_struc] = read_dicom_us(input_structure);

%% Define muscle and aponeurosis ROIs
frame_num=1;

dmr_options.roi_resolution = 1;                         %mm
dmr_options.frame_num = frame_num;                         
[image_data_struc, roi_struc] = define_muscleroi_us(image_data_struc, image_info_struc, dmr_options);

close all

%% Process images

%set processing options
b2a_options.stdev_1 = 1.5;
b2a_options.stdev_2 = 3; 
b2a_options.stdev_inc = 0.5;
b2a_options.gauss_size = 15;
b2a_options.vessel_beta = 0.5; 
b2a_options.vessel_c = 0.5;
b2a_options.wavelet_damp = 2.5622;
b2a_options.wavelet_kernel = 25;
b2a_options.wavelet_freq = 20;
b2a_options.min_angle = -181;
b2a_options.max_angle = -91;
b2a_options.num_angles = 82;
b2a_options.num_pixels = 75;

%convert b-mode image to angle image
image_doub = image_data_struc.doub(:,:,frame_num);
[angle_image, masked_angle_image, angle_image_grid, vector_image] = bmode2angle_us(image_doub, image_data_struc.mask, b2a_options);

%view results
figure('units', 'normalized', 'position', [.05 .1 .9 .8])
subplot(2,3,1)
imagesc(image_data_struc.doub(:,:,:,1))
axis image
title('B-Mode Image')
hold on
plot(roi_struc.fitted_c_pixels, roi_struc.fitted_r_pixels, 'r', 'linewidth', 2)
plot(image_data_struc.muscle_c_pixels, image_data_struc.muscle_r_pixels, 'y', 'linewidth', 2)

subplot(2,3,2)
imagesc(vector_image(:,:,1))
caxis([-1 1])
axis image
title('Vector Image (Y)')
hold on
plot(roi_struc.fitted_c_pixels, roi_struc.fitted_r_pixels, 'r', 'linewidth', 2)
cb=colorbar;
cb.Position(1) = cb.Position(1)*1.08;

subplot(2,3,3)
imagesc(vector_image(:,:,2))
caxis([-1 1])
title('Vector Image (X)')
axis image
cb=colorbar;
cb.Position(1) = cb.Position(1)*1.08;
hold on
plot(roi_struc.fitted_c_pixels, roi_struc.fitted_r_pixels, 'r', 'linewidth', 2)

subplot(2,3,4)
imagesc(angle_image)
axis image
title('Unmasked Angle Image')
hold on
plot(roi_struc.fitted_c_pixels, roi_struc.fitted_r_pixels, 'r', 'linewidth', 2)
plot(image_data_struc.muscle_c_pixels, image_data_struc.muscle_r_pixels, 'k', 'linewidth', 2)

subplot(2,3,5)
imagesc(masked_angle_image)
axis image
title('Masked Angle Image')
hold on
plot(roi_struc.fitted_c_pixels, roi_struc.fitted_r_pixels, 'r', 'linewidth', 2)

subplot(2,3,6)
imagesc(angle_image_grid)
title('Median Angle Image')
axis image
cb=colorbar;
cb.Position(1) = cb.Position(1)*1.05;
hold on
plot(roi_struc.fitted_c_pixels, roi_struc.fitted_r_pixels, 'r', 'linewidth', 2)

%% Fiber track

ft_options.step_size = 25;                                                  %in pixels
ft_options.angle_thrsh = 10;                                                %in degrees

[fiber_all, stop_list, angle_all] = fiber_track_us(vector_image, roi_struc, image_data_struc.mask, ft_options, image_doub);


%% Smooth and quantify fiber properties

fs_options.poly_order = [3 3];
fs_options.interp_distance =0.1;

[smoothed_fiber_all_pixels, smoothed_fiber_all_mm, coeff_c_pixels, coeff_r_pixels, coeff_x_mm, coeff_y_mm] = ...
    fiber_smoother_us(fiber_all, image_info_struc, fs_options, image_doub, roi_struc);

[apo_vector, tract_vector, penn_mean, curvature_mean, curvature_all] = fiber_quantifier_us(smoothed_fiber_all_mm, roi_struc, image_info_struc);

%% View final result
fiber_visualizer_us(image_doub, fiber_all, roi_struc);
fiber_visualizer_us(image_doub, smoothed_fiber_all_pixels, roi_struc);
