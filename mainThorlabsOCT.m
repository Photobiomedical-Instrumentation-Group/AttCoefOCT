
function  [M3D,OCT_Display] = mainThorlabsOCT(path,ShowImagesWhenLoad,frame_start,frame_stop)

% Main program for processing Thorlabs .FRG or .IMG file recorded from Thorlabs Swept source OCT system 
% Copyright 2009-2010 Thorlabs Inc.
% $Revision: 2.0 $ $Date: 2009/8/21 

octmap.contrast = 1.0;
octmap.brightness = 0;
octmap.db_range = 50;
octmap.method = 1;           %  Mapping method for conversion OCT image from linear scale to log scale, 
                             %  1: method 1;  2: method 2 

apodiz_method = 'Gaussian';  % 'Cosine', 'Gaussian', 'super_Gaussian','Hann', 'Kaiser'
                             % 'Hamming','Blackman', 'Nuttall', 'Blackman_Harris'*,'none'

sliding_average = 'N';        % swith for sliding average, 'Y': sliding average, 'N': non                      
window.shift_depth = 1;      % shift step along depth for sliding average window                
window.shift_width = 1;      % shfit step along width for sliding average window
window.ave_depth = 2;        % window length along depth for sliding average window  
window.ave_width = 2;        % window length along depth for sliding average window 

colormap_show = 'gray';            % colormap for show images


% Open the .FRG file, and return file parameters in the file header.
[file_head, frame_head, code] = Open_File(path);

% show file information
if isempty(code)
    disp('Program terminated');  
else
    disp(file_head.location)
    disp(sprintf(['...Type of the file:', file_head.type]))
    disp(sprintf('...Number of frames in the file is: %d', file_head.nFr))
    
    % show the imaging mode data obtained 
    switch  num2str(frame_head.imaging_mode)
        case '0'
            %disp(sprintf('...Normal OCT imaging mode'))
        otherwise
            display('Error message: imgaging mode other than OCT Fringe or intensity is not provided')  
    end
    
 
    
    
    if frame_start > file_head.nFr       % if the number of frames aquired is less than frame_start you set
        disp(sprintf('...frame_start > number of frames in the file = %d',file_head.nFr))
        disp(sprintf('...frame_start re-assigned to: %d',file_head.nFr))    
        frame_start = file_head.nFr;      % then process the last frame.
    end
    
    if frame_stop > file_head.nFr       % if the number of frames aquired is less than frame_start you set
        disp(sprintf('...frame_stop > number of frames in the file = %d', file_head.nFr))
        disp(sprintf('...frame_stop is re-assigned to: %d', file_head.nFr))  
        frame_stop = file_head.nFr;      % then process to the last frame.
    end
    
    if frame_stop < frame_start
        disp(sprintf('...frame_stop should be larger than frame_start!'))
    end
    
    Frame_Locator(file_head.fid, frame_start, frame_head.length_bytes)
    frm_n = 0;
    for index_frame = frame_start:frame_stop
        frm_n = frm_n + 1;
        % Load 2D .FRG frames at index_frame location, and return a 2D array in the format of size(FFT_length, depth)
        [frame_2D, frame_info, elapsed_time] = Load_Frame(file_head, index_frame, frame_head);
        if file_head.type == 'FRG'
            OCT_complex = FRG_Proc(index_frame, frame_2D, frame_head, apodiz_method);
            OCT_IMG_AS = OCT_Image_Calculation(OCT_complex, frame_head, sliding_average, window);
            OCT_Display = OCT_Image_Mapping(OCT_IMG_AS, frame_head.imaging_mode, octmap);
            OCT_Image_Show(OCT_Display, frame_head.imaging_mode, frm_n, index_frame, colormap_show);
            
%             if file_head.type =='FRG'
%             OCT_complex = FRG_Proc(index_frame, frame_2D, frame_head, apodiz_method);
%             OCT_IMG_AS = OCT_Image_Calculation(OCT_complex, frame_head, sliding_average, window);
%             OCT_Display = OCT_Image_Mapping(OCT_IMG_AS, frame_head.imaging_mode, octmap);
%             OCT_Image_Show(OCT_Display, frame_head.imaging_mode, frm_n, index_frame, colormap_show);
            
            
            % Time_elased(frm_n) = elapsed_time
            % Frame(:,:,frm_n) = OCT_Display;
            
        elseif file_head.type =='IMG'
            
         
      
            % Diego Edit
            OCT_Display = frame_2D;
            if (ShowImagesWhenLoad)
                OCT_Image_Show(OCT_Display, frame_head.imaging_mode, frm_n, index_frame, colormap_show);
                imagesc(OCT_Image_Show)
            end
            
            
        end
        
        M3D(:, :, index_frame) = frame_2D;
                        
    end
    
    % close the .FRG file
    %disp(sprintf('...Number of frames processed: %d', frame_stop - frame_start + 1))
    Close_File(file_head.fid)
end