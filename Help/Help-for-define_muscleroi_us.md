# Help for the function <i>define_muscleroi_us</i>, v. 1.0.0

## Introduction

This help file contains information about
1) [Purpose of the Program](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-define_muscleroi_us.md#1-purpose)
2) [Usage of the Program](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-define_muscleroi_us.md#2-usage)
3) [Syntax](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-define_muscleroi_us.md#3-Syntax)
5) [Example Code](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-define_muscleroi_us.md#4-Example-Code)
6) [Acknowledgements](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-define_muscleroi_us.md#5-Acknowledgements)


## 1. Purpose

The function <i>define_muscleroi_us</i> is used to define structures of interest in the MuscleUS_Toolbox, including the image mask defining the muscle boundaries and a curved line defined the aponeurosis region of interest.  

## 2. Usage
The function <i>define_muscleroi_us</i> is used to define regions of interest in the MuscleUS_Toolbox.

In typical usage, both the boundaries fo the muscle region of interest and the aponeurosis will be defined.  To define the region, the user will use the <i>roipoly</i> function to define the region's boundaries; the user is advised to look at MATLAB's help files on this function. Then the user is prompted to zoom in on the aponeurosis of fascicle insertion, pressing return when done.  The user defines the aponeurosis of fascicle insertion using a series of left mouse clicks; use a right click to end the procedure. A 3rd order polynomial curve is fitted to the points and displayed. Evenly spaced points along this curve will become the seed points for fiber-tracking.  The user can define the density (spacing) of these seed points. The user can also input a previously defined mask (if it exists), as a time-saving step to obviate re-defining the muscle boundaries.  

After each step, the user can inspect and verify these definitions before advancing. An instruction in the command window will prompt the user.

An updated image data structure and the binary image mask, aponeurosis definition, and other information about the region defined, are output.

(Hints: 1. Be sure to avoid the inclusion of other fascial tissues within the region, as these will erroneously bias the fascicle orientation estimates. 2. The aponeurosis must be defined entirely within the region of interest.).

## 3. Syntax
The function define_muscleroi_us is called using the following syntax:

[image_data_struc, roi_struc] = define_muscleroi_us(image_data_struc, image_info_struc, dmr_options);

The input arguments are:
* <i>image_data_struc</i>: A structure containing the imaging data, output from [<i>read_dicom_us</i>](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-read_dicom_us.md).

* <i>image_info_struc</i>: A structure containing the imaging metadata, output from [<i>read_dicom_us</i>](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-read_dicom_us.md). 

* <i>dmr_options</i>: A structure of options, containing the following fields:

    <i>.roi_resolution</i>: The desired distance between fiber tracking seed points, in mm
  
    <i>.frame_num</i>: The frame number within the image data series to be analyzed. If the data containing a time series, this is the frame number. If there is only one image, use 1.
  
    <i>.def_roi</i>: Set to 1 to define the aponeurosis region
  
    <i>.def_muscle</i>: Set to 1 to define the muscle.  If set to 0, a pre-existing muscle definition mask, including vertex locations, must be input as dmr_options.mask, dmr_options.muscle_c_pixels, and dmr_options.muscle_r_pixels

The output arguments are:
* <i>image_data_struc</i>: The input structure, with the following fields added:.
   
    <i>.mask</i>: A binary image mask defining the muscle of interest
  
    <i>.masked_gray</i>: The masked grayscale images.
    
* <i>roi_struc</i>: The input structure, with the following fields added:.
   
    <i>.muscle_c_pixels</i>: The X (column) points used to define the muscle boundaries (mask)
  
    <i>.muscle_r_pixels</i>: The Y (row) points used to define the muscle boundaries (mask)
   
    <i>.roi_c_pixels</i>: The X (column) points used to define the aponeurosis region of interest
  
    <i>.roi_r_pixels</i>: The Y (row) points used to define the aponeurosis region of interest
   
    <i>.fitted_roi_c_pixels</i>: The X (column) points used to define the aponeurosis region of interest, after smoothing using a 2nd order polynomial function
  
    <i>.fitted_roi_r_pixels</i>: The Y (row) points used to define the aponeurosis region of interest, after smoothing using a 2nd order polynomial function
  
    <i>.fitted_roi_c_distance</i>: The X (column) points used to define the aponeurosis region of interest converted to units mm, after smoothing using a 2nd order polynomial function
  
    <i>.fitted_roi_r_distance</i>: The Y (row) points used to define the aponeurosis region of interest converted to units mm, after smoothing using a 2nd order polynomial function

    <i>.roi_resolution</i>: The distance between seed points
  
    <i>.roi_pixels_params</i>: The fitted parameters for pixel locations in the aponeurosis region of interest
    
## 4. Example Code

% set options

dmr_options.roi_resolution = 1;

dmr_options.frame_num = 1;

dmr_options.def_roi = 1;

dmr_options.def_muscle = 1;    

% call the function

[image_data_struc, roi_struc] = define_muscleroi_us(image_data_struc, image_info_struc, dmr_options);

The aponeurosis can be redefined while reusing the muscle mask:

% update dmr_options with data previously output:

dmr_options.def_muscle = 0;

dmr_options.mask = image_data_struc.mask;

dmr_options.muscle_c_pixels = image_data_struc.muscle_c_pixels;

dmr_options.muscle_r_pixels = image_data_struc.muscle_r_pixels;

% call the function:

[image_data_struc, roi_struc] = define_muscleroi_us(image_data_struc, image_info_struc, dmr_options);

## 5. Acknowledgements
People: Bruce Damon, Hannah Kilpatrick

Grants: NIH/NIAMS R01 AR073831
