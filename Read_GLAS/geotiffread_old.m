function varargout = geotiffread(varargin)
%GEOTIFFREAD Read georeferenced image from GeoTIFF file
%
%   A = GEOTIFFREAD(FILENAME) reads the GeoTIFF image in FILENAME into A.
%   If the file contains a grayscale image, A is a two-dimensional array.
%   If the file contains a truecolor (RGB) image, A is a
%   three-dimensional (M-by-N-by-3) array.  
%
%   FILENAME is a string that specifies the name of the GeoTIFF file.
%   FILENAME may include the directory name; otherwise, the file must be in
%   the current directory or in a directory on the MATLAB path.  If the
%   named file includes the extension '.TIF' or '.TIFF' (either upper or
%   lower case), the extension may be omitted from FILENAME.
%
%   [X, CMAP] = GEOTIFFREAD(FILENAME) reads the indexed image in FILENAME
%   into X and its associated colormap into CMAP. Colormap values in the
%   image file are automatically rescaled into the range [0,1].
%
%   [X, CMAP, R, BBOX] = GEOTIFFREAD(FILENAME) reads the indexed image into
%   X, the associated colormap into CMAP, the referencing matrix into R,
%   and the bounding box into BBOX.  The referencing  matrix must be
%   unambiguously defined by the GeoTIFF file, otherwise  it and the
%   bounding box are returned empty ([]). 
%
%   [A, R, BBOX] = GEOTIFFREAD(FILENAME) reads the grayscale or RGB image
%   into A, the referencing matrix into R, and the bounding box into BBOX.  
%
%   [...] = GEOTIFFREAD(FILENAME, IDX) reads in one image from a
%   multi-image GeoTIFF file. IDX is an integer value that specifies the
%   order that the image appears in the file. For example, if IDX is 3,
%   GEOTIFFREAD reads the third image in the file. If you omit this
%   argument, GEOTIFFREAD reads the first image in the file.
%
%   [...] = GEOTIFFREAD(URL, ...) reads the GeoTIFF image from an  Internet
%   URL.  The URL must include the protocol type (e.g., "http://").
%
%   Note
%   ----
%   GEOTIFFREAD imports pixel data using the TIFF-reading capabilities of
%   the MATLAB function IMREAD and likewise shares any limitations of
%   IMREAD.  Consult the IMREAD documentation for specific information on
%   TIFF image support.
%
%   Example
%   -------
%   % Read and display the Boston GeoTIFF image. 
%   % Includes material (c) GeoEye, all rights reserved.
%   [boston, R, bbox] = geotiffread('boston.tif');
%   figure
%   mapshow(boston, R);
%   axis image off
%   
%   See also GEOSHOW, GEOTIFFINFO, IMREAD, MAPSHOW, MAPVIEW.

% Copyright 1996-2007 The MathWorks, Inc.
% $Revision: 1.1.8.10 $  $Date: 2007/06/04 21:13:28 $

% Verify the input and output argument count
checknargin(1,2,nargin,mfilename);
msg = nargoutchk(0,4,nargout);
if (~isempty(msg))
    eid = sprintf('%s:%s:tooManyOutputs', getcomp, mfilename);
    error(eid, '%s', msg)
end

% Verify the filename and obtain the full pathname
[filename, url] = checkfilename(varargin{1}, {'tif', 'tiff'}, ...
                                mfilename, 1, true);

% Check and set the image index number
if nargin == 2
  idx = varargin{2};
  checkinput(idx, {'numeric'}, {'real' 'scalar' 'positive'}, ...
             mfilename, 'IDX', 2);
else
  idx = 1;
end

% Read the info fields from the filename
info  = geotiffinfo(filename);

% Read the image from the filename
[I, map] = imread(filename,idx);

% Return output arguments
varargout{1} = I;

% Check that the RefMatrix is not null 
%  If so, try to read from a corresponding worldfile
if nargout > 2 && isempty(info.RefMatrix)
  worldfilename = getworldfilename(filename);
  if exist(worldfilename,'file')
    info.RefMatrix = worldfileread(getworldfilename(filename));
    info.BoundingBox = mapbbox(info.RefMatrix, size(I));
  end
end

switch nargout
  case 2
    varargout{2} = map;

  case 3
    varargout{2} = info.RefMatrix;
    varargout{3} = info.BoundingBox;

   case 4
    varargout{2} = map;
    varargout{3} = info.RefMatrix;
    varargout{4} = info.BoundingBox;
end

% Delete temporary file from Internet download.
if (url)
    deleteDownload(filename);
end
