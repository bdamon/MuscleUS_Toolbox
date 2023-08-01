# Help for the function <i>fiber_track_us</i>, v. 0.1.x

## Introduction

This help file contains information about
1) [Purpose of the program](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-fiber_track_us.md#1-purpose)
2) [Usage of the program](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-fiber_track_us.md#2-usage)
3) [Syntax](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-fiber_track_us.md#3-Syntax)
4) [Example Code](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-fiber_track_us.md#4-Example-Code)
5) [Acknowledgements](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-fiber_track_us.md#5-Acknowledgements)

## 1. Purpose
 
The function <i>fiber_track_us</i> is used to perform fiber tractography in the MuscleUS_Toolbox.

## 2. Usage
The inputs are derived from previous file opening (i.e, <i>read_dicom_us</i>), ROI definition (<i>define_muscle_roi_us</i>), and image processing (<i>bmode2angle_us</i>) steps, plus a structure defining the fiber-tracking options. This structure allows the user to set the tracking step size and tract termination criteria. Fiber tracking begins at the aponeurosis seed points and continues by using Euler integration of the vectors that are used to describe muscle fascicle orientation. Tracking occurs at a user-defined step size and terminates either due to high inter-point angle or if the tract reaches the muscle boundary, as defined by the image mask. The outputs include a matrix containing fiber tracts, with units of pixels; and a vector containing the reason for fiber tract termination.

The fiber tracts may be viewed using <i>fiber_visualizer_us</i>, either as part of the function call to <i>fiber_track_us</i> or directly from the command line.

## 3. Syntax

[fiber_all_pixels, stop_list] = fiber_track_us(vector_image, roi_struc, image_data_struc, ft_options, fv_options);

The input arguments are:
 
* <i>vector_image</i>: A spatial map of X and Y vector components of the fascicle orientations in the gridded angle image, output from [<i>bmode2angle_us</i>](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-bmode2angle_us.md)

* <i>roi_struc</i>: the output of [<i>define_muscle_roi_us</i>](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-define_muscle_roi_us.md)

* <i>ft_options</i>: A structure containing the following options for fiber-tracking:

  <i>.step_size</i>: The fiber-tracking step size, in pixels
  
  <i>.angle_thrsh</i>: The inter-step angle above which fiber tracking would terminate, in degrees

  <i>.image_num</i>: For a time series dataset, the image number to analyze (use 1 for a single-time point measurement)

  <i>.show_image</i>: Use 1 to display the initial result after fiber-tracking or 0 not to display the result

* <i>fv_options</i>: As defined in fiber_visualizer_us

The output arguments are:

* <i>fiber_all_pixels</i>: The fiber tracking data, with size MxNx2, where M is the number of fiber tracts, N is the number of points in the fiber tract (being padded with zeros because of varying fiber tract lengths, and the third dimension includes row adn colume (Y and X) positions. The units are image pixels.

* <i>stop_list</i>: A vector containing the reason for tract termination, with 1 = reaching the muscle border, as defined by the mask; and 2 = an excessive inter-point angle 

## 4. Example Code

% define fiber tracking options:

ft_options.step_size = 30;                                                  %in pixels

ft_options.angle_thrsh = 25;                                                %in degrees

ft_options.show_image = 1;                                                  %show the image

ft_options.image_num = 1;

% define visualization options:

fv_options.plot_mask=1;                                                     %show the mask

fv_options.plot_tracts=1;                                                   %show the tracts

fv_options.plot_roi=1;                                                      %show the roi

fv_options.tract_color=[1 1 0];                                             %tracts will be yellow

fv_options.roi_color=[0 1 1];                                               %roi will be cyan

fv_options.mask_color=[1 0 1];                                              %mask will be magenta

% call the function:

[fiber_all_pixels, stop_list] = fiber_track_us(vector_image, roi_struc, image_data_struc, ft_options, fv_options);


## 5. Acknowledgements
 People: Bruce Damon, Hannah Kilpatrick
 
 Grant support: NIH/NIAMS R01 AR073831

[Back to the top](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-fiber_track_us.md)
