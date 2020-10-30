function [smoothed_fiber_all_pixels, smoothed_fiber_all_mm, coeff_c_pixels, coeff_r_pixels, coeff_x_mm, coeff_y_mm] = ...
    fiber_smoother_us(fiber_all, image_info_struc, fs_options, image_doub, roi_struc)

          
%% get options
poly_order = fs_options.poly_order;
interp_distance = fs_options.interp_distance;
interp_pixels = interp_distance/image_info_struc.PixelSpacing(1);

%% 
coeff_c_pixels = zeros(length(fiber_all(:,1,2)), poly_order(1)+1);
coeff_r_pixels = zeros(length(fiber_all(:,1,1)), poly_order(2)+1);
coeff_x_mm = zeros(length(fiber_all(:,1,2)), poly_order(1)+1);
coeff_y_mm = zeros(length(fiber_all(:,1,1)), poly_order(2)+1);

for track_cntr=1:length(fiber_all(:,1,1))
    
    if length(nonzeros(fiber_all(track_cntr,:,2)))>10
        
        loop_track_points = [nonzeros(fiber_all(track_cntr,:,1)) nonzeros(fiber_all(track_cntr,:,2))];
        loop_track_mm = 0*loop_track_points;
        loop_track_mm(:,2) = loop_track_points(:,1)*image_info_struc.PixelSpacing(2);
        loop_track_mm(:,1) = loop_track_points(:,2)*image_info_struc.PixelSpacing(1);
        
        track_length_points = [0; cumsum((diff(loop_track_points(:,1)).^2 + diff(loop_track_points(:,2)).^2).^0.5)];
        coeff_c_pixels(track_cntr,:) = polyfit(track_length_points, loop_track_points(:,2), poly_order(1));
        coeff_r_pixels(track_cntr,:) = polyfit(track_length_points, loop_track_points(:,1), poly_order(2));
        smoothed_track_points=[];
        smoothed_track_points(:,1) = polyval(coeff_r_pixels(track_cntr,:), 0:interp_pixels:max(track_length_points));
        smoothed_track_points(:,2) = polyval(coeff_c_pixels(track_cntr,:), 0:interp_pixels:max(track_length_points));
        smoothed_fiber_all_pixels(track_cntr, 1:length(smoothed_track_points), :) = smoothed_track_points; %#ok<AGROW>
        
        track_length_mm = [0; cumsum((diff(loop_track_mm(:,1)).^2 + diff(loop_track_mm(:,2)).^2).^0.5)];
        coeff_x_mm(track_cntr,:) = polyfit(track_length_mm, loop_track_mm(:,1), poly_order(2));
        coeff_y_mm(track_cntr,:) = polyfit(track_length_mm, loop_track_mm(:,2), poly_order(1));
        smoothed_track_mm=[];
        smoothed_track_mm(:,1) = polyval(coeff_x_mm(track_cntr,:), 0:interp_distance:max(track_length_mm));
        smoothed_track_mm(:,2) = polyval(coeff_y_mm(track_cntr,:), 0:interp_distance:max(track_length_mm));
        smoothed_fiber_all_mm(track_cntr, 1:length(smoothed_track_mm), :) = smoothed_track_mm; %#ok<AGROW>        
        
    end
    
end

%% view results

if nargin>3

    fiber_visualizer_us(image_doub, smoothed_fiber_all_pixels, roi_struc)

end

%% end frunction
return;