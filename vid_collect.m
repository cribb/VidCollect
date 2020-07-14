function vid_collect(filename, exptime, Nsec)
% Prior to starting experiment, make sure the magnet is centered.  Lower
% the magnet to 0 and use the vertical micrometer to ensure the tips of the
% magnet will touch the top of a glass slide (to apply maximum force to
% bead).  Click on the apps tab and open image acquisition.  Use the
% horizontal micrometers to line up the magnet gap with the field of view.
% If done correctly, you will not see the tips of the magnets show up.  You
% may have to adjust the focus and increase the gain to see the gap with
% fluorescence.  Close image acquisition, then run the first two sections
% of this script.  Raise the motor back to 12mm by clicking the height box
% in the gui and typing the desired height.  Carefully place the sample
% under the magnet, making sure the magnet will not contact and edge of the
% chamber when it is lowered.  Close the gui, then reopen image acqusition.
% Find a region that has 20-40 beads.  Beads within a diameter from
% each other or an edge will probably not work well when tracking. Focus the region, then
% close image acquisition again.  Run the script.

if nargin < 1 || isempty(filename)
    error('Need filename.');
end

if nargin < 2 || isempty(exptime)
    exptime = 8; % [ms]
end

if nargin < 3 || isempty(Nsec)
    Nsec = 60; % [ms]
end


abstime{1,1} = [];
framenumber{1,1} = [];
TotalFrames = 0;


Fps = 1 / (exptime/1000);
NFrames = ceil(Fps * Nsec);
% NFrames = 7625;


imaqmex('feature', '-previewFullBitDepth', true);
vid = videoinput('pointgrey', 1,'F7_Raw16_1024x768_Mode2');
vid.ReturnedColorspace = 'grayscale';
triggerconfig(vid, 'manual');
vid.FramesPerTrigger = NFrames;

% Following code found in apps -> image acquisition
% More info here: http://www.mathworks.com/help/imaq/basic-image-acquisition-procedure.html
src = getselectedsource(vid); 
src.ExposureMode = 'off'; 
src.FrameRateMode = 'off';
src.ShutterMode = 'manual';
src.Gain = 10;
src.Gamma = 1.15;
src.Brightness = 5.8594;
src.Shutter = exptime;

vidRes = vid.VideoResolution;
imagetype = 'uint16';

imageRes = fliplr(vidRes);

filename = [filename, '_', num2str(vidRes(1)), 'x', ...
                           num2str(vidRes(2)), 'x', ...
                           num2str(NFrames), '_uint16'];

f = figure;%('Visible', 'off');
pImage = imshow(uint16(zeros(imageRes)));


axis image
setappdata(pImage, 'UpdatePreviewWindowFcn', @vid_view)
p = preview(vid, pImage);
set(p, 'CDataMapping', 'scaled');


% ----------------
% Controlling the Hardware and running the experiment
%

pause(2);
logentry('Starting video...');
start(vid);
pause(2);

NFramesAvailable = 0;

binfilename = [filename,'.bin'];
if ~isempty(dir(binfilename))
    delete(vid);
    clear vid
    close(f)
    error('That file already exists. Change the filename and try again.');
end
fid = fopen(binfilename, 'w');


logentry('Triggering video collection...');
cnt = 0;
trigger(vid);

% start timer for video timestamps
t1=tic; 

% Check and store the motor position every 100 ms until it reaches zero. 
pause(4/Fps);
NFramesTaken = 0;
% while(vid.FramesAvailable > 0)
while(NFramesTaken < NFrames)
    cnt = cnt + 1;
    
    
    NFramesAvailable(cnt,1) = vid.FramesAvailable;
    NFramesTaken = NFramesTaken + NFramesAvailable(cnt,1);
%     disp(['Num Grabbed Frames: ' num2str(NFramesAvailable(cnt,1)) '/' num2str(NFramesTaken)]);

    [data, ~, meta] = getdata(vid, NFramesAvailable(cnt,1));    
    
    if isempty(data)
        continue
    end
    
    abstime{cnt,1} = vertcat(meta(:).AbsTime);
    framenumber{cnt,1} = meta(:).FrameNumber;

    [rows, cols, rgb, frames] = size(data);

    
    if cnt == 1
        firstframe = data(:,:,1);
    end
        
    fwrite(fid, data, imagetype);

    if ~mod(cnt,5)
        drawnow;
    end

end

lastframe = data(:,:,1,end);

elapsed_time = toc(t1);

logentry('Stopping video collection...');
stop(vid);
pause(1);
    
% Close the video .bin file
fclose(fid);

NFramesCollected = sum(NFramesAvailable);
AbsFrameNumber = cumsum([1 ; NFramesAvailable(:)]);
AbsFrameNumber = AbsFrameNumber(1:end-1);

logentry(['Total Frame count: ' num2str(NFramesCollected)]);
logentry(['Total Elapsed time: ' num2str(elapsed_time)]);

Time = cellfun(@datenum, abstime, 'UniformOutput', false);
Time = vertcat(Time{:});

% Max = vertcat(maxval{:});
% Mean = vertcat(meanval{:});
% StDev = vertcat(stdval{:});
% Min = vertcat(minval{:});


delete(vid);
clear vid

close(f);
logentry('Done!');

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
     headertext = [logtimetext 'ba_pulloff: '];
     
     fprintf('%s%s\n', headertext, txt);
     
     return