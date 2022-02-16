function Frame_Locator(fid, frame_start, frame_length_bytes)


% Frame_Locator  locating starting frame poisition in the .FRG or .IMG file
% Call format: Frame_Locator(fid, frame_start, frame_length_bytes)
%
% fid: file handle returned by Open_File() 
% frame_start: the index of the starting frame in file
% frame_length_bytes: the length of one frame in bytes


% Copyright 2009-2010 Thorlabs Inc.
% $Revision: 2.0 $ $Date: 2009/8/21 $


fseek(fid, (frame_start-1)*frame_length_bytes, 'cof');
