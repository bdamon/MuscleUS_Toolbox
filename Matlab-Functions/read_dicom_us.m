function [image_data_struc, image_info_struc] = read_dicom_us(input_structure)
%
%FUNCTION read_dicom_us
%  [image_data_struc, image_info_struc] = read_dicom_us(input_structure);
%
%USAGE
%  The function read_dicom_us is used to open ultrasound image files in the
%  MuscleUS_Toolbox. File I/O and other options can be set using the
%  optional input argument input_structure.  If input_structure is not
%  included, the user is prompted to select the input and output file names.
%
%  Structures containing the image(s) (in several formats) and the image 
%  metadata are returned
%
%INPUT ARGUMENT
%  input_structure (optional): A structure containing file input/output
%    information. If used, the required fields are:
%      -.input_path_name: A path to the directory holding the image data
%        files
%      -.input_file_name: The file name of interest, including the .DCM
%        extension
%      -.output_path_name: A path to the directory where the Matlab data
%        file will be stored
%      -.output_file_name: The file name of the Matlab data file
%      -.show_image: A flag to view the image (1=yes, 0=no). If the image
%        data is 4D, the first image of the data series is shown. If
%        input_structure is not included as an input argument, show_image
%        is set to zero by default.
%    If no input arguments are included, the user is prompted to select
%    the input file and create an output file name.
%
%OUTPUT ARGUMENTS
%  image_data_struc: The imaging data, with the following fields:
%   -.orig.native: The original DICOM image(s), with dimensions of rows x
%      columns x color layer (for RGB and YCbCr formats). Depending on the
%      acquisition details, there may be a fourth dimension, usually time.
%   -.orig.native.doub: The original images converted to double precision
%   -.orig.native.norm: The original images converted to a signal range of
%      0-1
%   -gray: The images converted to grayscale
%   -rbg: The images converted to RGB format
%
%  image_info_struc: The contents of the DICOM file header, plus:
%   -dynamics: the number of images in the time series
%   -PixelSpacingX (and Y, R, C): The pixel spacing, in mm, in the X, Y,
%     row (=Y), and column (=X) directions
%   -RegionLocation: The pixel locations within the image that contain the
%     imaged anatomy (given as [minX maxX minY maxY])
%   -FieldOfView: the number of pixels in the X and Y directions, times the
%     corresponding pixel spacings
%
%VERSION INFORMATION
%  v. 1.0.0 (8/1/23) Bruce Damon
%
%ACKNOWLEDGEMENTS
%  People: Bruce Damon
%  Grant support: NIH/NIAMS R01 AR073831

%% Examine input structure, if present; otherwise, prompt user for variable and path names

if exist('input_structure', 'var')

    input_path_name = input_structure.input_path_name;
    input_file_name = input_structure.input_file_name;

    output_path_name = input_structure.output_path_name;
    output_file_name = input_structure.output_file_name;

    show_image = input_structure.show_image;

else

    [input_file_name, input_path_name] = uigetfile('*.DCM', 'Select any .DCM file');
    [output_file_name, output_path_name] = uiputfile('*.mat', 'Specify output file directory and name');

    show_image = 0;

end


%% Open files

% open file
cd(input_path_name);
image_info_struc = dicominfo(input_file_name);
image_data = dicomread(input_file_name);

%determine image type - assume either RGB (R) or monochrome (M)
image_type = image_info_struc.PhotometricInterpretation(1);

%convert to double precision, normalized, and (as needed) grayscale images
image_data_struc.orig.native = image_data;
image_data_struc.orig.doub = double(image_data);
image_data_struc.orig.norm = image_data_struc.orig.doub/max(max(max(max(image_data_struc.orig.doub))));

if image_type=='M'                                                          %monochrome image - already grayscale

    image_data_struc.gray = image_data_struc.orig.norm;

