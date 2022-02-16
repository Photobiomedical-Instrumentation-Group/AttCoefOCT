function [frame_2D, frame_info, elapsed_time] = Load_Frame(file, index_frame, frame)
  
% Load_Frame  Load Thorlabs Swept Source OCT .FRG or .IMG frame
% at index_frame location. The .FRG frame recorded for
% spectral fringes in k (wavenumber) domain after the MZI clock calibration. 
% Call format: [frame_2D, frame_info, elapsed_time] = Load_Frame(file_head, index_frame, frame_head)
%
% For .FRG file, returned frames of OCT spectral fringe data in a 2D array with 
% format frame_2D(FFT_length, width) 
%
% For. IMG file, returned frames of images in a 2D array with 
% format frame_2D(depth, width) 

% Copyright 2009-2010 Thorlabs Inc.
% $Revision: 2.0 $ $Date: 2009/8/21 $

  
% read one frame of FRG or IMG data at the position index_frame
disp(sprintf('...Frame loaded: %d',index_frame))
elapsed_time = fread(file.fid, 1, 'int32' );                      % 4 bytes of elapsed time
frame_info = fread(file.fid, 36, 'int8' );                      % 4 bytes of System time of current frame + 32 bytes Reserved
if file.type == 'FRG'
    frame_data = fread(file.fid, frame.pixel_num, 'int16' );      % int16 = 2 bytes = one pixel in FRG frame
    frame_2D = reshape(frame_data, frame.FFT_length, frame.width);
elseif file.type == 'IMG'
    frame_data = fread(file.fid, frame.pixel_num, 'uint8' );  % uint8 = 1 bytes = one pixel in IMG frame
    frame_2D = reshape(frame_data, frame.depth, frame.width);
end


