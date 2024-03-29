# Help for the function <i>bmode2angle_us</i>, v. 1.0.0

## Introduction

This help file contains information about
1) [Purpose of the program](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-bmode2angle_us.md#1-purpose)
2) [Usage of the program](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-bmode2angle_us.md#2-usage)
3) [Syntax](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-bmode2angle_us.md#3-Syntax)
4) [Example Code](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-bmode2angle_us.md#4-Example-Code)
5) [Acknowledgements](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-bmode2angle_us.md#5-Acknowledgements)

## 1. Purpose
 
The function <i>bmode2angle_us</i> is used to estimate muscle fascicle orientations in the MuscleUS_Toolbox.

## 2. Usage
The function <i>bmode2angle_us</i> is used to estimate muscle fascicle orientations in the MuscleUS_Toolbox. The user provides a B-mode image, the mask defining the region of interest in the image, and a structure containing options for estimating the fascicle orientations. The fascicle orientations are estimated using an algorithm presented by Rana et al., (J Biomech, 42:2068, 2009), in which the images are processed using
* Vesselness filtering:
  * A series of Gaussian blurring steps with increasing std. deviations for the Gaussian function; for each one, the vesselness response of the structures is calculated.
  * Determination of the maximum vesselness response
* Determination of local fasicle orientation
  * An anisotropic wavelet is convolved with the vesselness-filtered image at a user-specified range of orientations. The angle at which the maximum convolution of the wavelet with the image is taken as the fascicle orientation.
  * A mask is formed from the vesselness image and used to eliminate signals from areas of low vesselness response.
  * The median angle, across grid squares of user-defined dimensions, is taken and its vector components are calculated.
The function returns the vesselness images, spatial maps of fascicle orientations, and images for quality assurance/inspection, as described below.

The function returns:
* Spatial maps of fascicle orientations, including
  * An image of fascicle oreintations within the user-defined ROI, at the original image resolution
  * A vesselness-masked masked angle image image at the original resolution
  * An image containing the median angles within the grid squares
* An image with the components of unit vectors indicating the fascicle orientations, within the grid squares.
* Images for QA purposes, including 
  * The convolution images
  * A sample wavelet

Angles are specified as a counterclockwise rotation from the right side of the image = 0⁰.

(Hints: 1. Examine the image first to estimate the fascicle orientations.  Make your minimum angle (min_angle) ~10<sup>o</sup> lower than the lowest estimated angle and your maximum angle (max_angle) ~10<sup>o</sup> greater than the lowest estimated angle.  2. Using a higher number of angles (num_angles) and a higher range of angles (max_angle-min_angle) requires more time to model the data. Determine the range and angular resolution that you actually need for your study.  3. Be sure to inspect the output data using the code below (and adapt it to other other output variables). 4. The wavelet and vesselness parameters may vary depending on your image resolution).

## 3. Syntax

[angle_image, masked_angle_image, angle_image_grid, vector_image, vesselness_mask, vesselness_max, max_cvn_image, cvn_images, sample_wavelet] = 
 bmode2angle_us(image_gray, mask, b2a_options);

The input arguments are:
 
* <i>image_gray</i>: A grayscale, B-mode image at double-precision

* <i>mask</i>: The output of define_muscleroi_us

* <i>b2a_options</i>: A structure containing the following processing options:
  * Parameters describing the Gaussian convolution:
  
    <i>.stdev_1</i>: The minimum standard deviation of the Gaussian blurring window, in pixels

    <i>.stdev_2</i>: The maximum standard deviation of the Gaussian blurring window, in pixels
    
    <i>.stdev_inc</i>: The amount to increase the Gaussian blurring window per iteration, in pixels
   
    <i>.gauss_size</i>: The row x column dimensions of the Gaussian blurring window, in pixels
    
  * Parameters describing the vesselness response calculation:
  
    <i>.vessel_beta</i>: The beta value in the vesselness response function
   
    <i>.vessel_c</i>: The C value in the vesselness response function
    
  * Parameters describing the formation of the wavelet and wavelet convolution with the vesselness-filtered image:
  
    <i>.wavelet_damp</i>: The damping coefficient D of the wavelet
   
    <i>.wavelet_kernel</i>: The kernel size of the wavelet, in pixels
   
    <i>.wavelet_freq</i>: The expected spatial frequency of the fascicles, pixels<sup>-1</sup>
  
    <i>.wavelet_freq</i>: The row x column dimensions of the Gaussian blurring window, in pixels
    
    <i>.min_angle</i>: The minimum angle to use when convolving the wavelets with the image, in degrees (note that the right side of the image = 0 degrees and angles increase in a CCW manner).
  
    <i>.max_angle</i>: The maximum angle to use when convolving the wavelets with the image, in degrees
  
    <i>.num_angles</i>: The number of angles to use when convolving the wavelets with the image
    
  * Parameters describing the averaging over grid squares:
  
    <i>.num_pixels</i>: A P x 2 matrix defining the grid square sizes to be analyzed. Each row of num_pixels defines the row and column sizes of the grid squares, in pixels (i.e., n x m). The averaging is repeated for each row, p, of num_pixels.

    
  * Parameters describing the formation of the vesselness mask using either Otsu's method of k-means clustering:
  
    <i>.otsu</i>: The multiplier for Otsu's threshold in the vesselness-masked images, when Otsu's method is used to filter the image. For example, setting b2a_options.otsu to 1 uses the threshold set by Otsu's method.  Setting b2a_options.otsu to 0.5 uses 1/2 of this threshold.  
  
    <i>.k</i>: A two-element vector with the number of clusters and the ordinal rank, of the cluster to be used, when k-means clustering is used to filter the image. Note that the conditional logic is configured such that Otsu's method will be used if there is a subfield to b2a_options called otsu. If you want to use k-means clustering, ensure that there is NOT a field called otsu.

The output arguments are:

* <i>angle_image</i>: An image with per-pixel fasicle orientations

* <i>masked_angle_image</i>: <i>angle_image</i> with the muscle ROI mask applied

* <i>angle_image_grid</i>: The gridded angle image, at the user-defined resolution

* <i>vector_image</i>: The X and Y components of the angles in the gridded image

* vesselness_mask: The mask calculated fromteh vesselness image

* vesselness_max: The maximum vesselness response image

* max_cvn_image: An image showing trhe maximum value of the convolution of wavelet with the pixels

* cvn_images: All of the convolution images

* sample_wavelet: The wavelet use to determine fascicle orientation

## 4. Example Code
Given:
1.	A grayscale image stored in the variable image_data_struc.gray;

the following code will allow the user to 

1.	Define a Gaussian kernel with standard deviations of 1.5-3 pixels and kernel size 30x30, in SD increments of 0.5 pixels
2.	Estimate the vesselness response with coefficients Beta = 0.75 and C=0.25
3.	Create an anisotropic wavelet with damping coefficient = 2.5, wavelet frequency = 6, kernel size of 26x26, across angles of 155 to 200 degrees, in steps of 1 degree
4.	Form a vesselness mask using the threshold set by Otsu's method
5.	Smooth the values using a median filter, in grids of 30x45


%set processing options

b2a_options.stdev_1 = 0.75;

b2a_options.stdev_2 = 2.5;

b2a_options.stdev_inc = 0.5;

b2a_options.gauss_size = 18; 

b2a_options.vessel_beta = 0.75;

b2a_options.vessel_c = 1 - b2a_options.vessel_beta;

b2a_options.wavelet_damp = 10;

b2a_options.wavelet_kernel = 18;

b2a_options.wavelet_freq = 5;

b2a_options.min_angle = 160;

b2a_options.max_angle = 200;

b2a_options.num_angles = 31;

b2a_options.num_pixels = [45 45];

b2a_options.otsu = 1;

[angle_image, masked_angle_image, angle_image_grid, vector_image, vesselness_mask, vesselness_max, max_cvn_image, cvn_images, sample_wavelet] = 
bmode2angle_us(image_data_struc.gray(:,:,1), image_data_struc.mask, b2a_options); 

%display a masked version of the gridded fascicle orientation image:

figure

imagesc(angle_image_grid.*image_data_struc.mask)

axis image

caxis([160 200])

colorbar

axis image

set(gcf, 'Units', 'normalized', 'Position', [0.1000    0.1000    0.8000    0.7000])

## 5. Acknowledgements
 People: Emily Bush, Ke Li, Hannah Kilpatrick, Bruce Damon
 
 Grant support: NIH/NIAMS R01 AR073831
