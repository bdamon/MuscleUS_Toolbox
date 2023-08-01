# Help for the function <i>read_dicom_us</i>, v. 1.0.0

## Introduction

This help file contains information about
1) [Purpose of the Program](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-read_dicom_us.md#1-purpose)
2) [Usage of the Program](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-read_dicom_us.md#2-usage)
3) [Syntax](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-read_dicom_us.md#3-Syntax)
5) [Example Code](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-read_dicom_us.md#4-Example-Code)
6) [Acknowledgements](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-read_dicom_us.md#5-Acknowledgements)


## 1. Purpose

The function <i>read_dicom_us</i> is used to open ultrasound image files in the MuscleUS_Toolbox


## 2. Usage
File I/O and other options can be set using the optional input argument input_structure.  If input_structure is not included, the user is prompted to select the input and output file names.

Structures containing the image(s) (in several formats) and the image metadata are returned.

## 3. Syntax
The function read_dicom_us is called using the following syntax:

[image_data_struc, image_info_struc] = read_dicom_us(input_structure);

The input argument is:
* <i>input_structure</i> (optional): A structure containing the following fields:

    <i>.input_path_name</i>: A path to the directory holding the image data files

    <i>.input_file_name</i>: The file name of interest, including the .DCM extension

    <i>.output_path_name</i>: A path to the directory where the Matlab data file will be stored

    <i>.output_file_name</i>: The file name of the Matlab data file
  
    <i>.show_image</i>: A flag to view the image (1=yes, 0=no). If the image data is 4D, the first image of the data series is shown. If input_structure is not included as an input argument, <i>show_image</i> is set to zero by default. 

If no input arguments are included, the user is prompted to select the input file and create an output file name.

The output arguments are:

* <i>image_data_struc</i>: The imaging data, with the following fields:
   
    <i>.orig.native</i>: The original DICOM image(s), with dimensions of rows x columns x color layer (for RGB and YCbCr formats). Depending on the acquisition details, there may be a fourth dimension, usually time.
  
    <i>.orig.native.doub</i>: The original DICOM image(s) converted to double precision.
  
    <i>.orig.native.norm</i>: The double precision image(s) converted to a signal range of 0-1.

    <i>.gray</i>: The original images converted to gray scale
  
    <i>.rgb</i>: The original images converted to RGB format
    
* <i>image_info_struc</i>: The contents of the DICOM file header, plus:
   
    <i>.dynamics</i>: the number of images in the time series
  
    <i>.PixelSpacingX (and Y, R, C)</i>: The pixel spacing, in mm, in the X, Y, row (=Y), and column (=X) directions
    
    <i>.RegionLocation</i>: The pixel locations within the image that contain the imaged anatomy (given as [minX maxX minY maxY])

    <i>FieldOfView</i>: the number of pixels in the X and Y directions, times the corresponding pixel spacings
  
## 4. Example Code

% set file I/O options:

input_structure.input_path_name = 'S:\Muscle_DTI\Ultrasound_sample_images\Sample_US_2022.3.4';

input_structure.input_file_name = 'TA_4';

input_structure.output_path_name = input_structure.input_path_name;

input_structure.output_file_name =  'TA_4_output.mat';

input_structure.show_image = 1;

% call the function:

[image_data_struc, image_info_struc] = read_dicom_us(input_structure);

## 5. Acknowledgements
People: Bruce Damon

Grants: NIH/NIAMS R01 AR073831

