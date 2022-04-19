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

[Back to the top](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-bmode2angle_us.md)

## 4. Example Code
The code below will measure fiber tract length, pennation angle, and curvature in polynomial-fitted fiber tracts

%% call the function:

[penn_mean, tract_lengths, curvature_mean, curvature_all] = fiber_quantifier_us(smoothed_fiber_all_mm, roi_struc, image_info_struc);

[Back to the top](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-bmode2angle_us.md)

## 5. Acknowledgements
 People: Emily Bush, Ke Li, Hannah Kilpatrick, Bruce Damon
 
 Grant support: NIH/NIAMS R01 AR073831

[Back to the top](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-bmode2angle_us.md)
