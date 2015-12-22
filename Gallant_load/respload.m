% function r=respload(respfile,[respvarname],[respfiletype],[setnan=0],[psthonly=0])
%
% respfiletype - 0 matlab, 1 ascii
% setnan - set -1's to Nan. (default=0);
% psthonly - return only first column of response (not individual
%            trials... only average across trials). (default=0)
%
% modified SVD 9/21/04 - respfiles can be concatenated by a "+" in
%   which case each one is loaded and returned together as a single
%   raster. for psthonly, the rasters are averaged into a single psth
%
function r=respload(respfile,respvarname,respfiletype,setnan,psthonly);

if ~exist('respvarname','var'),
   respvarname='';
end
if not(exist('respfiletype','var')) | respfiletype==-1,
   if findstr(respfile,'mat'),
      respfiletype=0;
   else
      respfiletype=1;
   end
elseif strcmp(respfile(end-3:end),'.mat'),
   respfiletype=0;
end
if ~exist('setnan','var'),
   setnan=0;
end
if ~exist('psthonly','var'),
   psthonly=0;
end

%
% special case: multiple respfiles connected by "+", call respload
% recursively for each individual file and concatenate the rasters
%
sepfiles=strsep(respfile,'+');
if length(sepfiles)>1,
   for rridx=1:length(sepfiles),
      tr=respload(sepfiles{rridx},respvarname,respfiletype,setnan,0);
      if rridx==1,
         r=tr;
      else
         trlen=size(tr,1);
         rlen=size(r,1);
         if setnan,
            scf=nan;
         else
            scf=-1;
         end
         if trlen>rlen,
            r=[ [ r; ones(trlen-rlen,size(r,2)).*scf ] tr];
         else
            r=[ r [tr ; ones(rlen-trlen,size(tr,2)).*scf ] ];
         end
      end
   end
   if psthonly,
      r=nanmean(r')';
   end
   return
end

%
% deal with all the weird compatibility issues for different types
% of data.
%
if respfiletype==0,
   filetypestr='-MAT';
else
   filetypestr='-ASCII';
end

n0=length(respfile);
while not(strcmp(respfile(n0),'/')) & n0 > 1,
   n0=n0-1;
end
if n0>1,
   n0=n0+1;
end

n=n0;
while not(strcmp(respfile(n),'.')) & n < length(respfile),
   n=n+1;
end

path=respfile(1:n0-1);
if isempty(respvarname),
   respvarname=respfile(n0:n-1);
end
respfilename=respfile(n0:length(respfile));

%fprintf('Loading response file %s...\n',respfilename);

r=load(respfile,filetypestr);

if respfiletype==0,
   if isfield(r,respvarname),
      r=getfield(r,respvarname);
   elseif ~psthonly & isfield(r,'r'),
      r=getfield(r,'r');
   elseif isfield(r,'psth'),
      r=getfield(r,'psth');
   end
end

%
% DO EYE POS STUFF HERE
% 


rlen=size(r,1);
if respfiletype==0 & psthonly, % ie, mat file
   if size(r,2)>1,
      r=nanmean(r')';
   end
   rcount=1;
elseif respfiletype==0,
   rcount=size(r,2);
else
   rcount=size(r,2)-3;
   if rcount > 0,
      % remove first two columns of r (indexes):
      r=r(:,3:size(r,2));
   elseif rcount==-3,
      rcount=0;
      r=[];
   else
      rcount=1;
      r=r(:,size(r,2));
   end
end

if rcount>0 & psthonly,
   rcount=1;
   r=r(:,1);
end

if setnan,
   r(find(r==-1))=nan;
end


%fprintf('rlen=%d  rcount=%d\n',rlen,rcount);


return

HPF=1;

if HPF & size(r,1)>100,
   xx=(1:size(r,1))-round(size(r,1)/2);
   pfilt=exp(-xx.^2/(2*30.^2));
   pfilt=pfilt./sum(pfilt);
   hfilt=1./fft(pfilt);
end



