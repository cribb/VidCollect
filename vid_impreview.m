function vid_impreview(hwhandle, callback_function, focusTF)
% BA_IMPREVIEW UI for previewing the microscope's camera image.
%
    
    Video = flir_config_video('Grasshopper3', 'F7_Raw8_1024x768_Mode2', ExposureTime);
    [vid, src] = flir_camera_open(Video);

    pause(0.1);
    
    imageRes = fliplr(vid.Resolution);   
    
    f = figure('Visible', 'off', 'Units', 'normalized');
    ax = subplot(2, 1, 1);
    set(ax, 'Units', 'normalized');
    set(ax, 'Position', [0.05, 0.4515, .9, 0.53]); 
    
    switch Video.Depth
        case 8
            hImage = imshow(uint8(zeros(imageRes)));
        case 16
            hImage = imshow(uint16(zeros(imageRes)));
    end
    #hImage = imshow(uint16(zeros(imageRes)));
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
    
    
    setappdata(hImage, 'UpdatePreviewWindowFcn', callback_function);
    h = preview(vid, hImage);
    set(h, 'CDataMapping', 'scaled');

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
