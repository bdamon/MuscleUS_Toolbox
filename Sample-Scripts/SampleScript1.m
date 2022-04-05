%% Initialize workspace
clear
close all
clc

%% Open file
input_structure.input_path_name = 'S:\Muscle_DTI\Ultrasound_sample_images\Sample_US_2022.3.4';
input_structure.input_file_name = 'TA_4';
input_structure.output_path_name = input_structure.input_path_name;
input_structure.output_file_name =  'TA_4_output.mat';
input_structure.show_image = 1;

[image_data_struc, image_info_struc] = read_dicom_us(input_structure);

%% Define muscle and aponeurosis ROIs

dmr_options.roi_resolution = 1;                         %mm
dmr_options.frame_num = 1;                         
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
b2a_options.wavelet_damp = 2.56;
b2a_options.wavelet_kernel = 25;
b2a_options.wavelet_freq = 20;
b2a_options.min_angle = -135;
b2a_options.max_angle = -225;
b2a_options.num_angles = 91;
b2a_options.num_pixels = 60;

%convert b-mode image to angle image
image_gray = image_data_struc.gray(:,:);
[angle_image, masked_angle_image, angle_image_grid, vector_image] = bmode2angle_us(image_gray, image_data_struc.mask, b2a_options);

%% view results
figure('units', 'normalized', 'position', [.05 .1 .9 .8])
subplot(2,3,1)
show_image = cat(3, image_data_struc.gray, image_data_struc.gray, image_data_struc.gray);
show_image = show_image/max(max(max(show_image)));
imagesc(show_image)
axis image
title('B-Mode Image')
hold on
plot(roi_struc.fitted_roi_c_pixels(1:length(find(roi_struc.fitted_roi_c_pixels))), ...
    roi_struc.fitted_roi_r_pixels(1:length(find(roi_struc.fitted_roi_r_pixels))), 'r', 'linewidth', 1)
plot(roi_struc.muscle_c_pixels, roi_struc.muscle_r_pixels, 'y', 'linewidth', 1)

subplot(2,3,2)
imagesc(vector_image(:,:,1))
caxis([-1 1])
axis image
title('Vector Image (Y)')
hold on
plot(roi_struc.fitted_roi_c_pixels(1:length(find(roi_struc.fitted_roi_c_pixels))), ...
    roi_struc.fitted_roi_r_pixels(1:length(find(roi_struc.fitted_roi_r_pixels))), 'r', 'linewidth', 1)
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
plot(roi_struc.fitted_roi_c_pixels(1:length(find(roi_struc.fitted_roi_c_pixels))), ...
    roi_struc.fitted_roi_r_pixels(1:length(find(roi_struc.fitted_roi_r_pixels))), 'r', 'linewidth', 1)

subplot(2,3,4)
imagesc(angle_image)
axis image
title('Unmasked Angle Image')
hold on
plot(roi_struc.fitted_roi_c_pixels(1:length(find(roi_struc.fitted_roi_c_pixels))), ...
    roi_struc.fitted_roi_r_pixels(1:length(find(roi_struc.fitted_roi_r_pixels))), 'r', 'linewidth', 1)

subplot(2,3,5)
imagesc(masked_angle_image)
axis image
title('Masked Angle Image')
hold on
plot(roi_struc.fitted_roi_c_pixels(1:length(find(roi_struc.fitted_roi_c_pixels))), ...
    roi_struc.fitted_roi_r_pixels(1:length(find(roi_struc.fitted_roi_r_pixels))), 'r', 'linewidth', 1)

subplot(2,3,6)
imagesc(angle_image_grid)
title('Median Angle Image')
axis image
cb=colorbar;
cb.Position(1) = cb.Position(1)*1.05;
hold on
plot(roi_struc.fitted_roi_c_pixels(1:length(find(roi_struc.fitted_roi_c_pixels))), ...
    roi_struc.fitted_roi_r_pixels(1:length(find(roi_struc.fitted_roi_r_pixels))), 'r', 'linewidth', 1)

%% Fiber track
clc
ft_options.step_size = 30;                                                  %in pixels
ft_options.angle_thrsh = 25;                                                %in degrees
ft_options.show_image = 1;                                                %show the image
ft_options.image_num = 1;
    fv_options.tract_color=[1 1 0];
    fv_options.roi_color=[0 1 1];

[fiber_all, stop_list] = fiber_track_us(vector_image, roi_struc, image_data_struc, ft_options, fv_options);


%% Smooth and quantify fiber properties

fs_options.poly_order = [3 3];
fs_options.interp_distance = 0.1;

[smoothed_fiber_all_pixels, smoothed_fiber_all_mm, coeff_c_pixels, coeff_r_pixels, coeff_x_mm, coeff_y_mm] = ...
    fiber_smoother_us(fiber_all, image_info_struc, fs_options, image_gray, roi_struc, fv_options);

[penn_mean, tract_lengths, curvature_mean, curvature_all] = fiber_quantifier_us(smoothed_fiber_all_mm, roi_struc, image_info_struc);

%% View final result
fv_options.tract_color(1:24,1)=curvature_mean/5;
fv_options.tract_color(1:24,2)=1-curvature_mean/5;
fv_options.tract_color(1:24,3)=0;

fiber_visualizer_us(image_gray, fv_options, fiber_all, roi_struc);
fiber_visualizer_us(image_gray, fv_options, smoothed_fiber_all_pixels, roi_struc);
