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
The function bmode2angle_us is used to estimate muscle fascicle orientations in the MuscleUS_Toolbox. The user provides a B-mode image, the mask defining the region of interest in the image, and a structure containing options for estimating the fascicle orientations. The fascicle orientations are estimated using an algorithm presented by Rana et al., (J Biomech, 42:2068, 2009), in which the images are processed using
* Vesselness filtering:
  * A series of Gaussian blurring steps with increasing std. deviations for the Gaussian function; for each one, the vesselness response of the structures is calculated.
  * Determination of the maximum vesselness response
* Determination of local fasicle orientation.  First, an anisotropic wavelet is convolved with the vesselness-filtered image at a user-specified range of orientations. The angle at which the maximum convolution of the wavelet with the image is taken as the fascicle orientation. A mask is formed from the vesselness image and used to eliminate signals from areas of low vesselness response. The median angle, across grid squares of user-defined dimensions, is taken and its vector components are calculated.

The function returns the vesselness images, spatial maps of fascicle orientations, and images for quality assurance/inspection, as described below.
* Spatial maps of fascicle orientations, including
  * An image of fascicle oreintations within the user-defined ROI, at the original image resolution
  * A vesselness-masked masked angle image image at the original resolution
  * An image containing the median angles within the grid squares
  * An image with the components of unit vectors indicating the fascicle orientations, within the grid squares.
  * Images for QA purposes, including 1) The convolution images and 2) A sample wavelet
Angles are specified as a counterclockwise rotation from the right side of the image = 0⁰, as in the figure below.

[Back to the top](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-bmode2angle_us.md)

## 3. Syntax

[angle_image, masked_angle_image, angle_image_grid, vector_image] = bmode2angle_us(image_doub, mask, b2a_options);

The input arguments are:
 
* <i>image_doub</i>: A grayscale, B-mode image at double-precision

* <i>mask</i>: The output of define_muscleroi_us

* <i>b2a_options</i>: A structure containing the following processing options:
* 
  Parameters describing the Gaussian convolution:
  
    <i>.stdev_1</i>: The minimum standard deviation of the Gaussian blurring window, in pixels

    <i>.stdev_2</i>: The maximum standard deviation of the Gaussian blurring window, in pixels
    
    <i>.stdev_inc</i>: The amount to increase the Gaussian blurring window per iteration, in pixels
   
    <i>.gauss_size</i>: The row x column dimensions of the Gaussian blurring window, in pixels
    
  Parameters describing the vesselness response calculation:
  
    <i>.vessel_beta</i>: The beta value in the vesselness response function
   
    <i>.vessel_c</i>: The C value in the vesselness response function
    
  Parameters describing the formation of the wavelet and wavelet convolution with the vesselness-filtered image:
  
    <i>.wavelet_damp</i>: The damping coefficient D of the wavelet
   
    <i>.wavelet_kernel</i>: The kernel size of the wavelet, in pixels
   
    <i>.wavelet_freq</i>: he expected spatial frequency of the fascicles, pixels<sup>-1</sup>
  
    <i>.wavelet_freq</i>: The row x column dimensions of the Gaussian blurring window, in pixels
    
    <i>.min_angle</i>: The minimum angle to use when convolving the wavelets with the image, in degrees (note that the right side of the image = 0 degrees and angles increase in a CCW manner).
  
    <i>.max_angle</i>: The maximum angle to use when convolving the wavelets with the image, in degrees
  
    <i>.num_angles</i>: The number of angles to use when convolving the wavelets with the image
    
  Parameters describing the averaging over grid squares:
  
    <i>.num_pixels</i>: The size of the grid squares (n), in pixels (i.e., n x n)

The output arguments are:

* <i>angle_image</i>: An image with per-pixel fasicle orientations

* <i>masked_angle_image</i>: <i>angle_image</i> with the muscle ROI mask applied

* <i>angle_image_grid</i>: The gridded angle image, at the user-defined resolution

* <i>vector_image</i>: The X and Y components of the angles in the gridded image
* 
[Back to the top](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-bmode2angle_us.md)

## 4. Example Code
Given:
1.	A grayscale image stored in the variable image_data_struc.gray;

the following code will allow the user to 

1.	Define a Gaussian kernel with standard deviations of 1.5-3 pixels and kernel size 30x30, in SD increments of 0.5 pixels
2.	Estimate the vesselness response with coefficients  and C of 0.5
3.	Create an anisotropic wavelet with damping coefficient = 2.5622 and kernel size of 26x26, a spatial frequency for the fascicles of 20 pixels, across angles of -135 to -225 degrees, in steps of 1 degree
4.	Smooth the values using a median filter, in grids of 60x60


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
