%% Open file

% Initialize workspace
clear
close all
clc

% set file I/O options:
input_structure.input_path_name = ...                                       
    'S:\Muscle_DTI\Ultrasound_sample_images\Sample_US_2022.3.4';            % Local path to DICOM image file
input_structure.input_file_name = 'LG_2';                                   % Set input file name
input_structure.output_path_name = input_structure.input_path_name;         % Local path to MATLAB data file
input_structure.output_file_name =  'LG_2_raw_data.mat';                    % Set output file name
input_structure.show_image = 1;                                             % Opt to view the image

% call the function:
[image_data_struc, image_info_struc] = read_dicom_us(input_structure);

%% Form mask/Define region of interest for seed points

% set options
dmr_options.roi_resolution = 2;                                             % Define seed points at 2 mm spacing
dmr_options.frame_num = 1;                                                  % Use first frame in the dataset  

% close the current figure
close

% call the function
[image_data_struc, roi_struc] = define_muscleroi_us(image_data_struc, image_info_struc, dmr_options);


%% Estimate fascicle orientations

% set processing options for Gaussian filtering/vesselness filtering:
b2a_options.stdev_1 = 1.5;
b2a_options.stdev_2 = 3; 
b2a_options.stdev_inc = 0.5;
b2a_options.gauss_size = 15;
b2a_options.vessel_beta = 0.5; 
b2a_options.vessel_c = 0.5;

% set processing options for wavelet convolution/angle determination:
b2a_options.wavelet_damp = 2.5622;      
b2a_options.wavelet_kernel = 25;
b2a_options.wavelet_freq = 20;
b2a_options.min_angle = -136;                                               % minimum angle, inclusive
b2a_options.max_angle = -225;                                               % maximum angle, inclusive
b2a_options.num_angles = 180;                                               % 180 angles over 90 degree range

% set processing options for median filtering into grid squares:
b2a_options.num_pixels = 60;

% set grayscale image
image_gray = image_data_struc.gray(:,:);

% call the function:
[angle_image, masked_angle_image, angle_image_grid, vector_image] = bmode2angle_us(image_gray, image_data_struc.mask, b2a_options);

% notify when done
beep

%% Save file

save LG_2_preprocessed_data