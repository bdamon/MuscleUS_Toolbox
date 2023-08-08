# MuscleUS_Toolbox
## A Matlab Toolbox for Skeletal Muscle Ultrasound Fiber Tractography 

The MuscleUS_Toolbox consists of a series of custom-written Matlab functions for performing ultrasound fiber tractography in skeletal muscle. This README file contains
  1) [Acknowledgements](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/README.md#1-acknowledgements)
  2) [License information](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/README.md#2-license-information)
  3) [Getting started](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/README.md#3-getting-started)
  4) [A list of the conventions assumed regarding data acquisition](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/README.md#4-data-acquisition-conventions-assumed)
  5) [An overview of a typical workflow using the toolbox](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/README.md#5-overview-of-a-typical-workflow)
  6) [Links to other resources in the toolbox and online](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/README.md#6-other-resources)

## 1. Acknowledgements
The functions in this toolbox reflect the collective contributions of many individuals, including: Emily Bush, Crystal Coolbaugh, Bruce Damon, Zhaohua Ding, Hannah Kilpatrick, and Ke Li. Details regarding authorship and individual contributions are noted in each function.

This work was supported by NIH grant NIH/NIAMS R01 AR073831. By using this software, users agree to acknowledge the active grant (NIH/NIAMS R01 AR073831) in presentations and publications and to adhere to NIH policies regarding open access to their publications. 

## 2. License Information
This work is covered under a [GNU General Public License](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/LICENSE.md), v. 3 or later.

## 3. Getting Started
### A. Downloading the Toolbox
The easiest way to do this is to click once on the green Code button. Select the "Download ZIP" option; this will download a compressed folder to your computer. Then extract the files to a convenient place on your computer (note that after extracting the files, you will need to set a MATLAB path to the directory that holds the custom-written functions).

### B. MATLAB Requirements
The functions have been tested using MATLAB v. 2021 b, Release 2.  The toolbox consists primarily of custom-written functions, but also calls MATLAB functions in the base package and the image processing toolbox.

## 4. Overview of a Typical Workflow
### A. Open the image using <i>read_dicom_us</i>.
To begin the session, a DICOM-formatted ultrasound file is opened.  The function [<i>read_dicom_us</i>](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Matlab-Functions/read_dicom_us.m) will prepare image data and information structures in the form expected by subsequent functions.  Help is available [here](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-read_dicom_us.md).

### B. Define muscle boundaries and the aponeurosis using the function <i>define_muscleroi_us</i>
Real muscle fibers are assumed to be contained entirely within a single muscle of interest. The function [<i>define_muscleroi_us</i>](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Matlab-Functions/define_muscleroi_us.m) is therefore used to create a binary image mask demarcating the muscle boundaries; this mask is used to restrict analyses to the region of interest within the muscle. The tracts are propagated from a set of points, commonly called "seed points." In the MuscleUS_Toolbox, the anatomical structure into which the muscle fibers insert (a flattened tendinous structure called an aponeurosis) is used to define these points. Follow [this link](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-define_muscleroi_us.md) for detailed help on this function.

### C. Calculate the fiber orientations using the function <i>bmode2angle_us</i>
Using the B-mode image, the muscle fascicles orientations are estimated using the algorithm presented by Rana et al., (<i>J Biomech</i>, <b>42</b>:2068, 2009). The images are processed using the following steps: 

* Vesselness filtering:
  * A series of Gaussian blurring steps of varying sizes
  * Calculation of the vesselness response of the structures
  * Calculation of the Hessian matrix of the vesselness response
* Orientation modeling:
  * An anisotropic wavelet is convolved with the image at a range of orientations
  * The angle at which the maximum convolution of the wavelet with the image is taken as the fascicle orientation
  * The angles are averaged across grid squares of user-defined dimensions

The function returns an image at the original resolution, a masked image at the original resolution, a gridded image of angles, a masked image with the components of unit vectors indicating the fascicle orientations, and images for QA purposes.  The current version of [<i>bmode2angle_us</i>](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Matlab-Functions/bmode2angle_us.m) is 1.0.0 and has a detailed help file available [here](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-bmode2angle_us.md).

### D. Generate the fiber tracts using the function <i>fiber_track_us</i>
Fiber tracts are propagated from the seed points by integrating through the vector field defined by the second eigenvector of the image intensity gradient's Hessian matrix. The function [<i>fiber_track_us</i>](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Matlab-Functions/fiber_track_us.m) is used to perform this integration. The major output of this function is a matrix containing the {row, column, slice} coordinates of each point along each fiber tract. Follow [this link](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-fiber_track_us.md) for detailed help on this function.

### E. Smooth the fiber tracts using the function <i>fiber_smoother_us</i>
Fiber tract points are subject to errors in position because of the presence of noise and artifacts in the images. To mitigate these effects, the function [<i>fiber_smoother_us</i>](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Matlab-Functions/fiber_smoother_us.m) performs a polynomial fit to each fiber tract. This also allows the interpolation of the fiber tract positions at a resolution higher than the original tracts.  This step is not required, but is strongly recommended prior to calling the <i>fiber_quantifier_us</i> function. Follow [this link](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-fiber_smoother_us.md) for detailed help on this function.

### F. Quantify the tracts' structural properties using the function <i>fiber_quantifier_us</i>
After the fiber tracts have been polynomial-fitted, their structural properties are quantified using the function [<i>fiber_quantifier_us</i>](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Matlab-Functions/fiber_quantifier_us.m).  The properties quantified include the pennation angle, curvature, and length. These properties are calculated in a pointwise manner along the fiber tracts. Follow [this link](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-fiber_quantifier_us.md) for detailed help on this function.

### G. Visualize the results using the function <i>fiber_visualizer_us</i>
At any stage, the results can be visualized using the function [<i>fiber_visualizer_us</i>](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Matlab-Functions/fiber_visualizer_us.m). The user can select the mask, seed surface, and/or fiber tracts for display. Follow [this link](https://github.com/bdamon/MuscleUS_Toolbox/blob/master/Help/Help-for-fiber_visualizer_us.md) for detailed help on this function.

## 6. Other Resources
### A. Within the toolbox:
* [Here's a direct link to all of the MATLAB functions](https://github.com/bdamon/MuscleUS_Toolbox/tree/master/Matlab-Functions)
* [Here's a direct link to all of the help files](https://github.com/bdamon/MuscleUS_Toolbox/tree/master/Help)
* [Here's a direct link to a sample data processing script](https://github.com/bdamon/MuscleUS_Toolbox/tree/master/Sample-Scripts)
* [Here's a direct link to a sample dataset suitable for practicing using the code](https://github.com/bdamon/MuscleUS_Toolbox/tree/master/Data)
* [Here's a direct link to templates for submitting feature requests and bug reports](https://github.com/bdamon/MuscleUS_Toolbox/tree/master/Issues)

### B. External to the toolbox:
* Here's the [PubMed link](https://pubmed.ncbi.nlm.nih.gov/19646699/) for the paper with the algorithm for modeling fascicle orientation that we used.
* Our paper describing this method is in press in the <i>Journal of Applied Biomechanics</i> and will be linked here as soon as the preprint is available.
