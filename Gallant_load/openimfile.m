% function [fid,framecount,iconsize,iconside,filetype,altname]=openimfile(sImFile)
%
% Last update: SVD 11/30/99
%
% Required parameters:
%
% sImFile      - file name of movie for input (.im or .imsm)
%
% Returns:
%
% fid          - matlab binary movie file id (use openimfile to generate it)
% iconside     - pixels per side of each frame in the movie file
% iconsize     - pixels per frame (iconside^2... duh)
% filetype     - code to identify type of file:
%                  0. standard .im file
%                  1 or 2. 1-byte-per-pixel grayscale (.imsm)
%                  format
% filetype:    - which type of known movie file you've just opened
%                 -1 - error opening file
%                  0 - im file format (raw RGB - uint32 per pixel)
%                  1/2/3 - imsm file format (grayscale - uint8 per pixel)
%                  4 - imsm file format double
%                  5 - imsm file format uint32
% altname:     - if imfile loaded from a remote network location 
%                (ie, checkbic>0) name of temp file
%
function [fid,framecount,iconsize,iconside,filetype,altname]=openimfile(sImFile)

if not(exist('sImFile','var')),
   disp('syntax: openimfile(sImFile)');
   framecount=-1;
   iconsize=-1;
   iconside=-1;
   filetype = -1;
   return
end

altname=sImFile;

% open file using "little-endian" format.
[fid,sError]=fopen(sImFile,'r','l');

if fid >= 0,
   framecount=fread(fid,1,'uint32');
   iconsize=fread(fid,1,'uint32');
   if framecount==0 & iconsize==0,
      filetype=2;
      framecount=0;  % must read big-endian uint32s
      for ii=1:4,
         framecount=bitshift(framecount,8)+fread(fid,1,'uint8');
      end
      iconsize=0;
      for ii=1:4,
         iconsize=bitshift(iconsize,8)+fread(fid,1,'uint8');
      end
      iconside=sqrt(iconsize);
      
   elseif framecount==0 & iconsize==1,
      filetype=2;
      framecount=fread(fid,1,'uint32');  %little-endian uint32
      iconsize=fread(fid,1,'uint32');
      iconside=sqrt(iconsize);
   elseif framecount==0 & ismember(iconsize,[3 4 5]),
      filetype=iconsize;
      %arms=[0 imfilefmt framecount spacedimcount iconsizeout imfilefmt];
      framecount=fread(fid,1,'uint32');
      spacedimcount=fread(fid,1,'uint32');
      iconside=fread(fid,spacedimcount,'uint32');
      iconsize=prod(iconside);
   elseif framecount==0 & (iconsize>=101 & iconsize<=104),
      filetype=iconsize;
      framecount=fread(fid,1,'uint32');  %little-endian uint32
      iconsize=fread(fid,1,'uint32');
      iconside=sqrt(iconsize);
      
   elseif framecount==0 & iconsize==105,  % log sf format
      filetype=105;
      disp('Opening lim file...');
      framecount=fread(fid,1,'uint32');  %little-endian uint32
      iconside=fread(fid,3,'uint32');
      iconsize=prod(iconside);
      
   else
      fclose(fid);
      [fid,sError]=fopen(sImFile,'r','b');
      framecount=fread(fid,1,'uint32');
      iconsize=fread(fid,1,'uint32');
      iconside=sqrt(iconsize);
      
      filetype=0;
   end

else
   framecount=-1;
   iconsize=-1;
   iconside=-1;
   filetype = -1;
end

