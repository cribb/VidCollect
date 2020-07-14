function vid_workflow(filemask)
% BA_WORKFLOW analyzes a suite of bead-adhesion videos in the experiment path.
%

% 
%
% Given an experiment directory of bin files, perform automated analysis
% for a bead adhesion experimental protocol run on the Ixion tilting
% microscope in the Superfine lab.
%
% Inputs:
%    exptdir- directory of bin files
% 

if nargin < 1 || isempty(filemask)
    error('No files to work on.');
end

filelist = dir(filemask); 

if isempty(filelist)
    error('This directory does not contain files in filemask.');
end

exptdir = filelist(1).folder;

startdir = pwd;
cd(exptdir);

    
binfilelist = dir('**/*.bin');
    
if ~isempty(binfilelist)
    B = length(binfilelist);
    for b = 1 : B
        binfile = binfilelist(b).name;
        
        logentry('Converting bin file to stack of pgms...')
        ba_bin2stack(binfile, [], true);
        
        logentry('Deleting original bin file...');
        delete(binfile);
    end
else
%     error('No data found.');
end

stackdirlist = dir('**/frame00001.pgm');

S = length(stackdirlist);

% For every file-stack in my experiment directory
for s = 1:S
    
    stackdir = stackdirlist(s).folder;
    
% %     cd(binpath);
    


%     logentry('Loading frame extraction times and motor z-positions');
%     tz = load([stackdir '.meta.mat']);
    
%     logentry('Retrieving first & last frames (used for first locating beads).');
    vid_extract_keyframes(stackdir);
    
%     logentry('Creating mini-video of stack using MP4 format');
    vid_minivideo(stackdir);
    
    logentry('Tracking beads in this stack...');
    vid_trackstack(stackdir);



%     logentry('Finding beads in first and last frames.');
%     ba_discoverbeads(
%     logentry('Compressing stack into smaller zip file.');
%     ba_zipstack(stackdir);
    
%     logentry('Deleting stack...');
%     rmdir(stackdir, 's');
    

    
    % Return to our original experiment directory
    cd(exptdir);
        
end
% rm('*_tmp.*');

cd(startdir);

return

    
% function for writing out stderr log messages
function logentry(txt)
    logtime = clock;
    logtimetext = [ '(' num2str(logtime(1),  '%04i') '.' ...
                   num2str(logtime(2),        '%02i') '.' ...
                   num2str(logtime(3),        '%02i') ', ' ...
                   num2str(logtime(4),        '%02i') ':' ...
                   num2str(logtime(5),        '%02i') ':' ...
                   num2str(floor(logtime(6)), '%02i') ') '];
     headertext = [logtimetext 'ba_workflow: '];
     
     fprintf('%s%s\n', headertext, txt);
     
     return;  