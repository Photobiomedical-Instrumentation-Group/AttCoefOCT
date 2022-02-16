function [file, frame, code] = Open_File(path)

% Open_File    open a .FRG or .IMG file and return its header information
% Call format: [file_head, frame_head] = Open_File();
% 
% file_head: a structure contains file header information 
% frame_head: a structure contains frame header information

% Copyright 2009-2010 Thorlabs Inc.
% $Revision: 2.0 $ $Date: 2009/8/21 $

% [file_name, file_path, filter] = uigetfile({'*.FRG'; '*.IMG'}, 'Select a .FRG or .IMG File');  % get file name and file path of the fringe data
     
%     if filter == 1;
%        file.type = 'FRG';
%     elseif filter == 2
%        file.type = 'IMG';
%     end
    
% [file_name, file_path] = uigetfile({'*.IMG'}, 'Select a .IMG File');  % get file name and file path of the fringe data

% [file_name, file_path] = uigetfile({'*.IMG'}, 'Select a .IMG File');
[file_name, file_path] = uigetfile({'*.IMG'}, 'Select a .IMG File',path);


file.type = 'IMG';
    
    % file location
    file.location = [file_path, file_name,];
     
    
    % open file and return file handle fid
    file.fid = fopen(file.location, 'rb' );
    
    % read header of the .FRG data using file handle fid
    file.id = fread(file.fid, 16, '*char');        % File identification string
    file_head = fread(file.fid, 8, 'int32' );       % File_header
    file.nFr = file_head(1);                         % Number of images saved in the file
    frame.width = file_head(2);                      % frame width, width = image_width*Average_Num for one channel
    frame.depth = file_head(3);                      % Image depth
    file.nFrp3D = file_head(4);                      % Number of frames in each 3D volume
    file.n3D = file_head(5);                         % Number of 3D volume, 0 means only 2D movie recorded, 1 means 3D data recorded
    frame.FFT_length = file_head(6);                 % FFT_length for OCT fringe
    if frame.FFT_length == 0
        frame.FFT_length = 2*frame.depth;
    end
    frame.Frame_byte = file_head(7);                       % Frame size in bytes
    frame.Record_length = file_head(8);                    % Record length

    frame.PS_fringe_check = fread( file.fid, 1, 'int16' );     % PS_Fringe_check, 1 is PSOCT Fringe imaging mode, 0 is other modes.
    if frame.PS_fringe_check ==[]
       frame.PS_fringe_check = 0;
    end
    
    frame.average_number = fread(file.fid, 1, 'int16' );     % Number of A-line numbers for averaging in one frame
    if frame.average_number == []
       frame.average_number = 1; 
    end
    
    frame.imaging_mode = fread(file.fid, 1, 'int16');
    if frame.imaging_mode ==[]
       frame.imaging_mode = 0;  
    end
        
    file.junk = fread(file.fid,458,'int8');                      % Reversed bytes
    
        
    if (frame.imaging_mode == 0)                                    % Normal imaging mode, .IMG or .FRG format
        frame.num_DAQ_Ch = 1;                                        % Number of DAQ channels for detection of fringes is 1
        
        if file.type =='FRG'
            frame.pixel_num = frame.width * frame.FFT_length;           % FRG frame pixel number
            frame.length_bytes = 40 + frame.pixel_num*2;               % FRG frame length in bytes, 40 bytes is sub hearder length in one frame. (one pixel = 2 bytes)
        elseif file.type == 'IMG'
            
            frame.pixel_num = frame.width * frame.depth;                % IMG frame pixel number
            frame.length_bytes = 40 + frame.pixel_num;                  % IMG frame length in bytes, 40 bytes is sub hearder length in one frame. (one pixel = 1 bytes)
        end
        code = 0;
    else                                                            % other mode is not provided
        
        disp('Error message: imgaging mode other than OCT Fringe or intensity is not provided') 
        code = [];
    end
    
    