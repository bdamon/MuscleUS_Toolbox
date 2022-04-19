# Help for the function <i>define_muscleroi_us</i>, v. 0.1.x

## Introduction

This help file contains information about
1) [Purpose of the Program](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-define_muscleroi_us.md#1-purpose)
2) [Usage of the Program](https://github.com/bdamon/MuscleDTI_Toolbox/blob/master/Help/Help-for-define_muscleroi_us.md#2-usage)
3) [Syntax](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-define_muscleroi_us.md#3-Syntax)
5) [Example Code](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-define_muscleroi_us.md#4-Example-Code)
6) [Acknowledgements](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-define_muscleroi_us.md#5-Acknowledgements)


## 1. Purpose

The function <i>define_muscleroi_us</i> is used to define structures of interest in the MuscleUS_Toolbox, including an image mask defining the muscle boundaries and a curved line defined the aponeurosis region of interest.  

[Back to the top](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-define_muscleroi_us.md)

## 2. Usage
An image is displayed and the user is prompted to define the muscle region of interest using the roipoly tool. The resulting binary image mask, and other information about the region defined, are output.

Then the user is prompted to define the aponeurosis of muscle fascicle insertion using a series of left mouse clicks. A 2nd order polynomial curve is fitted to the points. Evenly spaced points along this curve will become the seed points for fiber-tracking.  The user can define the density (spacing) of these seed points.

After each step, the user can inspect and verify these definitions before advancing.

[Back to the top](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-define_muscleroi_us.md)

## 3. Syntax
The function define_muscleroi_us is called using the following syntax:

[image_data_struc, roi_struc] = define_muscle_roi(image_data_struc, image_info_struc, roi_resolution);

The input arguments are:
* <i>anat_image</i>: The imaging data. 

* <i>image_data_struc</i>: A structure containing the imaging data, output from [<i>read_dicom_us</i>](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-read_dicom_us.md).

* <i>image_info_struc</i>: A structure containing the imaging metadata, output from [<i>read_dicom_us</i>](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-read_dicom_us.md). 

* <i>dmr_options</i>: A structure of options, containing the following fields:

    <i>.roi_resolution</i>: The desired distance between fiber tracking seed points, in mm
  
    <i>.frame_num</i>: The frame number within the image data series to be analyzed. If the data containing a time series, this is the frame number. If there is only one image, use 1. 

The output arguments are:
* <i>image_data_struc</i>: The input structure, with the following fields added:.
   
    <i>.mask</i>: A binary image mask defining the muscle of interest
  
    <i>.masked_gray</i>: The masked grayscale images.
    
* <i>roi_struc</i>: The input structure, with the following fields added:.
   
    <i>.muscle_c_pixels</i>: The X (column) points used to define the muscle boundaries (mask)
  
    <i>.muscle_r_pixels</i>: The Y (row) points used to define the muscle boundaries (mask)
   
    <i>.roi_c_pixels</i>: The X (column) points used to define the aponeurosis region of interest
  
    <i>.roi_r_pixels</i>: The Y (row) points used to define the aponeurosis region of interest
   
    <i>.fitted_roi_c_pixels</i>: The X (column) points used to define the aponeurosis region of interest, after smoothing using a 3rd order polynomial function
  
    <i>.fitted_roi_r_pixels</i>: The Y (row) points used to define the aponeurosis region of interest, after smoothing using a 3rd order polynomial function
   
    <i>.roi_resolution</i>: The distance between seed points
  
    <i>.roi_pixels_params</i>: The fitted parameters for pixel locations in the aponeurosis region of interest
    
[Back to the top](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-define_muscleroi_us.md)

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
 

[Back to the top](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-define_muscleroi_us.md)

## 5. Acknowledgements
People: Bruce Damon, Hannah Kilpatrick

Grants: NIH/NIAMS R01 AR073831

[Back to the top](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-define_muscleroi_us.md)
