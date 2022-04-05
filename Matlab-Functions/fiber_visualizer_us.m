function us_figure = fiber_visualizer_us(image_doub, fv_options, fiber_all, roi_struc)
%
%FUNCTION fiber_visualizer_us
%  us_figure = fiber_visualizer_us(image_doub, fv_options, fiber_all, roi_struc);
%
%USAGE
%  The function fiber_ visualizer_us is used to visualize ultrasound images and 
%  other structures, including the muscle mask, aponeurosis definition, and/or the 
%  fiber tracts.
%
%  The user can call fiber_visualizer from the command line.  In addition, 
%  read_dicom_us, fiber_track, and fiber_smoother_us, can be configured to call 
%  fiber_visualizer from within the functions, so that the image, mask, 
%  aponeurosis definition, and fiber tracts can be automatically plotted.  The 
%  user supplies a double precision image, a structure with some plotting 
%  options, and the other variables to be plotted as input arguments. A handle 
%  to the figure is returned.
%
%INPUT ARGUMENTS
%  image_doub: A grayscale, B-mode image at double-precision
%
%  fv_options: A structure with visualization options, as defined in the
%  following fields:
%    -.tract_color: If tract_color is a 1x3 vector, the tracts will be
%      plotted as a single color according to an RGB coding mechanism. If
%      tract_color is an Mx3 matrix (with M=the number of fiber tracts),
%      each tract will be plotted using a different color
%    -.roi_color: A 1x3 vector used to indicate the color of the
%      aponeurosis region of interest
%
%  fiber_all (optional): The fiber tracts to be displayed, if desired
%
%  roi_struc (optional): A structure with ROI data (output from
%   define_muscleroi_us), if desired
%
%OUTPUT ARGUMENTS
%  us_figure: A MATLAB figure structure
%
%VERSION INFORMATION
%  v. 0.1
%
%ACKNOWLEDGEMENTS
%  People: Bruce Damon
%  Grant support: NIH/NIAMS R01 AR073831

%% Plot fiber tracts

%define figure window
us_figure = figure('units', 'normalized', 'position', [0.1 .1 .8 .75]);
imagesc(image_doub), colormap gray
axis image
hold on


if exist('fiber_all', 'var')
    for k = 2:(length(fiber_all(:,1,1))-1)

        %get fiber tract poins
        loop_c = nonzeros(squeeze(fiber_all(k,:,2)));
        loop_r = nonzeros(squeeze(fiber_all(k,:,1)));

        %plot using user-defined color(s)
        if numel(fv_options.tract_color)==3
            plot(loop_c, loop_r, 'color', fv_options.tract_color)
        elseif numel(fv_options.tract_color)>3
            plot(loop_c, loop_r, 'color', fv_options.tract_color(k,:))
        end

    end
end

if exist('roi_struc', 'var')
    for k = 1:length(fiber_all(:,1,1))
        plot(roi_struc.fitted_roi_c_pixels, roi_struc.fitted_roi_r_pixels, 'color', fv_options.roi_color)
    end
end



%% end function
return;
