function vid_livehist(obj,event,hImage)
% BA_LIVEHIST is a callback function for ba_impreview.
%

persistent q

% Display the current image frame.
im = event.Data;
hImage.CData = im;

zhand = hImage.UserData{1};
focusTF = hImage.UserData{2};

% Pull out min and max pixel intensities so we can scale the preview image
image_ax = ancestor(hImage, 'axes');
cmin = min(double(hImage.CData(:)));
cmax = max(double(hImage.CData(:)));

% Handle the case when the camera image is totally washed out (zero diff
% between pixel intensities makes the range zero).
if cmin == cmax
    cmin = cmax-1;
end

% Set configuration for histogram plot
switch class(im)
    case 'uint8'
        histRange = [0 260];
        Nbins = 128;
    case 'uint16'        
        histRange = [0 66000];
        Nbins = 32768;
end

% Select the second subplot on the figure for the histogram.
hist_ax = subplot(2,1,2);
set(hist_ax, 'Units', 'normalized');
set(hist_ax, 'Position', [0.28, 0.05, 0.4, 0.17]);


D = double(im(:));
avgD = num2str(round(mean(D)), '%u');
stdD = num2str(round(std(D)), '%u');
maxD = num2str(num2str(max(D)), '%u');
minD = num2str(num2str(min(D)), '%u');

% assignin('base', 'focus_measure', q);

% disp(['event.data.class = ' class(event.Data)]);

% Plot the histogram. Choose less bins for faster update of the display.
xlim(histRange);        
imhist(event.Data, Nbins);
set(gca,'YScale','log')
set(image_ax, 'CLim', [uint16(cmin) uint16(cmax)]);

image_str = [avgD, ' \pm ', stdD, ' [', minD ', ', maxD, ']'];

if focusTF
    focus_score = fmeasure(im, 'GDER');
    % q = [q focus_score];
    focus_str = [', focus score= ', num2str(focus_score)];
else
    focus_str = '';
end

if isa(zhand, 'COM.MGMOTOR_MGMotorCtrl_1')
    zpos_str = [', z = ' num2str(ba_getz(zhand)) ' [mm]'];
else 
    zpos_str = '';
end

title([image_str, focus_str, zpos_str]);

% Refresh the display.
drawnow

return