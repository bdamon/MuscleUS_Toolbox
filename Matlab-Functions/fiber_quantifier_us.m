function [apo_vector, tract_vector, penn_mean, curvature_mean, curvature_all] = fiber_quantifier_us(fiber_all_mm, roi_struc, image_info_struc)


%% calculate pennation angle
num_tracts = length(fiber_all_mm(:,1,1));
apo_vector = zeros(num_tracts,2);
tract_vector = zeros(num_tracts,2);
penn_mean = zeros(num_tracts,1);
curvature_mean = zeros(num_tracts,1);
curvature_all = (0*fiber_all_mm(:,:,1));

roi_x_mm = roi_struc.fitted_c_pixels*image_info_struc.PixelSpacing(1);
roi_y_mm = roi_struc.fitted_r_pixels*image_info_struc.PixelSpacing(2);
for track_cntr = 2:(num_tracts-1)
    
    %get tract, convert to mm
    loop_track_mm = [nonzeros(fiber_all_mm(track_cntr,:,1)) nonzeros(fiber_all_mm(track_cntr,:,2))];
    track_length_mm = [0; cumsum((diff(loop_track_mm(:,1)).^2 + diff(loop_track_mm(:,2)).^2).^0.5)];
    if max(track_length_mm)<5
        continue
    end
    index_5mm = find(track_length_mm>5, 1);
    
    %calculate pennation angle
    apo_vector(track_cntr,1:2) = [(roi_y_mm(track_cntr+1) - roi_y_mm(track_cntr-1)) (roi_x_mm(track_cntr+1) - roi_x_mm(track_cntr-1))];
    apo_vector(track_cntr,1:2) = apo_vector(track_cntr,1:2)/norm(apo_vector(track_cntr,1:2));
    tract_vector(track_cntr, 1:2) = [(loop_track_mm(index_5mm,2) - loop_track_mm(1,2)) (loop_track_mm(index_5mm,1) - loop_track_mm(1,1))];
    tract_vector(track_cntr,1:2) = tract_vector(track_cntr,1:2)/norm(tract_vector(track_cntr,1:2));
    
    penn_mean(track_cntr) = real(acosd(dot(apo_vector(track_cntr,1:2),tract_vector(track_cntr,1:2))));
    
    %calculate curvature along tract
    for fiber_cntr = 2:(length(nonzeros(track_length_mm))-3)           %curvature values blow up at the end of the fiber because the rest of the vector is padded with 0's
        
        %curvature measurements use a discrete implementation of the Frenet equations.
        p1_idx = fiber_cntr-1;                                                  %indices for the three points of interest along the tract - define two pairs of points
        p2_idx = fiber_cntr;
        p3_idx = fiber_cntr+1;
        loop_fiber_m = loop_track_mm/1000;                                      %convert from mm to m for curvature measurements
        
        r_1 = (loop_fiber_m(p1_idx,:))-loop_fiber_m(1,:);                       %three position vectors, one for each point
        r_2 = (loop_fiber_m(p2_idx,:))-loop_fiber_m(1,:);
        r_3 = (loop_fiber_m(p3_idx,:))-loop_fiber_m(1,:);
        
        ds21 = sqrt(sum((loop_fiber_m(p2_idx,:)-loop_fiber_m(p1_idx,:)).^2));   %distance between points 1 and 2 and (below) 2 and 3
        ds32 = sqrt(sum((loop_fiber_m(p3_idx,:)-loop_fiber_m(p2_idx,:)).^2));
        
        tangent_vector_2 = (r_2-r_1)/norm(r_2-r_1);                           	%normalized tangent lines between the two pairs of points
        tangent_vector_3 = (r_3-r_2)/norm(r_3-r_2);
        dTds = ((tangent_vector_3-tangent_vector_2)/mean([ds21 ds32]))';      	%dT/ds is the spatial rate of change in tangent lines
        dTds(isnan(dTds)) = 0;
        
        if sum(dTds) ~= 0
            N_vector = dTds/norm(dTds);                                         %normal to tangent lines
            curvature_all(track_cntr,fiber_cntr) = pinv(N_vector)*dTds;	%based on dT/ds = curvature * N
        end
        
    end
    
    curvature_mean(track_cntr) = mean(nonzeros(curvature_all(track_cntr,:)));
end

%% end function
return;
