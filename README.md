# MuscleUS_Toolbox
## A Matlab Toolbox for Skeletal Muscle Ultrasound Fiber Tractography 

The MuscleUS_Toolbox consists of a series of custom-written Matlab functions for performing ultrasound fiber tractography in skeletal muscle. This README file contains
  1) [Acknowledgements](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/README.md#1-acknowledgements)
  2) [License information](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/README.md#2-license-information)
  3) [A list of MATLAB requirements](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/README.md#3-matlab-requirements)
  4) [A list of the conventions assumed regarding data acquisition](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/README.md#4-data-acquisition-conventions-assumed)
  5) [An overview of a typical workflow using the toolbox](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/README.md#5-overview-of-a-typical-workflow)
  6) [Links to other resources in the toolbox and online](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/README.md#6-other-resources)

## 1. Acknowledgements
The functions in this toolbox reflect the collective contributions of many individual, including: Emily Bush, Crystal Coolbaugh, Bruce Damon, Zhaohua Ding, Hannah Kilpatrick, and Ke Li. Details regarding authorship and individual contributions are noted in each function.

This work was supported by NIH grant NIH/NIAMS R01 AR073831. By using this software, users agree to acknowledge the active grant (NIH/NIAMS R01 AR073831) in presentations and publications and to adhere to NIH policies regarding open access to their publications. 

## 2. License Information
This work is covered under a [GNU General Public License](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/LICENSE.md), v. 3 or later.

## 3. MATLAB Requirements
The functions have been tested using MATLAB v. 2019b.  The toolbox consists primarily of custom-written functions, but also calls MATLAB functions in the base package and the image processing toolbox.

## 4. Overview of a Typical Workflow
### A. Open the image using <i>read_dicom_us</i>.
To begin the session, a DICOM-formatted ultrasound file is opened.

### B. Define muscle boundaries and the aponeurosis using the function <i>define_muscleroi_us</i>
Real muscle fibers are assumed to be contained entirely within a single muscle of interest. The fiber_track_us function therefore requires the user to input a binary image mask demarcating the muscle boundaries; this mask is used to prevent fiber tracts from exiting the muscle of interest. The tracts are propagated from a set of points, commonly called "seed points." In the MuscleUS_Toolbox, the anatomical structure into which the muscle fibers insert (a flattened tendinous structure called an aponeurosis) is used to define these points. The function [<i>define_muscleroi_us</i>](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Matlab-Functions/define_muscleroi_us.m) is used to define the mask and the aponeurosis ROI. Follow [this link](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-define_muscleroi_us.md) for detailed help on this function.

### C. Calculate the fiber orientations using the function <i>bmode2angle_us</i>
Using the B-mode image, the muscle fascicles orientations are estimated using the algorithm presented by Rana et al., (J Biomech, 42:2068,2009). The images are processed using the following steps: 
 * A series of Gaussian blurring steps of varying sizes  
 * Calculation of the vesselness response of the structures
 * Calculation of the Hessian matrix of the vesselness response 
 * An anisotropic wavelet is convolved with the image at a range of orientations
 * The angle at which the maximum convolution of the wavelet with the image is taken as the fascicle orientation.  
 * The angles are averaged across grid squares of user-defined dimensions.  

The function returns an image at the original resolution, a masked image at the original resolution, a gridded image of angles, and a masked image with the components of unit vectors indicating the fascicle orientations.

### D. Generate the fiber tracts using the function <i>fiber_track_us</i>
Fiber tracts are propagated from the seed points by following the direction indicated by the second eigenvector of the image intensity gradient's Hessian matrix. The function <i>fiber_track_us</i> is used to perform this integration. The major output of this function is a matrix containing the {row, column, slice} coordinates of each point along each fiber tract. Follow [this link](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-fiber_track_us.md) for detailed help on this function.

### E. Smooth the fiber tracts using the function <i>fiber_fitter_us</i>
Fiber tract points are subject to errors in position because of the presence of noise and artifacts in the images. To mitigate these effects, the function [<i>fiber_fitter_us</i>](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Matlab-Functions/fiber_fitter.m) performs a polynomial fit to each fiber tract. This also allows the interpolation of the fiber tract positions at a resolution higher than the original tracts.  This step is not required, but is strongly recommended prior to calling the <i>fiber_quantifier_us</i> function. Follow [this link](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-fiber_fitter_us.md) for detailed help on this function.

### F. Quantify the tracts' structural properties using the function <i>fiber_quantifier_us</i>
After the fiber tracts have been polynomial-fitted, their structural properties are quantified using the function [<i>fiber_quantifier_us</i>](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Matlab-Functions/fiber_quantifier_us.m).  The properties quantified include the pennation angle, curvature, and length. These properties are calculated in a pointwise manner along the fiber tracts. Follow [this link](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-fiber_quantifier_us.md) for detailed help on this function.

### G. Visualize the results using the function <i>fiber_visualizer_us</i>
At any stage, the results can be visualized using the function [<i>fiber_visualizer_us</i>](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Matlab-Functions/fiber_visualizer_us.m). The user can select the mask, seed surface, and/or fiber tracts for display.  The user can also select which image slices to display for anatomical reference. Follow [this link](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-fiber_visualizer_us.md) for detailed help on this function.

## 6. Other Resources
### A. Within the toolbox:
* [Here's a link to all of the MATLAB functions](https://github.com/bdamon/MuscleUS_Toolbox/tree/master/Matlab-Functions)
* [Here's a link to all of the help files](https://github.com/bdamon/MuscleUS_Toolbox/tree/master/Help)
* [Here's a link to templates for submitting feature requests and bug reports](https://github.com/bdamon/MuscleUS_Toolbox/tree/master/Issues)

### B. External to the toolbox:
