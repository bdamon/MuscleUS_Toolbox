function [penn_mean, tract_lengths, curvature_mean, curvature_all] = fiber_quantifier_us(fiber_all_mm, roi_struc, image_info_struc)
%
%FUNCTION fiber_quantifier_us
%  [penn_mean, tract_lengths, curvature_mean, curvature_all] = ...
%    fiber_quantifier_us(fiber_all_mm, roi_struc, image_info_struc);
%
%USAGE
%  The function fiber_quantifier_us is used to calculate the muscle
%  architectural parameters fiber tract length, pennation angle, and
%  curvature in the MuscleUS_Toolbox.
%
%  The user inputs a matrix containing fiber tract positions, specified in
%  units of mm; a structure containing information about the seeding region
%  of interest; and a structure containing image metadata. Computations are
%  made automatically; the length of the full tract, pennation angle over the
%  first 5 mm, and curvature at each point are calculated.  The procedures
%  for each calculation are:
%    -Fiber tract length: This is measured by summing the inter-point 
%     distances along the tract.
%
%    -Pennation: For each fiber tract, position vectors are formed along the
%     local segment of the aponeurosis and the first 5 mm of the tract.
%     Each position vector is converted to unit length.  The pennation
%     angle is calculated as the inverse cosine of the dot product of the
%     two vectors.
% 
%    -Curvature: The method for curvature measurements is adapted from Damon 
%     et al, Magn Reson Imaging 2012. Briefly, these use a discrete 
%     implementation of the Frenet-Serret equations. Specifically, the 
%     curvature K is defined in
%       dT/ds = K N
%     where T is the tangent line to points along the curve, s is the step 
%     length between points, and N is the normal vector. In fiber_quantifier_us, 
%     K is calculated by multiplying each side of this equation by the Moore-
%     Penrose pseudoinverse matrix of N.
% 
%     For curvature, the best results are obtained with polynomial-fitted 
%     fiber tracts, calculated using fibersmoother_us. 
%
%  The function outputs vectors containing the fiber tract lengths, pennation
%  angles, and mean curvatures and a matrix containing the point-wise curvature
%  values.
%
%INPUT ARGUMENTS
%  fiber_all_mm: A matrix containing the fiber tract points, having units
%    of mm
%
%  roi_struc: A structure containing information about the aponeurosis ROI,
%    output from define_muscleroi_us
%
%  image_info_struc: A structure containing image metadata, output from
%    read_dicom_us
%
%OUTPUT ARGUMENTS: 
%  penn_mean: A vector containing the pennation angle of each tract, in
%  degrees
%
%  tract_lengths: A vector containing the fiber tract lengths, in mm
%
%  curvature_mean: A vector containing the mean curvature of each tract, in
%    mm^-1
%
%  curvature_all: A matrix containing the point-wise curvature values, in
%    mm^-1
%
%VERSION INFORMATION
% v. 0.1
%
%ACKNOWLEDGEMENTS
% People: Bruce Damon, Hannah Kilpatrick
% Grant support: NIH/NIAMS R01 AR073831

%% calculate architectural parameters for each tract

% initialize zeros matrices
num_tracts = length(fiber_all_mm(:,1,1));
apo_vector = zeros(num_tracts,2);
tract_vector = zeros(num_tracts,2);
tract_lengths = zeros(num_tracts,1);
penn_mean = zeros(num_tracts,1);
curvature_mean = zeros(num_tracts,1);
curvature_all = (0*fiber_all_mm(:,:,1));

% convert aponeurosis ROI to mm
roi_x_mm = roi_struc.fitted_roi_c_pixels*image_info_struc.PixelSpacingX;
roi_y_mm = roi_struc.fitted_roi_r_pixels*image_info_struc.PixelSpacingY;

