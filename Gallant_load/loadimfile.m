% function mov = loadimfile(sImFile,startframe,endframe,scale_to_pix,
%                           mask_to_pix,crop_to_pix,smallfmt,dosmooth)
%
% movie is X x T in size. X is the total number of spatial
% channels. imfile header contains info on how X breaks down into
% different spatial dimentions. the number of dimensions can vary.
%
% sImFile - file name of imsm file
% startframe - first frame to load. default=1.
% endframe - last frame to load. default=end. (also end if endframe<startframe)
% scale_to_pix - special to movies where space is X x X (2D
%                square). rescale each frame to scale_to_pix x
%                scale_to_pix after loading. default=original pix size.
% mask_to_pix - apply a circular mask of diameter mask_to_pix in
%               scale_to_pix dimension. zero means no mask (default)
% crop_to_pix - square crop after scaling and masking. default is scale_to_pix.
% smallfmt - return uint8 (1) or double (0) (default=0)
% dosmooth - filter against aliasing before rescaling (default=0)
%
% created SVD 3/02 (hacked from readimfile)
%
function mov = loadimfile(sImFile,startframe,endframe,scale_to_pix,mask_to_pix,crop_to_pix,smallfmt,dosmooth)

[fid, framecount, iconsize, iconside, filetype,altname] = openimfile(sImFile);
if filetype==-1,
   disp(sprintf('readimfile.m:  ERROR could not open %s',sImFile));
   mov=[];
   return;
end
if ~exist('startframe','var') | startframe <= 0,
   startframe=1;
end
if ~exist('endframe','var') | endframe <= 0,
   endframe=framecount;
end
if ~exist('scale_to_pix','var'),
   scale_to_pix=0;
end
if ~exist('mask_to_pix','var'),
   mask_to_pix=0;
end
if mask_to_pix>scale_to_pix,
   mask_to_pix=0;  % this is just to keep naming of pre-processed
                   % files from being redundant
end
if ~exist('crop_to_pix','var'),
   crop_to_pix=0;
end
if not(exist('smallfmt','var')),
   smallfmt=0;
end
if ~exist('dosmooth','var'),
   dosmooth=1;
end

if scale_to_pix==0,
   scale_to_pix=iconside(1);
end

%
% figure out if this imsm file has been loaded with these
% parameters before.
%
precompfile=sprintf('%s.%d.%d.%d.%d.%d',sImFile,scale_to_pix,...
                    mask_to_pix,crop_to_pix,smallfmt,dosmooth);
FASTLOAD=0;

if exist(precompfile,'file') & scale_to_pix<iconside,
   FASTLOAD=1;
   sImFile=precompfile;
   fclose(fid);
   [fid,framecount,iconsize,iconside,filetype,altname]=openimfile(sImFile);
   scale_to_pix=iconside(1);
elseif scale_to_pix<iconside,  % ie, hasn't been pre-shrunk but want to do it
   w=unix(['touch ',precompfile]);
   if ~w,
      w=unix(['\rm ',precompfile]); % delete to avoid collisions
      FASTLOAD=2;
      sf0=startframe;
      if framecount<endframe,
         ef0=framecount;
      else
         ef0=endframe;
      end
      startframe=1;
      endframe=framecount;
   end
end
if crop_to_pix==0,
   crop_to_pix=scale_to_pix;
end

fmtstr={'uint8','uint8','uint8','double','uint32'};
pixsize=[1 1 1 8 4];
%keyboard
if filetype==0,
   ps=1;
elseif filetype < 5,
   ps=pixsize(filetype);
else
   ps=1;
end
if startframe > 1 & startframe <= framecount,
   fseek(fid,iconsize*(startframe-1)*ps,0);
   if endframe >= startframe & endframe < framecount,
      framecountout = endframe-startframe+1;
   else
      framecountout = framecount-startframe+1;
   end
else
   if endframe > 0 & endframe < framecount,
      framecountout = endframe;
   else
      framecountout= framecount;
   end
end

fprintf('Reading movie file %s (frames %d-%d)...\n',...
        sImFile,startframe,endframe);
if crop_to_pix<iconside | scale_to_pix<iconside,
   [fmask,croprange]=movfmask(iconside(1),mask_to_pix/scale_to_pix, ...
			      crop_to_pix*iconside(1)./ ...
                              scale_to_pix);
   mov=readfromimfile(fid,framecountout,iconside,filetype,...
                      crop_to_pix,fmask,croprange,smallfmt,dosmooth);
else
   mov=readfromimfile(fid,framecountout,iconside,filetype,...
                      [],[],[],smallfmt,dosmooth);
end

fclose(fid);

msize=size(mov);
if msize(1)==1 & msize(2)>1,
   mov=mov(:);
end

if FASTLOAD==2,
   %fprintf('saving pre-comp stim: %s\n',precompfile);
   writeimfile(mov,precompfile,4);  % since its been resized, want
                                    % to preserve more than a byte
   if length(msize)==3,
      mov=mov(:,:,sf0:ef0);
   else
      mov=mov(:,sf0:ef0);
   end
end

