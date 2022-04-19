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

[image_data_struc, roi_struc] = define_muscle_roi(image_data_struc, image_info_struc, roi_resolution);

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

### Example 1
Given 

1.	An anatomical image with variable name anat_image and having matrix size 192x192x44, field of view 192x192 mm, and slice thickness 7 mm;

2.	The muscle mask, stored in a variable called mask; and

3.	DTI images, having matrix size 192x192x44, field of view 192x192 mm, and slice thickness 7 mm

the code below will allow the user to:

1.	Manually select aponeurosis in slices 4-31;

2.	Create a mesh of size 150 rows x 30 columns; and

3.	Visualize the outcome, using slices 14, 24, 34, and 44 of the anatomical image stack for reference.

% Set mesh options:

dr_options.slices = [4 31]; %analyze slices 4-31

dr_options.dti_size = [192 192 44]; %matrix size and # of slices in DTI images

dr_options.mesh_size = [150 30]; %mesh will have 150 rows and 30 columns

dr_options.method = ‘manual'; %digitize it manually

% Set visualization options

fv_options.anat_dims = [192 7]; %FOV and slice thickness of the images to be displayed, in mm

fv_options.anat_slices = 14:10:44; %display slices 14, 24, 34, and 44 

fv_options.plot_mesh = 1; %do plot the aponeurosis mesh

fv_options.plot_mask = 0; %don’t plot the mask

fv_options.plot_fibers = 0; %don’t plot any fiber tracts

fv_options.mesh_size = [192 192]; %rows x columns of the images used to generate the mesh

fv_options.mesh_dims = [192 7]; %FOV and ST of the images used to create the mesh

fv_options.mesh_color = [0.75 0.75 0.75]; %make the mesh light gray

% call the function:

roi_mesh = define_roi(anat_image, mask, dr_options, plot_options);
 

[Back to the top](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-fiber_visualizer_us.md)

## 5. Acknowledgements
People: Bruce Damon

Grants: NIH/NIAMS R01 AR073831

[Back to the top](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-fiber_visualizer_us.md)
