function varargout = vid_impreview(hwhandle, viewOps, callback_function)
% VID_IMPREVIEW UI for previewing the microscope's camera image.
%
    [~, ComputerName] = system('hostname');
    ComputerName = strtrim(ComputerName);
    
    switch upper(ComputerName)
        case 'HILLVIDEOCOMP'
            CameraName = 'Flea3';
            CameraFormat = 'F7_Mono8_1280x1024_Mode0';
            viewOps.exptime = 8; % [ms]
        case 'ZINC'
            CameraName = 'Grasshopper3';
            CameraFormat = '';
            viewOps.exptime = 16;
    end
    
    
    Video = flir_config_video(CameraName, CameraFormat, viewOps.exptime);
    [cam, src] = flir_camera_open(Video);
    
    pause(0.1);
    
    vidRes = cam.VideoResolution;
    imageRes = fliplr(vidRes);   
    
    f = figure('Visible', 'off', ...
               'Units', 'normalized', ...
               'Toolbar','none', ...
               'Menubar', 'none', ...
               'NumberTitle','Off', ...
               'Name','vid_impreview');
    f.Position = [0.02, 0.075, 0.4286, 0.8731];
%     f.Resize = 'off';
    
    % Position: [from left, from bottom, width, height]    
    ax1 = axes(f, 'Units', 'normalized', ...
                  'Position', [0, 0.25, 1, 0.8]); 
    
    switch Video.Depth
        case 8
            hImage = imshow(uint8(zeros(imageRes)));
        case 16
            hImage = imshow(uint16(zeros(imageRes)));
    end
    
    ax1.Tag = 'Live Image';        

    axis image
    
   
    ax2 = axes(f, 'Tag', 'Image Histogram', ...
                  'Units', 'normalized', ...
                  'Position', [0.3, 0.05, 0.68, 0.2]); 
    
    
    txt_exptime = uicontrol(f, 'Units', 'pixels', ...
                               'Position', [5 27 100 20], ...
                               'Style', 'text', ...
                               'HorizontalAlignment', 'left', ...
                               'String', 'Exposure time [ms]:');
        
    edit_exptime = uicontrol(f, 'Units', 'pixels', ...
                                'Position', [105 30 35 20], ...
                                'Style', 'edit', ...
                                'String', num2str(src.Shutter), ...
                                'Callback', @change_exptime);

    btn_grabframe = uicontrol(f, 'Units', 'pixels', ...
                                 'Position', [5 5 40 20], ...
                                 'Style', 'pushbutton', ...
                                 'String', 'Grab', ...
                                 'Callback', @grab_frame);

    edit_framename = uicontrol(f, 'Units', 'pixels', ...
                                  'Position', [48 5 93 20], ...
                                  'Style', 'edit', ...
                                  'String', 'filename', ...
                                  'Callback', @change_framefilename);
                            
    
    setappdata(hImage, 'UpdatePreviewWindowFcn', callback_function);
    setappdata(hImage, 'hwhandle', hwhandle);
    setappdata(hImage, 'viewOps', viewOps);
    h = preview(cam, hImage);

    set(h, 'CDataMapping', 'scaled');
    
   if nargout > 0
       varargout{1} = f;
   end
   
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
