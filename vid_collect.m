function vid_collect(filename, Video, Nsec)


if nargin < 1 || isempty(filename)
    error('Need filename.');
end

if nargin < 2 || isempty(Video)
    logentry('No Camera configured. Configuring for Grasshopper3');
    Video = vid_config('Grasshopper3'); % [ms]
end

if nargin < 3 || isempty(Nsec)
    Nsec = 10; % [ms]
end


abstime{1,1} = [];
framenumber{1,1} = [];
TotalFrames = 0;


Fps = 1 / (Video.ExposureTime/1000);
NFrames = ceil(Fps * Nsec);

[cam, src] = flir_camera_open(Video);

triggerconfig(cam, 'manual');
cam.FramesPerTrigger = NFrames;

imagetype = ['uint', num2str(Video.Depth)];

filename = [filename, '_', num2str(Video.Width), 'x', ...
                           num2str(Video.Height), 'x', ...
                           num2str(NFrames), '_' imagetype];

f = figure; %('Visible', 'off');
pImage = imshow(uint16(zeros(Video.Height, Video.Width)));


axis image
setappdata(pImage, 'UpdatePreviewWindowFcn', @vid_view)
p = preview(cam, pImage);
set(p, 'CDataMapping', 'scaled');


% ----------------
% Controlling the Hardware and running the experiment
%

pause(2);
logentry('Starting video...');
start(cam);
pause(2);

NFramesAvailable = 0;

binfilename = [filename,'.bin'];
if ~isempty(dir(binfilename))
    delete(cam);
    clear cam
    close(f)
    error('That file already exists. Change the filename and try again.');
end
fid = fopen(binfilename, 'w');


logentry('Triggering video collection...');
cnt = 0;
trigger(cam);

% start timer for video timestamps
t1=tic; 

% Check and store the motor position every 100 ms until it reaches zero. 
pause(4/Fps);
NFramesTaken = 0;
% while(cam.FramesAvailable > 0)
while(NFramesTaken < NFrames)
    cnt = cnt + 1;
    
    
    NFramesAvailable(cnt,1) = cam.FramesAvailable;
    NFramesTaken = NFramesTaken + NFramesAvailable(cnt,1);
%     disp(['Num Grabbed Frames: ' num2str(NFramesAvailable(cnt,1)) '/' num2str(NFramesTaken)]);

    [data, ~, meta] = getdata(cam, NFramesAvailable(cnt,1));    
    
    if isempty(data)
        continue
    end
    
    abstime{cnt,1} = vertcat(meta(:).AbsTime);
    framenumber{cnt,1} = meta(:).FrameNumber;

%     [rows, cols, rgb, frames] = size(data);
% 
%     numdata = double(squeeze(data));
% 
%     squashedstack = reshape(numdata,[],frames);
%     meanval{cnt,1} = transpose(mean(squashedstack));
%     stdval{cnt,1}  = transpose(std(squashedstack));
%     maxval{cnt,1}  = transpose(max(squashedstack));
%     minval{cnt,1}  = transpose(min(squashedstack));
    
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
stop(cam);
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


delete(cam);
clear cam

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
     headertext = [logtimetext 'vid_collect: '];
     
     fprintf('%s%s\n', headertext, txt);
     
     return