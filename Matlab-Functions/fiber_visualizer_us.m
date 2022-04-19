function us_figure = fiber_visualizer_us(image_doub, fv_options, fiber_all, roi_struc)
%
%FUNCTION fiber_visualizer_us
%  us_figure = fiber_visualizer_us(image_doub, fv_options, fiber_all, roi_struc);
%
%USAGE
%  The function fiber_visualizer_us is used to fiber-tracts in the MuscleUS_Toolbox.
%  The user provides a double precision B-mode image, a matrix of fiber-tracts,
%  a structure containing ROI definitions, and a structure containing
%  visualization options.
%
%INPUT ARGUMENTS
%  image_doub: A grayscale, B-mode image at double-precision
%
%  fv_options: A structure with visualization options, as defined in the
%  following fields:
%    -.plot_tracts: If set to 1, the fiber tracts will be plotted; other-
%       wise, set to 0
%    -.plot_mask: If set to 1, the muscle ROI will be plotted; other-
%       wise, set to 0
%    -.plot_roi: If set to 1, the aponeurosis ROI will be plotted; other-
%       wise, set to 0
%    -.tract_color: Required when plot_tracts = 1. If tract_color is a 1x3 
%       vector, the tracts will be plotted as a single color according to an
%       RGB coding mechanism. If tract_color is an Mx3 matrix (with M = the 
%       number of fiber tracts), each tract will be plotted using a 
%       different color
%    -.mask_color: Required when plot_mask = 1. A 1x3 vector used to 
%       indicate the color of the muscle region of interest
%    -.roi_color: Required when plot_roi = 1. A 1x3 vector used to indicate 
%       the color of the aponeurosis region of interest
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
us_figure = figure('units', 'normalized', 'position', [0.1 .1 .6 .75]);
imagesc(image_doub), colormap gray
axis image
hold on


if fv_options.plot_tracts==1
    for k = 1:length(fiber_all(:,1,1))

        %get fiber tract poins
        loop_c = nonzeros(squeeze(fiber_all(k,:,2)));
        loop_r = nonzeros(squeeze(fiber_all(k,:,1)));

        %plot using user-defined color(s)
        if numel(fv_options.tract_color)==3
            plot(loop_c, loop_r, fv_options.tract_color)
        elseif numel(fv_options.tract_color)>3
            plot(loop_c, loop_r, fv_options.tract_color(k,:))
        end

    end
end

if fv_options.plot_roi==1
   plot(roi_struc.fitted_roi_c_pixels, roi_struc.fitted_roi_r_pixels, 'color', fv_options.roi_color)
end

if fv_options.plot_mask==1
    plot(roi_struc.muscle_c_pixels, roi_struc.muscle_r_pixels, 'color', fv_options.mask_color)
end



%% end function
return;
