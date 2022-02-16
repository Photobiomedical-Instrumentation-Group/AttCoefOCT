function Close_File(fid)

% Close_File    close the file opened
% Call format: Close_File(fid)
% fid is the file handle returned by Open_File


% Copyright 2009-2010 Thorlabs Inc.
% $Revision: 2.0 $ $Date: 2009/8/21 $

fclose( fid );