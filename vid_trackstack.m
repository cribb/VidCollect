function vid_trackstack(stackdir, destination_folder, outfile, cfgfiles)
% BA_TRACKSTACK wraps Video Spot Tracker in the bead adhesion assay workflow.
%

if nargin < 1 || isempty(stackdir)
    error('No Stack folder defined.');
end

sftmp = dir(stackdir);

if ~isempty(sftmp)
    stackdir = sftmp.folder;
else
    error('Stack not found. Incorrect filename?');
end

slashpos = regexp(stackdir, filesep);

if nargin < 2 || isempty(destination_folder)
    destination_folder = stackdir(1:slashpos(end)-1);
end

dftmp = dir(destination_folder);

if ~isempty(dftmp)
    destination_folder = dftmp.folder;
else
    error('Destination folder not found. Incorrect filename?');
end

if nargin < 3 || isempty(outfile)
    outfile = stackdir;
end

if nargin < 4 || isempty(cfgfiles)
    cfgfiles.find = which('optimize_1um_find.cfg');
    cfgfiles.track = which('optimize_1um_track.cfg');
end

startpath = pwd;
firstframename = 'frame00001.pgm';

[~,findcfg,fext] = fileparts(cfgfiles.find);
[~,trackcfg,text] = fileparts(cfgfiles.track);

findcfg = [findcfg, fext];
trackcfg = [trackcfg, text];

configFind = [destination_folder filesep findcfg];
configTrack = [destination_folder filesep trackcfg];

if ~strcmp(cfgfiles.find, configFind)
    [successF, msga, msgIDa] = copyfile(cfgfiles.find, configFind ); %#ok<ASGLU>
else
    successF = true;
end

if ~strcmp(cfgfiles.track, configTrack)
    [successT, msgb, msgIDb] = copyfile(cfgfiles.track, configTrack ); %#ok<ASGLU>
else
    successT = true;
end

if ~successF || ~successT
    error('One or more tracking configuration files not copied.');
end

firstframe = fullfile(stackdir, firstframename);
findframefilename =  fullfile(stackdir, 'findframe.pgm');

% copy first frame into a new filename so initialize bead positions
[successFF,~,~] = copyfile(firstframe, findframefilename);
        
if ~successFF
    error('First frame not copied.');
end

logfile = outfile;
findlog = [logfile '_tmp'];

vc = vst_config_init; 
vst_check_config(vc);
vst_run_from_matlab(findframefilename, findlog, configFind, vc);

vc.continue_from = [findlog '.csv'];
vst_run_from_matlab(firstframe, logfile, configTrack, vc);

% delete(findframefilename);
% delete([findlog '.vrpn']);
% 
% % Delete the vrpn files (we want to keep the csv files, though)
% delete([logfile '.vrpn']);
% delete([findlog '.csv']);
% 
% delete(configFind);
% delete(configTrack);

return