% architectural characterization loop
for tract_cntr = 2:(num_tracts-1)
    
    %get tract, convert to mm
    loop_track_mm = [nonzeros(fiber_all_mm(tract_cntr,:,1)) nonzeros(fiber_all_mm(tract_cntr,:,2))];
    track_length_mm = [0; cumsum((diff(loop_track_mm(:,1)).^2 + diff(loop_track_mm(:,2)).^2).^0.5)];
    tract_lengths(tract_cntr) = max(track_length_mm);
    
    if max(track_length_mm)>=5                                              % start of if statement: only characterize tracts at least 5 mm length
        index_5mm = find(track_length_mm>=5, 1);
        
        %calculate pennation angle
        apo_vector(tract_cntr,1:2) = ...                                    % position vector between points on aponeurosis
            [(roi_y_mm(tract_cntr+1) - roi_y_mm(tract_cntr-1)) (roi_x_mm(tract_cntr+1) - roi_x_mm(tract_cntr-1))];
        apo_vector(tract_cntr,1:2) = ...                                    % convert to unit length
            apo_vector(tract_cntr,1:2)/norm(apo_vector(tract_cntr,1:2));
        tract_vector(tract_cntr, 1:2) = ...                                 % position vector between seed point and 5 mm along tract
            [(loop_track_mm(index_5mm,2) - loop_track_mm(1,2)) (loop_track_mm(index_5mm,1) - loop_track_mm(1,1))];
        tract_vector(tract_cntr,1:2) = ...                                  % convert to unit length
            tract_vector(tract_cntr,1:2)/norm(tract_vector(tract_cntr,1:2));
        if tract_vector(tract_cntr,2)<0 && apo_vector(tract_cntr,2)>0 || ...  % make sure apon. and tract vectors point the same way
                tract_vector(tract_cntr,2)>0 && apo_vector(tract_cntr,2)<0 
            tract_vector = -tract_vector;
        end
        
        % calculate pennation angle
        penn_mean(tract_cntr) = real(acosd(dot(apo_vector(tract_cntr,1:2),tract_vector(tract_cntr,1:2))));
        
        %calculate curvature along tract
        for fiber_cntr = 2:(length(nonzeros(track_length_mm))-3)            %curvature values blow up at the end of the fiber because the rest of the vector is padded with 0's
            
            %curvature measurements use a discrete implementation of the Frenet equations.
            p1_idx = fiber_cntr-1;                                         	%indices for the three points of interest along the tract - define two pairs of points
            p2_idx = fiber_cntr;
            p3_idx = fiber_cntr+1;
            loop_fiber_m = loop_track_mm/1000;                              %convert from mm to m for curvature measurements
            
            r_1 = (loop_fiber_m(p1_idx,:))-loop_fiber_m(1,:);              	%three position vectors, one for each point
            r_2 = (loop_fiber_m(p2_idx,:))-loop_fiber_m(1,:);
            r_3 = (loop_fiber_m(p3_idx,:))-loop_fiber_m(1,:);
            
            ds21 = sqrt(sum((loop_fiber_m(p2_idx,:)-loop_fiber_m(p1_idx,:)).^2));   %distance between points 1 and 2 and (below) 2 and 3
            ds32 = sqrt(sum((loop_fiber_m(p3_idx,:)-loop_fiber_m(p2_idx,:)).^2));
            
            tangent_vector_2 = (r_2-r_1)/norm(r_2-r_1);                   	%normalized tangent lines between the two pairs of points
            tangent_vector_3 = (r_3-r_2)/norm(r_3-r_2);
            dTds = ((tangent_vector_3-tangent_vector_2)/mean([ds21 ds32]))';  %dT/ds is the spatial rate of change in tangent lines
            dTds(isnan(dTds)) = 0;
            
            if sum(dTds) ~= 0
                N_vector = dTds/norm(dTds);                               	%normal to tangent lines
                curvature_all(tract_cntr,fiber_cntr) = pinv(N_vector)*dTds;	%based on dT/ds = curvature * N
            end
            
        end
        
        curvature_mean(tract_cntr) = mean(nonzeros(curvature_all(tract_cntr,:)));  %calculate mean curvature
        
    else                                                                    % if tract is < 5 mm long
        continue
    end
    
end

%% end the function
return;
