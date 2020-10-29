function vid_impreview
% BA_IMPREVIEW UI for previewing the microscope's camera image.
%
    
    imaqmex('feature', '-previewFullBitDepth', true);
    
    vid = videoinput('pointgrey', 1, 'F7_Mono8_1280x1024_Mode0');
    
    vid.ReturnedColorspace = 'grayscale';
    
    src = getselectedsource(vid);
    
    src.Brightness = 5.8594;   
    src.ExposureMode = 'off';    
    src.GainMode = 'manual';
    src.Gain       = 15;
    src.GammaMode = 'manual';
    src.Gamma      = 1.15;
    src.FrameRateMode  = 'off';
    src.ShutterMode = 'manual';
    src.Shutter = 8;

    pause(0.1);
    
    vidRes = vid.VideoResolution;
    imageRes = fliplr(vidRes);   
    
    f = figure('Visible', 'off', 'Units', 'normalized');
    ax = subplot(2, 1, 1);
    set(ax, 'Units', 'normalized');
    set(ax, 'Position', [0.05, 0.4515, .9, 0.53]); 
    
    hImage = imshow(uint16(zeros(imageRes)));
    axis image

    edit_exptime = uicontrol(f, 'Position', [20 20 60 20], ...
                                'Style', 'edit', ...
                                'String', num2str(src.Shutter), ...
                                'Callback', @change_exptime);
    edit_framename = uicontrol(f, 'Position', [20 40 120 20], ...
                                'Style', 'edit', ...
                                'String', 'grabframe', ...
                                'Callback', @change_framefilename);
                            
    btn_grabframe = uicontrol(f, 'Position', [20 60 60 20], ...
                                 'Style', 'pushbutton', ...
                                 'String', 'Grab Frame', ...
                                 'Callback', @grab_frame);
%     edit_exptime.Position
%     btn_grabframe.Position
    
    
    setappdata(hImage, 'UpdatePreviewWindowFcn', @vid_livehist);
    h = preview(vid, hImage);
    set(h, 'CDataMapping', 'scaled');
    assignin('base', 'LiveImage', hImage);
    
    function change_exptime(source,event)

        exptime = str2num(source.String);
        fprintf('New exposure time is: %4.2g\n', exptime);
        
        src.Shutter = exptime;
       
        edit_exptime.String = num2str(src.Shutter);
        
    end

    function change_framefilename(source,event)
        
    end
    
    function grab_frame(source, event)
        framename = get(edit_framename, 'String');
        framename = [framename, '.png'];
        imwrite(hImage.CData, framename);
        disp(['Frame grabbed to ' framename]);
    end


end