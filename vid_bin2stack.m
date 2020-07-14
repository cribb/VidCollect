function vid_bin2stack(filename, stackpath, statTF, showTF)
% BA_BIN2STACK converts bead-adhesion assay bin files into a stack of PGMs.
%

% Check to see if a filename string was provided.
if nargin < 1 || isempty(filename)
    error('No bin file provided.');
end

% Now, check to see that the provided filename is real. If it is real, then
% extract the path, filename, and path+filename
fntmp = dir(filename);
if ~isempty(fntmp)
    filepath = fntmp.folder;
    filename = fntmp.name;
    absname = fullfile(filepath, filename);
else
    error('File not found. Incorrect filename?');
end

% If no output path has been provided, then create one from the original bin 
% filename minus the extension.
if nargin < 2 || isempty(stackpath)
    stackpath = strrep(absname, '.bin', '');
end

% Display the frames as they're converted? Assume false ('no') as default.
if nargin < 3 || isempty(statTF)
    statTF = false;
end

% Display the frames as they're converted? Assume false ('no') as default.
if nargin < 4 || isempty(showTF)
    showTF = false;
end

% Dissect the filename for the relevant video metadata
mytokens = regexpi(filename, '_(\d+)x(\d+)x(\d+)_uint(\d+).bin', 'tokens');
mytokens = cellfun(@str2num,mytokens{1});
    
width = mytokens(1);
height = mytokens(2);
frames = mytokens(3);
depth = mytokens(4);

expected_filesize_bytes = (width * height * frames * depth) / 8;
expected_framesize_bytes = expected_filesize_bytes / frames;

if expected_filesize_bytes ~= fntmp.bytes
    disp('Expected file size differs from actual file. Attempting to compensate.');

    if mod(fntmp.bytes,width*height*depth/8)
        disp('Expected frame width, height, depth or number of frames is wrong.');
        disp('Assuming partial frame and moving on...');
        frames = floor(fntmp.bytes/expected_framesize_bytes);
    elseif ~mod(fntmp.bytes,expected_framesize_bytes)
        newframes = fntmp.bytes/expected_framesize_bytes;
        disp(['Expected ' num2str(frames) ...
              ' frames, got ' num2str(newframes) ...
              ' frames instead. Setting to new number.']);
        frames = newframes;
    else
        error('Something weird with this file size. Partial frame?');
    end 
end


    if isempty(dir(stackpath))
        mkdir(stackpath);
    end

    fid = fopen(filename, 'r');
    
    startdir = pwd;
    
    cd(stackpath);        

%     if showTF
%         h = figure;
%     end    

    depthtype = ['uint' num2str(depth)];    
    
    if statTF
        [vmax, vmin, vmean, vsd] = deal(NaN(frames,1));
    end
    
%     for k = 1:10
%     for k = 1:100
    for k = 1:frames

        myframe = fread(fid, width*height, ['*' depthtype]);
        framename = ['frame' num2str(k,'%05u') '.pgm'];
        myframe = reshape(myframe, height, width);

%         if showTF
%             figure(h);
%             imagesc(myframe); 
%             colormap(gray);
%             drawnow;
%         end
        

        
        if statTF
            tmpframe  = double(myframe(:));
            vmax(k)  = max(tmpframe);
            vmin(k)  = min(tmpframe);
            vmean(k) = mean(tmpframe);
            vsd(k)   = std(tmpframe);
        end
        
        imwrite(myframe, framename);
        

        if ~mod(k,200)
            disp([num2str(k), ' of ', num2str(frames), ' done.']);            
        end
    end
    
    fclose(fid);
    cd(startdir);
    
    if statTF
        VidStats = table([1:frames]', vmax, vmin, vmean, vsd);
        VidStats.Properties.VariableNames = {'Frame', 'Max', 'Mean', 'StDev', 'Min'};
        save([filename(1:end-4), '.vidstats.mat'], 'VidStats');
    end
    

%     outs = {width, height, frames, depth};
return
