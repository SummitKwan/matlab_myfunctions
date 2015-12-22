% function mov = readfromimfile(fid,framestoread,iconside,filetype,
%                               final_pix,fmask,croprange,smallfmt,dosmooth)
%
% Last update: SVD 11/30/99
% Last update: SVD 3/19/02 - added support for arbitrary number of
%                            dimensions and uint8/double/uint32 resolution
%
% Required parameters:
%
% fid          - matlab binary movie file id (use openimfile to generate it)
% framestoread - number of frames to read
% iconside     - vector of the size of each spatial dimension
% filetype     - code to identify type of file:
%                  0. old (SGI) .im file ("big-endian" integer format)
%                  1 or 2. 1-byte-per-pixel grayscale (.imsm)
%                  (1="big-endian", 2="little-endian" integer format)
%                  3. double
%                  4. uint32
%
% Optional parameters:
%
% final_pix    - scale cropped region of movie to final_pix X final_pix
%                (default=iconside)
% fmask        - iconside X iconside 1/0 matrix to mask movie
%                before scaling (default=ONES(iconside,iconside))
% croprange    - coordinates in movie frame to crop out before scaling
%                of the format [x0 y0 x1 y1].  
%                (default=[1 1 iconside iconside])
% smallfmt     - flag.  if 1, return mov as uint8.  if 0, return mov
%                as double (default=0)
% 
% Returns:
%
% mov          - size X size X ... X time matrix containing frames from
%                the movie
%
function mov = readfromimfile(fid,framestoread,iconside,filetype,final_pix,fmask,croprange,smallfmt,dosmooth)

if nargin < 4,
   disp ('readfromimfile.m:  ERROR: must supply first 4 arguments.');
   return
end
if ~exist('dosmooth','var'),
   dosmooth=0;
end

% set parameters to default values if they haven't been specified
if not(exist('croprange','var')),
    [fmask,croprange]=movfmask(iconside(1),1.0,iconside(1));
    fmask=ones(iconside(1));
end
if not(exist('final_pix','var')) | isempty(final_pix),
   final_pix=iconside(1);
   redosize=0;
elseif final_pix==iconside & isempty(find(fmask<1)),
   redosize=0;
else
   redosize=1;
end
if not(exist('smallfmt','var')),
    smallfmt=0;
end

% set scaling ratio
%ratio=scale_to_pix./iconside(1);
iconsize=iconside(1).^2;  % total pixels per frame

% determine final dimensions, ie, scaled cropped region for setting
% size of mov
%crop_to_pix=round((croprange(3)-croprange(1)+1).*ratio);

if smallfmt == 1
	fmttype = 'uint8';
else
	fmttype = 'double';
end

crop_to_pix=final_pix;
if crop_to_pix < iconside(1),
   mov=zeros(crop_to_pix,crop_to_pix,framestoread, fmttype);
