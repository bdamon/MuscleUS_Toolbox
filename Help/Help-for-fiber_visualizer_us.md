# Help for the function <i>fiber_visualizer_us</i>, v. 0.1.x

## Introduction

This help file contains information about
1) [Purpose of the Program](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-fiber_visualizer_us.md#1-purpose)
2) [Usage of the Program](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-fiber_visualizer_us.md#2-usage)
3) [Syntax](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-fiber_visualizer_us.md#3-Syntax)
5) [Example Code](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-fiber_visualizer_us.md#4-Example-Code)
6) [Acknowledgements](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-fiber_visualizer_us.md#5-Acknowledgements)

## 1. Purpose

The function <i>define_muscleroi_us</i> is used is used to visualize ultrasound images and other structures, including the muscle mask, aponeurosis definition, and/or the fiber tracts, in the MuscleUS_Toolbox.  

[Back to the top](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-fiber_visualizer_us.md)

## 2. Usage
The user can call fiber_visualizer from the command line.  In addition, <i>read_dicom_us</i>, <i>fiber_track</i>, and <i>fiber_smoother_us</i>, can be configured to call <i>fiber_visualizer</i> from within the functions, so that the image, mask, aponeurosis definition, and fiber tracts can be automatically plotted.  

The user provides a double precision B-mode image, a matrix of fiber-tracts, a structure containing ROI definitions, and a structure containing visualization options. The image and user-selected options are displayed.

[Back to the top](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-fiber_visualizer_us.md)

## 3. Syntax
The function define_muscleroi_us is called using the following syntax:

us_figure = fiber_visualizer_us(image_doub, fv_options, fiber_all, roi_struc);

The input arguments are:
* <i>image_doub</i>: A grayscale, B-mode image at double-precision. 

* <i>fv_options</i>: A structure containing the fololowing fields:

    <i>.plot_tracts</i>: If set to 1, the fiber tracts will be plotted; otherwise, set to 0

    <i>.plot_mask</i>: If set to 1, the muscle mask will be plotted; otherwise, set to 0

    <i>.plot_roi</i>: If set to 1, the aponeurosis region of interest will be plotted; otherwise, set to 0
  
    <i>.tract_color</i>: Required when plot_tracts = 1. If tract_color is a 1x3 vector, the tracts will be plotted as a single color according to an RGB coding mechanism. If tract_color is an Mx3 matrix (with M = the number of fiber tracts), each tract will be plotted using a different color 
 
    <i>.mask_color</i>: Required when plot_mask = 1. A 1x3 vector used to indicate the color of the muscle mask 
 
    <i>.roi_color</i>: Required when plot_roi = 1. A 1x3 vector used to indicate the color of the aponeurosis region of interest 

* <i>fiber_all</i>: The fiber tracts to be displayed; required when plot_tracts=1. 

* <i>roi_struc</i>: A structure with ROI data (output from define_muscleroi_us); required when plot_mask=1 or when plot_roi=1 

The output arguments are:
* <i>us_figure</i>: A MATLAB figure structure
   
[Back to the top](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-fiber_visualizer_us.md)

## 4. Example Code

% define visualization options:

fv_options.plot_mask=1;                                                     %show the mask

fv_options.plot_tracts=1;                                                   %show the tracts

fv_options.plot_roi=1;                                                      %show the roi

fv_options.tract_color=[1 1 0];                                             %tracts will be yellow

fv_options.roi_color=[0 1 1];                                               %roi will be cyan

fv_options.mask_color=[1 0 1];                                              %mask will be magenta

% call the function:

us_figure = fiber_visualizer_us(image_gray, fv_options, fiber_all_pixels, roi_struc);

[Back to the top](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-fiber_visualizer_us.md)

## 5. Acknowledgements
People: Bruce Damon

Grants: NIH/NIAMS R01 AR073831

[Back to the top](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-fiber_visualizer_us.md)