elseif image_type=='R'                                                      %if it's an RGB image, convert to grayscale

    image_data_struc.rgb = image_data_struc.orig.norm;                      %put the rgb image in a standard place in the strcture

    if length(size(image_data_struc.orig.norm))==3                               %if there is only one image in the time series
        image_data_struc.gray = rgb2gray(image_data_struc.rgb);
        image_info_struc.dynamics = 1;
    elseif length(size(image_data_struc.orig.norm))==4                           %if there are multiple dynamics
        image_data_struc.gray = rgb2gray(image_data_struc.rgb);
        image_info_struc.dynamics = length(image_data_struc.orig(1,1,1,:));
    end

elseif image_type=='Y'                                                      %if it's a YCbCr image, convert to RGB and then convert to grayscale


    if length(size(image_data_struc.orig.norm))==3                          %if there is only one image in the time series

        %convert to grayscale
        Y = double(image_data_struc.orig.native(:,:,1));                    %first get the Y, Cb, and Cr channels
        Cb = double(image_data_struc.orig.native(:,:,2));
        Cr = double(image_data_struc.orig.native(:,:,3));

        G = Y - floor((Cr + Cb) / 4);                                       %then convert to grayscale, via RGB intermediate step
        R = Cr + G;
        B = Cb + G;
        image_data_struc.gray = 0.299*R + 0.587*G + 0.114*B;
        image_info_struc.dynamics = 1;

    elseif length(size(image_data_struc.orig.norm))==4                      %if there are multiple dynamics

        %convert to grayscale
        Y = double(image_data_struc.orig.native(:,:,1,:));                  %first get the Y, Cb, and Cr channels
        Cb = double(image_data_struc.orig.native(:,:,2,:));
        Cr = double(image_data_struc.orig.native(:,:,3,:));

        G = Y - floor((Cr + Cb) / 4);                                       %then convert to grayscale, via RGB intermediate step
        R = Cr + G;
        B = Cb + G;
        image_data_struc.gray = 0.299*R + 0.587*G + 0.114*B;
        image_info_struc.dynamics = length(image_data_struc.orig(1,1,1,:));

    end

end

% put pixel spacing, region location, and field of view in easily accessible places
image_info_struc.PixelSpacingX = image_info_struc.SequenceOfUltrasoundRegions.Item_1.PhysicalDeltaX/1E-1; %convert to mm; X
image_info_struc.PixelSpacingY = image_info_struc.SequenceOfUltrasoundRegions.Item_1.PhysicalDeltaY/1E-1; %convert to mm; Y
image_info_struc.PixelSpacingR = image_info_struc.SequenceOfUltrasoundRegions.Item_1.PhysicalDeltaY/1E-1; %convert to mm; rows (=Y)
image_info_struc.PixelSpacingC = image_info_struc.SequenceOfUltrasoundRegions.Item_1.PhysicalDeltaX/1E-1; %convert to mm; cols (=X)

image_info_struc.RegionLocation = [image_info_struc.SequenceOfUltrasoundRegions.Item_1.RegionLocationMinX0 ...
    image_info_struc.SequenceOfUltrasoundRegions.Item_1.RegionLocationMaxX1...
    image_info_struc.SequenceOfUltrasoundRegions.Item_1.RegionLocationMinY0 ...
    image_info_struc.SequenceOfUltrasoundRegions.Item_1.RegionLocationMaxY1];

image_info_struc.FieldOfView = [(image_info_struc.RegionLocation(2) - image_info_struc.RegionLocation(1))*image_info_struc.PixelSpacingX ...
    (image_info_struc.RegionLocation(4) - image_info_struc.RegionLocation(3))*image_info_struc.PixelSpacingY];
  
%% Save data

cd(output_path_name)
save(output_file_name)

%% Show images

if show_image == 1

    fv_options.plot_tracts=0;
    fv_options.plot_roi=0;
    fv_options.plot_mask=0;

    fiber_visualizer_us(image_data_struc.gray(:,:,1), fv_options)

end

%% End function

return
