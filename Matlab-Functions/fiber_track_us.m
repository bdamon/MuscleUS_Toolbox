function [fiber_all_pixels, stop_list] = fiber_track_us(vector_image, roi_struc, image_data_struc, ft_options, fv_options)
%
%FUNCTION fiber_track_us
%  [fiber_all_pixels, stop_list] = fiber_track_us(vector_image, roi_struc, mask, ft_options, image_doub);
%
%USAGE
%  The function fiber_track_us is used to perform fiber tractography in the
%  MuscleUS_Toolbox. The inputs are derived from previous file opening
%  (i.e, read_dicom_us), ROI definition (define_muscle_roi_us), and image
%  processing (bmode2angle_us) steps.  
%
%  Fiber tracking occurs using Euler integration of the vectors that are
%  used to describe muscle fascicle orientation, at a user-defined step size.
%
%  The outputs include a matrix containing fiber tracts, with units of
%  pixels; and a vector containing the reason for fiber tract stoppage.  
%
%INPUT ARGUMENT
%  vector_image: a spatial map of X and Y vector components of the fascicle
%    orientation, at each pixel, in the gridded angle image
%
%  roi_struc: the output of define_muscle_roi_us
%
%  image_data_struc: the output of define_muscle_roi_us
%
%  ft_options: a structure containing the following options for
%   fiber-tracking:
%    -.step_size: the fiber-tracking step size, in pixels;
%    -.angle_thrsh: the inter-step angle above which fiber tracking would
%      terminate, in degrees;
%    -.image_num: within a time series dataset, the image number to analyze
%      (use 1 for a single-time point measurement)
%    -.show_image: use 1 to display the initial result after fiber-tracking
%      or 0 not to display the result
%
%  fv_options: As defined in fiber_visualizer_us
%
%OUTPUT ARGUMENTS
%  fiber_all_pixels: The fiber tracking data, with size MxNx2, where M is
%    the number of fiber tracts, N is the number of points in the fiber
%    tract (being padded with zeros because of varying fiber tract lengths, 
%    and the third dimension includes row adn colume (Y and X) positions. The 
%    units are image pixels.
%
%  stop_list: A vector containing the reason for tract termination, with 1 =
%    reaching the muscle border, as defined by the mask; and 2 = an excessive
%    inter-point angle.
%
%VERSION INFORMATION
%  v. 0.1
%
%ACKNOWLEDGEMENTS
%  People: Hannah Kilpatrick, Bruce Damon
%  Grant support: NIH/NIAMS R01 AR073831

%% Get variations from input structure

% options from ft_options
step_size = ft_options.step_size;
angle_thrsh = ft_options.angle_thrsh;
if isfield(ft_options, 'image_num')
    image_num = ft_options.image_num;
else 
    image_num = 1;
end
if isfield(ft_options, 'show_image')
    show_image = 1;
else 
    show_image = 0;
end

%data from image_data_struc
mask = image_data_struc.mask;
image_gray = image_data_struc.gray(:,:,image_num);

%% Propagate fiber tract
% Get seed points
roi_points = roi_struc.fitted_roi_r_pixels;                                     %column number
roi_points(2,:) = roi_struc.fitted_roi_c_pixels;                                %row number

%initialize fiber_all: 1st dimension fiber track #, 2nd dimension point #,
%3rd dimension row/column indices
num_fibers = length(roi_points);
fiber_all_pixels = zeros(num_fibers,100,2);

%iterate point by point then move to the next fiber
stop_list=zeros(length(roi_points), 1);

for track_cntr = 1:num_fibers
    
    fiber_cntr=1;                                                                    %reset counter for each new fiber
    
    %update seed point for each fiber
    seed_point = roi_points(:,track_cntr);
    row_point = round(seed_point(1));
    col_point = round(seed_point(2));
    
    %if within the mask, add to fiber_all
    if mask(row_point, col_point)
        fiber_all_pixels(track_cntr,fiber_cntr,1:2) = roi_points(:,track_cntr);                   %save seed point
    else
        stop_list(track_cntr) = 1;
        continue
    end
    
    %get next direction
    step_dir = squeeze(vector_image(row_point, col_point,:));               %local fascicle orientation
    step_dir_old = step_dir;                                                %to be used for inter-point angle calculations
    
    %calculate next point
    fiber_cntr = fiber_cntr + 1;
    next_point = squeeze(fiber_all_pixels(track_cntr, fiber_cntr-1,:)) + ...
        step_size*step_dir;
    row_point = round(next_point(1));
    col_point = round(next_point(2));
    
    %if within the mask, add to fiber_all
    if row_point<=0 || row_point>=length(mask(:,1))
        stop_list(track_cntr) = 1;
        continue
    end
    
    if col_point<=0|| col_point>=length(mask(1,:))
        stop_list(track_cntr) = 1;
        continue
    end
    
    if mask(row_point, col_point)
        fiber_all_pixels(track_cntr,fiber_cntr,1:2) = next_point;                   %save next point
    else
        stop_list(track_cntr) = 1;
        continue
    end
    
    %begin fiber tracking loop
    while 1
        
        %calculate next point
        step_dir = squeeze(vector_image(row_point, col_point,:));
        next_point = squeeze(fiber_all_pixels(track_cntr, fiber_cntr-1,:)) + ...
            step_size*step_dir;
        row_point = round(next_point(1));
        col_point = round(next_point(2));
        
        %check for mask criterion
        if row_point<=0 || row_point>=length(mask(:,1))
            stop_list(track_cntr) = 1;
            break
        end
        
        if col_point<=0|| col_point>=length(mask(1,:))
            stop_list(track_cntr) = 1;
            break
        end
        
        if mask(row_point, col_point)
            fiber_all_pixels(track_cntr,fiber_cntr,1:2) = roi_points(:,track_cntr);                   %save seed point
        else
            stop_list(track_cntr) = 1;
            break
        end
        
        %check for angle criterion
        step_angle = abs(acosd(dot(step_dir, step_dir_old)));
        if step_angle > angle_thrsh
            
            stop_list(track_cntr) = 2;                                      %stopped because angle > threshold value
            break
            
        else
            
            %add to fiber_all matrix
            fiber_all_pixels(track_cntr, fiber_cntr,:) = next_point;
            
            %prepare for next time through the loop
            step_dir_old = step_dir;
            fiber_cntr = fiber_cntr + 1;
            
        end
        
    end
    
end

%% view results

if show_image==1
    
    fiber_visualizer_us(image_gray, fv_options, fiber_all_pixels, roi_struc)
    
end
