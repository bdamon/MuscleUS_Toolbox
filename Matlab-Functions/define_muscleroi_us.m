function [image_data_struc, roi_struc] = define_muscleroi_us(image_data_struc, image_info_struc, dmr_options)
%
%FUNCTION define_muscle_roi
%  [image_data_struc, roi_struc] = define_muscle_roi(image_data_struc, image_info_struc, roi_resolution);
%
%USAGE
%  The function define_muscleroi_us is used to define regions of interest in
%  the MuscleUS_Toolbox. An image is displayed and the user is prompted to
%  define the muscle region of interest using the roipoly tool. The resulting 
%  binary image mask, and other information about the region defined, are 
%  output.
%
%  Then the user is prompted to define the aponeurosis of muscle fascicle
%  insertion using a series of left mouse clicks. A 2nd order polynomial 
%  curve is fitted to the points. Evenly spaced points along this curve  
%  will become the seed points for fiber-tracking.  The user can define the
%  density (spacing) of these seed points.
%
%  After each step, the user can inspect and verify these definitions
%  before advancing.
%
%INPUT ARGUMENT
%  image_data_struc: A structure containing the imaging data, output from 
%   read_dicom_us
%
%  image_info_struc: A structure containing the imaging metadata, output from 
%   read_dicom_us
%
%  dmr_options: A structure containing the following fields:
%    -roi_resolution: The desired distance between fiber tracking seed  
%      points, in mm
%    -frame_num: The frame number within the image data series to be analyzed.
%      If the data containing a time series, this is the frame number. If 
%      there is only one image, use 1;
%
%OUTPUT ARGUMENTS
%  image_data_struc: The input structure, plus the following additional
%   fields:
%    -mask: A binary image mask defining the muscle of interest
%    -masked_gray: The mask applied to the grayscale images.
%
%  roi_struc: A structure with information about the seed surface ROI,
%   containing the following fields:
%    -muscle_c_pixels: The X (column) points used to define the muscle ROI
%    -muscle_r_pixels: The Y (row) points used to define the muscle ROI
%    -roi_c_pixels: The selected X (column) points
%    -roi_r_pixels: The selected Y (row) points
%    -fitted_roi_c_pixels: The fitted X (column) points
%    -fitted_roi_r_pixels: The fitted Y (row) points
%    -roi_resolution: The distance between fiber tracking points
%    -roi_pixels_params: The fitted parameters for pixel locations in the
%      ROI
%
%VERSION INFORMATION
%  v. 0.1
%
%ACKNOWLEDGEMENTS
%  Grant support: NIH/NIAMS R01 AR073831


%% Prompt user to define muscle of interest in every dynamic of interest

frame_num = dmr_options.frame_num;           %which frames to be analyzed
image_data_struc.mask = zeros(size(squeeze(image_data_struc.gray(:,:,1)))); %initialization of the mask

figure('units', 'normalized', 'position', [.1 .1 .8 .7])
fig_position = get(gcf, 'position');

while 1

    show_image = image_data_struc.gray(:,:,frame_num);
    clf
    imagesc(show_image)
    colormap gray
    axis image
    set(gcf, 'position', fig_position);
    
    title('Define muscle region of interest; Right-click and select Create Mask when finished')
    [mask, temp_roi_c_pixels, temp_roi_r_pixels] = roipoly;
    hold on
    plot(temp_roi_c_pixels, temp_roi_r_pixels, 'c')
    
    fig_position = get(gcf, 'position');
    
    title('Press Enter to continue or any letter/Enter to repeat your selection')
    temp = input('Press Enter to continue or any letter/Enter to repeat your selection: ', 's');
    
    % Apply mask to images/store in output structure
    image_data_struc.mask = mask;
    image_data_struc.masked_gray = mask.*image_data_struc.gray(:,:,frame_num);
    roi_struc.muscle_c_pixels = temp_roi_c_pixels;
    roi_struc.muscle_r_pixels = temp_roi_r_pixels;
    
    if isempty(temp)
        break
    end

end


%% Define points for aponeurosis

roi_resolution = dmr_options.roi_resolution;

figure('units', 'normalized', 'position', [.1 .1 .8 .7])

while 1

    show_image = image_data_struc.gray(:,:,frame_num);
    clf
    imagesc(show_image)
    colormap gray
    axis image
    set(gcf, 'position', fig_position);
    hold on
    plot(temp_roi_c_pixels, temp_roi_r_pixels, 'c')
    
    title('Define surface for seed points using left mouse clicks; Press right mouse button when finished')
    j=1;
    while 1
        [temp_c, temp_r, b] = ginput(1);
        if b==1
            temp_c_pixels(j) = temp_c;
            temp_r_pixels(j) = temp_r;
            plot(temp_c_pixels(j), temp_r_pixels(j), 'y.', 'markersize', 12)
            j=j+1;
        else
            break
        end
    end

    roi_c_pixels = temp_c_pixels;
    roi_r_pixels = temp_r_pixels;
    
    
    %form smoothed line
    roi_pixels_params = polyfit(temp_c_pixels, temp_r_pixels, 2);
    temp_fitted_c_pixels = min(temp_c_pixels):max(temp_c_pixels);
    temp_fitted_r_pixels = polyval(roi_pixels_params, temp_fitted_c_pixels);
    
    %convert to mm and calculate distances
    temp_fitted_x_distance = temp_fitted_c_pixels*image_info_struc.PixelSpacingX;
    temp_fitted_y_distance = temp_fitted_r_pixels*image_info_struc.PixelSpacingY;
    temp_distance = [0 cumsum((diff(temp_fitted_x_distance).^2 + diff(temp_fitted_y_distance).^2).^0.5)];

    %interpolate to desired spacing
    roi_distance = 0:roi_resolution:max(temp_distance);
    temp_fitted_c_pixels = interp1(temp_distance, temp_fitted_c_pixels, roi_distance);
    temp_fitted_r_pixels = interp1(temp_distance, temp_fitted_r_pixels, roi_distance);

    %store fitted roi - distance
    roi_struc.fitted_roi_r_distance = temp_fitted_r_pixels*image_info_struc.PixelSpacingY;
    roi_struc.fitted_roi_c_distance = temp_fitted_c_pixels*image_info_struc.PixelSpacingX;
    
    %store fitted roi - pixels
    fitted_roi_r_pixels = temp_fitted_r_pixels;
    fitted_roi_c_pixels = temp_fitted_c_pixels;
    
    %view and verify result
    plot(temp_fitted_c_pixels, temp_fitted_r_pixels, 'y');
    title('Press Enter to continue or any letter/Enter to repeat your selection')
    temp = input('Press Enter to continue or any letter/Enter to repeat your selection: ', 's');
    
    fig_position = get(gcf, 'position');
    
    if isempty(temp)
        break
    end
    
end

roi_struc.roi_c_pixels = roi_c_pixels;
roi_struc.roi_r_pixels = roi_r_pixels;
roi_struc.fitted_roi_c_pixels = fitted_roi_c_pixels;
roi_struc.fitted_roi_r_pixels = fitted_roi_r_pixels;
roi_struc.roi_resolution = roi_resolution;
roi_struc.roi_pixels_params = roi_pixels_params;

%% End function

return

