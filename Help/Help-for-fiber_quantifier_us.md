# Help for the function <i>fiber_quantifier_us</i>, v. 1.0.0

## Introduction

This help file contains information about
1) [Purpose of the program](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-fiber_quantifier_us.md#1-purpose)
2) [Usage of the program](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-fiber_quantifier_us.md#2-usage)
3) [Syntax](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-fiber_quantifier_us.md#3-Syntax)
4) [Example Code](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-fiber_quantifier_us.md#4-Example-Code)
5) [Acknowledgements](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-fiber_quantifier_us.md#5-Acknowledgements)

## 1. Purpose
 
The function <i>fiber_quantifier_us</i> is used to calculate the muscle architectural parameters fiber tract length, pennation angle, and curvature in the MuscleUS_Toolbox.

## 2. Usage
The user inputs a matrix containing fiber tract positions, specified in units of mm; a structure containing information about the seeding region of interest; and a structure containing image metadata. Computations are made automatically; the length of the full tract, pennation angle over the first 5 mm, and curvature at each point are calculated.  The procedures for each calculation are:

* <i>Fiber tract length</i>: This is measured by summing the inter-point distances along the tract.

* <i>Pennation</i>:  For each fiber tract, position vectors are formed along the local segment of the aponeurosis and the first 5 mm of the tract. Each position vector is converted to unit length.  The pennation angle is calculated as the inverse cosine of the dot product of the two vectors. 

* <i>Curvature</i>: The method for curvature measurements is adapted from [Damon et al, Magn Reson Imaging 2012](https://pubmed.ncbi.nlm.nih.gov/22503094/). Briefly, these use a discrete implementation of the Frenet-Serret equations. The curvature K is defined in 

     dT/ds = K N
     
  where T is the tangent line to points along the curve, s is the step length between points, and N is the normal vector. In <i>fiber_quantifier</i>, K is calculated by multiplying each side of this equation by the Moore-Penrose pseudoinverse matrix of N.

For curvature, the best results are obtained with polynomial-fitted fiber tracts, calculated using <i>fiber_smoother_us</i>. 

The function outputs vectors containing the fiber tract lengths, pennation angles, and mean curvatures and a matrix containing the point-wise curvature values.

## 3. Syntax

[penn_mean, tract_lengths, curvature_mean, curvature_all] = fiber_quantifier_us(fiber_all_mm, roi_struc, image_info_struc);

The input arguments are:
 
* <i>fiber_all_mm</i>: A 4D matrix containing the fiber tract points, with units of mm. This matrix could be substituted with smoothed_fiber_all_mm (the output of [<i>fiber_smoother_us</i>](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-fiber_smoother_us.md))

* <i>roi_struc</i>: A structure containing information about the aponeurosis ROI, output from <i>define_muscleroi_us</i>

* <i>image_info_struc</i>: A structure containing image metadata, output from <i>read_dicom_us</i>

The output arguments are:
* <i>penn_mean</i>: A vector containing the pennation angle of each tract, in degrees

* <i>tract_lengths</i>: A vector containing the fiber tract lengths, in mm

* <i>curvature_mean</i>: A vector containing the mean curvature of each tract, in m<sup>-1</sup>

* <i>curvature_all</i>: A matrix containing the point-wise curvature values, in m<sup>-1</sup>

## 4. Example Code
The code below will measure fiber tract length, pennation angle, and curvature in polynomial-fitted fiber tracts

%% call the function for smoothed fiber tracts:

[penn_mean, tract_lengths, curvature_mean, curvature_all] = fiber_quantifier_us(smoothed_fiber_all_mm, roi_struc, image_info_struc);

## 5. Acknowledgements
 People: Bruce Damon, Hannah Kilpatrick
 
 Grant support: NIH/NIAMS R01 AR073831
