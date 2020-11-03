function [image_data_struc, roi_struc] = define_muscleroi_us(image_data_struc, image_info_struc, dmr_options)
%
%FUNCTION define_muscle_roi
%  [image_data_struc, roi_struc] = define_muscle_roi(image_data_struc, image_info_struc, roi_resolution);
%
%USAGE
%  The function define_muscleroi_us is used to define regions of interest in
%  the MuscleUS_Toolbox. An image is displayed and the user is prompted to
%  define the muscle region of interest using the roi_poly tool. The resulting 
%  binary image mask is applied to the images and added to the image_data_struc
%  structure.
%
%  Then the user is prompted to define the aponeurosis of muscle fascicle
%  insertion using a series of left mouse clicks. A 2nd order polynomial 
%  curve is fitted to the points. Evenly spaced points along this curve  
%  will become the seed points for fiber-tracking.
%
%  After each step, the user can inspect and verify these definitions.
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
%     points, in mm
%    -frame_num: The frame number within the image data to be analyzed.  If
%     not specified, the first frame is used.
%
%OUTPUT ARGUMENTS
%  image_data_struc: The input structure, plus the following additional
%   fields:
%    -mask: A binary image mask defining the muscle of interest
%    -masked_gray: The mask applied to the grayscale images.
%
%  roi_struc: A structure with information about the seed surface ROI,
%   containing the following fields:
%    -roi_x_points: The selected X points
%    -roi_y_points: The selected Y points
%    -fitted_x_points: The fitted X points
%    -fitted_y_points: The fitted Y points
%    -roi_resolution: The distance between fiber tracking points
%    -roi_points_params: The fitted parameters for pixel locations in the
%     ROI
%
%VERSION INFORMATION
%  v. 0.1
%
%ACKNOWLEDGEMENTS
%  Grant support: NIH/NIAMS R01 AR073831

%% Get first image out of structure and display it

roi_resolution = dmr_options.roi_resolution;
if isfield(dmr_options, 'frame_num')
    frame_num = dmr_options.frame_num;
else
    frame_num = 1;
end

show_image = squeeze(image_data_struc.gray(:,:,frame_num));

%% Prompt user to define muscle of interest

figure('units', 'normalized', 'position', [.1 .1 .8 .7])
k=0;
while 1
    
    clf
    imagesc(show_image)
    colormap gray
    axis image
    if k==1
        set(gcf, 'position', fig_position);
    end
    
    title('Define muscle region of interest; Right-click and select Create Mask when finished')
    [mask, muscle_c_pixels, muscle_r_pixels] = roipoly;
    hold on
    plot(muscle_c_pixels, muscle_r_pixels, 'c')
    
    fig_position = get(gcf, 'position');
    k=1;
    
    title('Press Enter to continue or any letter/Enter to repeat your selection')
    temp = input('Press Enter to continue or any letter/Enter to repeat your selection: ', 's');
    
    if isempty(temp)
        break
    end

end

image_data_struc.mask = mask;
image_data_struc.muscle_c_pixels = muscle_c_pixels;
image_data_struc.muscle_r_pixels = muscle_r_pixels;

close

%% Apply mask to images

image_data_struc.masked_doub = zeros(size(image_data_struc.doub));

if length(size(image_data_struc.orig))==4
    
        for t=1:length(image_data_struc.orig(1,1,1,:))
            
            loop_image_gray = image_data_struc.gray(:,:,t);
            image_data_struc.masked_gray(:,:,t) = loop_image_gray.*mask;
            
        end
    
else
        
        loop_image_gray = image_data_struc.gray;
        image_data_struc.masked_gray = loop_image_gray.*mask;
        
end

%% Define points for aponeurosis

figure('units', 'normalized', 'position', [.1 .1 .8 .7])

while 1
    
    clf
    imagesc(show_image)
    colormap gray
    axis image
    hold on
    plot(muscle_c_pixels, muscle_r_pixels, 'c')
    set(gcf, 'position', fig_position);
    
    title('Define surface for seed points using left mouse clicks; Press enter when finished')
    [roi_c_pixels, roi_r_pixels] = ginputWhite;
    hold on
    plot(roi_c_pixels, roi_r_pixels, 'y.', 'markersize', 12)
    
    %form smoothed line
    roi_pixels_params = polyfit(roi_c_pixels, roi_r_pixels, 2);
    temp_c_pixels = min(roi_c_pixels):10:max(roi_c_pixels);
    temp_r_pixels = polyval(roi_pixels_params, temp_c_pixels);
    
    %convert to mm and calculate distances
    temp_x_distance = temp_c_pixels*image_info_struc.PixelSpacing(1);
    temp_y_distance = temp_r_pixels*image_info_struc.PixelSpacing(2);
    temp_distance = temp_x_distance(1) + ...
        [0 cumsum((diff(temp_x_distance).^2 + diff(temp_y_distance).^2).^0.5)];
    roi_distance_params = polyfit(temp_x_distance, temp_y_distance, 2);

    %interpolate to desired spacing
    roi_distance = min(roi_c_pixels)*image_info_struc.PixelSpacing:roi_resolution:...
        max(roi_c_pixels)*image_info_struc.PixelSpacing;
    fitted_c_pixels = interp1(temp_distance, temp_c_pixels, roi_distance);
    fitted_r_pixels = interp1(temp_distance, temp_r_pixels, roi_distance);
    
    %view and verify result
    plot(fitted_c_pixels, fitted_r_pixels, 'y');
    title('Press Enter to continue or any letter/Enter to repeat your selection')
    temp = input('Press Enter to continue or any letter/Enter to repeat your selection: ', 's');
    
    fig_position = get(gcf, 'position');
    
    if isempty(temp)
        break
    end
    
end

roi_struc.roi_c_pixels = roi_c_pixels;
roi_struc.roi_r_pixels = roi_r_pixels;
roi_struc.fitted_c_pixels = temp_c_pixels;
roi_struc.fitted_r_pixels = temp_r_pixels;
roi_struc.roi_resolution = roi_resolution;
roi_struc.roi_pixels_params = roi_pixels_params;
roi_struc.roi_distance_params = roi_distance_params;

%% End function

return

