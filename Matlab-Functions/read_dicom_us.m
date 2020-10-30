function [image_data_struc, image_info_struc] = read_dicom_us(input_structure)
%
%FUNCTION read_US
%  [image_data_struc, image_info_struc] = read_dicom_us(input_structure);
%
%USAGE
%  The function read_dicom_us is used to open ultrasound image files in the
%  MuscleUS_Toolbox. File I/O and other options can be set using the
%  optional input argument input_structure.  If input_structure is not
%  included, the user is prompted to select the input and output file names.
%
%INPUT ARGUMENT
%  input_structure (optional): A structure containing file input/output
%    information. If used, the required fields are:
%      -input_path_name: A path to the directory holding the image data
%       files
%      -input_file_name: The file name of interest, including the .DCM
%       extension
%      -output_path_name: A path to the directory where the Matlab data
%       file will be stored
%      -output_file_name: The file name of the Matlab data file
%      -show_image: A flag to view the image (1=yes, 0=no). If the image
%        data is 4D, the first image of the data series is shown. If
%        input_structure is not included as an input argument, show_image
%        is set to zero by default.
%    If no input arguments are included, the user is prompted to select
%    the input and output file names.
%
%OUTPUT ARGUMENTS
%  image_data_struc: The imaging data, with the following fields:
%   -orig: The DICOM image(s), with dimensions of rows x columns
%    x color layer. Depending on the acquisition details, there may be a
%    fourth dimension, usually time.
%   -doub: The images converted to double precision
%   -gray: The images converted to grayscale
%
%  image_info_struc: The contents of the DICOM file header
%
%VERSION INFORMATION
%  v. 0.1
%
%ACKNOWLEDGEMENTS
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

cd(input_path_name);
image_info_struc = dicominfo(input_file_name);

image_data_struc.orig = dicomread(input_file_name);
image_data_struc.doub = double(image_data_struc.orig);
image_data_struc.doub=image_data_struc.doub/max(max(max(max(image_data_struc.doub))));

if length(size(image_data_struc.orig))==3
    image_data_struc.gray = image_data_struc.doub(:,:,1)*0.299...
        + image_data_struc.doub(:,:,2)*0.587 + image_data_struc.doub(:,:,3)*0.114;
elseif length(size(image_data_struc.orig))==4
    image_data_struc.gray = image_data_struc.doub(:,:,1,:)*0.299...
        + image_data_struc.doub(:,:,2,:)*0.587 + image_data_struc.doub(:,:,3,:)*0.114;
end


% get class of original image
image_info_struc.ImageClass = class(image_data_struc.orig);

%% Save data

cd(output_path_name);
save(output_file_name, '-v7.3');

%% Show images

if show_image == 1
    
    fiber_visualizer_us(image_data_struc.doub(:,:,1))
    
end

%% End function

return
