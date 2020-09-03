function ba_livehist(obj,event,hImage)
% BA_LIVEHIST is a callback function for ba_impreview.
%

persistent q

im = event.Data;
% class(im)

% Display the current image frame.
set(hImage, 'CData', im);


zhand = hImage.UserData{1};
focusTF = hImage.UserData{2};



% Select the second subplot on the figure for the histogram.
ax = subplot(2,1,2);
set(ax, 'Units', 'normalized');
set(ax, 'Position', [0.28, 0.05, 0.4, 0.17]);


D = double(im(:));

avgD = round(mean(D));
stdD = round(std(D));
maxD = num2str(max(D));
minD = num2str(min(D));


avgD = num2str(avgD, '%u');
stdD = num2str(stdD, '%u');
maxD = num2str(maxD, '%u');
minD = num2str(minD, '%u');



assignin('base', 'focus_measure', q);

% Plot the histogram. Choose less bins for faster update of the display.
switch class(event.Data)
    case 'uint8'
        xlim([0 260]);        
        imhist(event.Data, 128);
    case 'uint16'        
        imhist(event.Data, 32768);        
        xlim([0 66000]);
end
set(gca,'YScale','log')

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


% Modify the following numbers to reflect the actual limits of the data returned by the camera.
% For example the limit a 16-bit camera would be [0 65535].
a = ancestor(hImage, 'axes');
cmin = min(double(hImage.CData(:)));
cmax = max(double(hImage.CData(:)));
set(a, 'CLim', [uint16(cmin) uint16(cmax)]);

% set(a, 'CLim', [0 65535]);


% Refresh the display.
drawnow

return