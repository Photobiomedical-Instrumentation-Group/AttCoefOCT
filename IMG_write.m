function file_wr_fid = IMG_write(file_rd, frame_rd)

% IMG_write    write a .IMG file header
% Call format: IMG_write(file_input, frame_input);
% 
% file_rd: a structure contains file header information 
% frame_rd: a structure contains frame header information

% Copyright 2009-2010 Thorlabs Inc.
% $Revision: 2.0 $ $Date: 2009/8/21 $

[file_name, file_path] = uiputfile('*.IMG', 'Write IMG File as');  % set file name and file path of the .IMG data
     

    % file location
    file_wr_location = [file_path, file_name];
     
    % open file and return file handle fid
    file_wr_fid = fopen(file_wr_location, 'wb' );
    
    % write header of the .IMG data using file handle fid
    fwrite(file_wr_fid, file_rd.id, '16*uchar');      % File identification string
    
    fwrite(file_wr_fid, file_rd.nFr,  'int32');         % Number of images saved in the file
    fwrite(file_wr_fid, frame_rd.width,  'int32');      % frame width, width = image_width*Average_Num for one channel
    fwrite(file_wr_fid, frame_rd.depth,  'int32');      % Image depth
    fwrite(file_wr_fid, file_rd.nFrp3D,  'int32');      % Number of frames in each 3D volume
    fwrite(file_wr_fid, file_rd.n3D,  'int32');         % Number of 3D volume, 0 means only 2D movie recorded, 1 means 3D data recorded
    fwrite(file_wr_fid, frame_rd.FFT_length,  'int32'); % FFT_length for OCT fringe
    fwrite(file_wr_fid, frame_rd.Frame_byte,  'int32'); % Frame size in bytes
    fwrite(file_wr_fid, frame_rd.Record_length,  'int32'); % Record length
    fwrite(file_wr_fid, frame_rd.imaging_mode, 'int16' );   % Imaging_mode is used to check imaging mode, 1 is PSOCT imaging mode, 0 is other modes.
    fwrite(file_wr_fid, frame_rd.average_number, 'int16' );    % Number of A-line numbers for averaging in one frame
    fwrite(file_wr_fid, frame_rd.imaging_mode, 'int16');
    
  