elseif ismember(filetype,[3 4 5 105]),
   mov=zeros([iconside(:); framestoread]', fmttype);
else
   mov=zeros(crop_to_pix,crop_to_pix,framestoread, fmttype);
end

if ismember(filetype,[1 3 4]),
   fmtstr={'uint8','uint8','uint8','double','uint32'};
   
   % load in chunks to save memory
   CHUNKSIZE=500;
   pixsofar=0;
   for ii=1:ceil(framestoread/CHUNKSIZE),
      if ii==ceil(framestoread/CHUNKSIZE),
         f2r=mod(framestoread-1,CHUNKSIZE)+1;
      else
         f2r=CHUNKSIZE;
      end
      [tmov,n]=fread(fid,[prod(iconside) f2r],fmtstr{filetype});
      iirange=(ii-1)*CHUNKSIZE+(1:(n./prod(iconside)));
      if redosize,
         tmov=reshape(tmov,[iconside(:)' f2r]);
         mov(:,:,iirange)=movresize(tmov,final_pix,fmask,croprange,...
                               smallfmt,dosmooth);
      elseif smallfmt,
         tmov=reshape(tmov,[iconside(:)' f2r]); % bug fix 01/18/2007 by sn
         mov(:,:,iirange)=uint8(tmov);  
      %elseif filetype==1,
      %   mov(:,:,iirange)=(double(tmov)/128)-1;
      else
         mov((pixsofar+(1:n))')=tmov(:)';
      end
      pixsofar=pixsofar+n;
   end
elseif ismember(filetype,[2]), % imsm file format
   
   % load in chunks to save memory
   % adapted from above, SVD 5/9/03
   
   CHUNKSIZE=500;
   pixsofar=0;
   iconside=[iconside iconside];
   for ii=1:ceil(framestoread/CHUNKSIZE),
      if ii==ceil(framestoread/CHUNKSIZE),
         f2r=mod(framestoread-1,CHUNKSIZE)+1;
      else
         f2r=CHUNKSIZE;
      end
      
      % load the next CHUNKSIZE (or whatever's left) from disk
      [tmov,n]=fread(fid, [prod(iconside) f2r],'uint8');
      
      % transpose each frame
      tmov=reshape(tmov,[iconside(:)' f2r]);
      tmov=permute(tmov,[2 1 3]);
      iirange=(ii-1)*CHUNKSIZE+(1:(n./prod(iconside)));
      
      if redosize,
         
         % mask and scale the current chunk, then save to mov matrix
         tmov=double(tmov);
         mov(:,:,iirange)=movresize(tmov,final_pix,fmask,croprange,...
                               smallfmt,dosmooth);
      elseif smallfmt,
         
         % just save the byte-sized data
         mov(:,:,iirange)=tmov;  
      else
         
         % output is double; file was uint8. so we need to convert
         % for output to mov
         mov((pixsofar+(1:n))')=double(tmov(:)');
      end
      pixsofar=pixsofar+n;
   end
   
else
   %
   % old imsm/im formats.
   % load and process each frame from the .im file, one at a time
   for ii=1:framestoread,
      if filetype == 0,  % im file format
         [nextframe, fcount] = fread(fid, [iconside,iconside], 'uint32');
         if fcount~=iconsize,
            disp('full frame not read!');
         end
         
         r = bitand(nextframe, 255);
         g = bitand(bitshift(nextframe,-8), 255);
         b = bitand(bitshift(nextframe,-16), 255);
         
         % deal with border regions?  check out DeFlag() in LoadinMov.m    
         %    v = ((r * 0.3086) + (g * 0.6094) + (b * 0.082)) .* (fmask==1) + ...
         %        (-999.99) .* (fmask==0);
         
         % convert from RGB to grayscale
         v = round((r .* 0.3086) + (g .* 0.6094) + (b .* 0.082));
         
         % clean up:    any pixels > 255 set to 255, < 0 set to 0
         good_mask = (v > 0) & (v <= 255);
         good_temp = v .* good_mask;
         
         high_mask = v > 255;
         high_temp = high_mask * 255;
         
         % note use of transpose!  this is to match bill's LoadInMov.m routine!
         vout = uint8(good_temp + high_temp)';
      
      elseif filetype>=101 & filetype<=104, % complex phase format
         [nextframe, fcount] = fread(fid, [iconside,iconside], 'double');
         if fcount~=iconsize,
            disp('full frame not read!');
            keyboard
         end
         %	nextframe=double(nextframe);
         %        nextframe
         %	pause
         
         % no transpose here! it's already been done!
         vout = nextframe;
         if filetype==102 | filetype==104,
            vout=vout*i;
         end
         if filetype==103 | filetype==104,
            vout=-vout;
         end
         
      elseif filetype==105,
         %keyboard
         [nextframe,fcount]=fread(fid,prod(iconside),'double');
         %if fcount<prod(iconside),
         %   keyboard
         %end
         mov(:,:,:,ii)=reshape(nextframe,iconside');
         
      end
      
      if filetype~=105,
         if redosize,
            mov(:,:,ii)=movresize(vout,final_pix,fmask,croprange,...
                                  smallfmt,dosmooth);
         elseif smallfmt,
            mov(:,:,ii)=uint8(vout);  
         else
            mov(:,:,ii)=double(vout);
            %mov(:,:,ii)=(double(vout)/128)-1;
         end
      end
   end
end


