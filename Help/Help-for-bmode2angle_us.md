# Help for the function <i>bmode2angle_us</i>, v. 0.1.x

## Introduction

This help file contains information about
1) [Purpose of the program](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-bmode2angle_us.md#1-purpose)
2) [Usage of the program](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-bmode2angle_us.md#2-usage)
3) [Syntax](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-bmode2angle_us.md#3-Syntax)
4) [Example Code](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-bmode2angle_us.md#4-Example-Code)
5) [Acknowledgements](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-bmode2angle_us.md#5-Acknowledgements)

## 1. Purpose
 
The function <i>bmode2angle_us</i> is used to estimate muscle fascicle orientations in the MuscleUS_Toolbox.

[Back to the top](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-bmode2angle_us.md)

## 2. Usage
The user provides a B-mode image, the mask defining the region of interest in the image, and a structure containing options for estimating the fascicle orientations. The fascicle orientations are estimated using the algorithm presented by Rana et al., (J Biomech, 42:2068,2009), in which the images are processed using 
* A series of Gaussian blurring steps of varying sizes  
* Calculation of the vesselness response of the structures to form a vesselness-filtered image
* An anisotropic wavelet is convolved with the filtered image at a user-specified range of orientations
* The angle at which the maximum convolution of the wavelet with the image is taken as the fascicle orientation.  
The angles are averaged across grid squares of user-defined dimensions.  

The function returns an image at the original resolution, a masked image at the original resolution, an image containing the median angles within the grid squares, and a masked image with the components of unit vectors indicating the fascicle orientations.

[Back to the top](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-bmode2angle_us.md)

## 3. Syntax

[angle_image, masked_angle_image, angle_image_grid, vector_image] = bmode2angle_us(image_doub, mask, b2a_options);

The input arguments are:
 
* <i>image_doub</i>: A grayscale, B-mode image at double-precision

* <i>mask</i>: The output of define_muscleroi_us

* <i>b2a_options</i>: A structure containing the following processing options:
  Parameters describing the Gaussian convolution:
    <i>.stdev_1</i>: The minimum standard deviation of the Gaussian blurring window, in pixels

    <i>.stdev_2</i>: The maximum standard deviation of the Gaussian blurring window, in pixels
    
    <i>.stdev_inc</i>: The amount to increase the Gaussian blurring window per iteration, in pixels
   
    <i>.gauss_size</i>: The row x column dimensions of the Gaussian blurring window, in pixels
  Parameters describing teh vesselness response calculation:
    <i>.vessel_beta</i>: The beta value in the vesselness response function
   
    <i>.vessel_c</i>: The C value in the vesselness response function
  Parameters describing the formation of the wavelet and waveletconvolution with the vesselness-filtered image::
    <i>.wavelet_damp</i>: The damping coefficient D of the wavelet
   
    <i>.wavelet_kernel</i>: The kernel size of the wavelet, in pixels
   
    <i>.wavelet_freq</i>: he expected spatial frequency of the fascicles, pixels<sup>-1</sup>
  
    <i>.wavelet_freq</i>: The row x column dimensions of the Gaussian blurring window, in pixels
    
    <i>.min_angle</i>: The minimum angle to use when convolving the wavelets with the image, in degrees (note that the right side of the image = 0 degrees and angles increase in a CCW manner).
  
    <i>.max_angle</i>: The maximum angle to use when convolving the wavelets with the image, in degrees
  
    <i>.num_angles</i>: The number of angles to use when convolving the wavelets with the image
  Parameters describing the averaging over grid squares:
    <i>.num_pixels</i>: The size of the grid squares (n), in pixels (i.e., n x n)

The output argumetns are:

* <i>angle_image</i>: An image with per-pixel fasicle orientations

* <i>masked_angle_image</i>: angle_image with the muscle ROI mask applied

* <i>angle_image_grid</i>: The gridded angle image, at the user-defined resolution

* <i>vector_image</i>: The X and Y components of the angles in the gridded image
* 
[Back to the top](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-bmode2angle_us.md)

## 4. Example Code
The code below will set processing optiosn as in the published manuscript and calculate the angle image and its derived images

%set processing options

b2a_options.stdev_1 = 1.5;

b2a_options.stdev_2 = 3; 

b2a_options.stdev_inc = 0.5;

b2a_options.gauss_size = 15;

b2a_options.vessel_beta = 0.5; 

b2a_options.vessel_c = 0.5;

b2a_options.wavelet_damp = 2.5622;

b2a_options.wavelet_kernel = 25;

b2a_options.wavelet_freq = 20;

b2a_options.min_angle = -135;

b2a_options.max_angle = -225;

b2a_options.num_angles = 91;

b2a_options.num_pixels = 60;

%convert b-mode image to angle image

image_gray = image_data_struc.gray(:,:);

[angle_image, masked_angle_image, angle_image_grid, vector_image] = bmode2angle_us(image_gray, image_data_struc.mask, b2a_options);

[Back to the top](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-bmode2angle_us.md)

## 5. Acknowledgements
 People: Emily Bush, Ke Li, Hannah Kilpatrick, Bruce Damon
 
 Grant support: NIH/NIAMS R01 AR073831

[Back to the top](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-bmode2angle_us.md)
