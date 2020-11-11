function vid_livehist(obj,event,hImage)
% BA_LIVEHIST is a callback function for ba_impreview.
%

% persistent ax1

% class(im)

% Display the current image frame.
h = ancestor(hImage, 'figure');
im = event.Data;

hImage.CData = im;
% zhand = hImage.UserData{1};
% focusTF = hImage.UserData{2};

zhand = '';
focusTF = '';

% Pull out min and max pixel intensities so we can scale the preview image
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

ax1 = ancestor(hImage, 'axes');
% ax1.Units = 'normalized';
% ax1.Position = [0.01, 0.45, 1, 0.6];


% Select the second subplot on the figure for the histogram.
f = ancestor(ax1, 'figure');
ax2 = f.Children(end-1);
% ax2.Units = 'normalized';
% ax2.Position = [0.3, 0.05, 0.68, 0.2];


D = double(im(:));

avgD = round(mean(D));
stdD = round(std(D));
maxD = num2str(max(D));
minD = num2str(min(D));


avgD = num2str(avgD, '%u');
stdD = num2str(stdD, '%u');
maxD = num2str(maxD, '%u');
minD = num2str(minD, '%u');


% assignin('base', 'focus_measure', q);

% disp(['event.data.class = ' class(event.Data)]);

% Plot the histogram. Choose less bins for faster update of the display.
% axes(ax2);
% xlim(histRange);        
% imhist(im, Nbins);
histogram(ax2, im(:), Nbins, 'DisplayStyle', 'stairs');
ax2.YScale = 'log';

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



set(ax1, 'CLim', [uint16(cmin) uint16(cmax)]);

% set(a, 'CLim', [0 65535]);


% Refresh the display.
drawnow

return