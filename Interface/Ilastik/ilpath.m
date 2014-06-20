function [ipath, varargout] = ilpath(hintpath)
%
% [ipath, ilrun] = ilpath(hintpath)
%
% description:
%    tries to locate Ilastik using an optional hint to a path
%
% input:
%    hintpath  (optional) path to Ilastik ([] = autodetection)
%
% output:
%    ipath       path to valid Ilastik
%    ilrun       (optional) run script
%
% See also: ilinitialize

found = 0;

% use hint
if nargin == 1
   [ipath, ilrun] = findil(hintpath);
   if ~isempty(ipath)
      found = 1;
   end
end

%edjucated guessing
if ~found
   if ismac()
      rpath = '/Applications/';
      hintpath = dir('/Applications/ilastic*');
      hintpath = hintpath([hintpath.isdir]);
   elseif isunix()
      rpath = '/usr/local/';
      hintpath = dir('/usr/local/ilastik*');
      hintpath = hintpath([hintpath.isdir]);
   elseif ispc()
      rapth = 'C:\Program Files\';
      hintpath = 'C:\Program Files\ilastik*';
   else
      error('ilpath: operating system not supported, modify ilpath.m!');
   end
   
   if ~isempty(hintpath)
      [ipath, ilrun] = findil([rpath, hintpath(1).name]);
      if ~isempty(ipath)
         found = 1;
      end
   end
end

%edjucated guessing 2
if ~found && isunix() && ~ismac()
   hintpath = dir('~/programs/ilasti*');
  
   if ~isempty(hintpath)
      [ipath, ilrun] = findil(['~/programs/' hintpath(1).name]);
      if ~isempty(ipath)
         found = 1;
      end
   end
end

if ~found
    error('ilpath: cannot find Ilastik installation, try passing a valid path')
end

if nargout > 1
   varargout{1} = ilrun;
end

end




%check if the path is a valid main Ilastik path based existence of ./ilastik/ilastikMain.py
function ilrun = checkpath(ilpath)
 
   ilrun = [];
   if ~isdir(ilpath)
      return
   end

   if ~isdir(fullfile(ilpath, 'ilastik'))
      return
   end
   
   if ~isfile(fullfile(ilpath, 'ilastik', 'ilastikMain.py'))
      return
   end
   
   ilrun = dir(fullfile(ilpath, 'run*'));
   ilrun = ilrun(~[ilrun.isdir]);
   if isempty(ilrun)
      ilrun = [];
      return
   else
      ilrun = ilrun(1).name;
   end

end



% find imagej in ipath
function [rpath, ilrun] = findil(ipath)  

   rpath = [];

   if ~isdir(ipath)
      ipath = fileparts(ipath);
   end
        
   ilrun = checkpath(ipath);
   if ~isempty(ilrun)
      rpath = absolutepath(ipath);
      return;
   end
   
   % get absolute path and check all directories below
   ipath = absolutepath(ipath);

   ipathcomp = strsplit(ipath, filesep);
   for l = length(ipathcomp):-1:1
      ipath = fullfile(ipathcomp{1:l});
      ilrun = checkpath(ipath);
      if ~isempty(ilrun)
         rpath = absolutepath(ipath);
         return;
      end
   end

end