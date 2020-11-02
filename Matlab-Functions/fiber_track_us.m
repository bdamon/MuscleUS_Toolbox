function [fiber_all_pixels, stop_list, angle_all] = fiber_track_us(vector_image, roi_struc, mask, ft_options, image_doub)

%% Get options from ft_options

% tracking options
step_incr = ft_options.step_size;

%tract termination options
angle_thrsh = ft_options.angle_thrsh;

%% Propagate fiber tract
% Get seed points
roi_points = roi_struc.fitted_r_pixels;                                     %column number
roi_points(2,:) = roi_struc.fitted_c_pixels;                                %row number

%initialize fiber_all: 1st dimension fiber track #, 2nd dimension point #,
%3rd dimension row/column indices
num_fibers = length(roi_points);
fiber_all_pixels = zeros(num_fibers,100,2);

%iterate point by point then move to the next fiber
stop_list=zeros(length(roi_points), 1);
angle_all = zeros(num_fibers, 100);

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
    angle_all(track_cntr,fiber_cntr) = acosd(dot(step_dir, [0 1]'));        %fiber orientation in image plane, with CCW rotation from east = 0
    
    %calculate next point
    fiber_cntr = fiber_cntr + 1;
    next_point = squeeze(fiber_all_pixels(track_cntr, fiber_cntr-1,:)) + ...
        step_incr*step_dir;
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
            step_incr*step_dir;
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

if nargin>4
    
    fiber_visualizer_us(image_doub, fiber_all_pixels, roi_struc)
    
end
