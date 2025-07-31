function varargout = vid_impreview(hwhandle, viewOps, callback_function)
% VID_IMPREVIEW UI for previewing the microscope's camera image.
%
    [~, ComputerName] = system('hostname');
    ComputerName = strtrim(ComputerName);

    if ~isfield(viewOps, 'man_cmin'), viewOps.man_cmin = false; end
    if ~isfield(viewOps, 'man_cmax'), viewOps.man_cmax = false; end
    if ~isfield(viewOps, 'ludl_pos'), viewOps.ludl_pos = false; end
    if ~isfield(viewOps, 'cmin'), viewOps.cmin = 0; end
    if ~isfield(viewOps, 'gain'), viewOps.gain = 12; end

    switch upper(ComputerName)
        case 'HILLVIDEOCOMP'
            CameraName = 'Flea3';
            
            if ~isfield(viewOps, 'CameraFormat')
                viewOps.CameraFormat = 'F7_Mono8_1280x1024_Mode0';
            end
            
            if ~isfield(viewOps, 'exptime')
                viewOps.exptime = 8; % [ms]
            end
            
            if ~isfield(viewOps, 'cmax')
                viewOps.cmax = 255; 
            end
            
        case {'ZINC', 'CHROMIUM', 'CERIUM'}
            CameraName = 'Grasshopper3';
            
            if ~isfield(viewOps, 'CameraFormat')
                viewOps.CameraFormat = 'F7_Raw16_1024x768_Mode2';
            end
            
            if ~isfield(viewOps, 'exptime')
                viewOps.exptime = 16; % [ms]
            end
            
            if ~isfield(viewOps, 'cmax')
                viewOps.cmax = 65535;
            end
    end
    
    
    Video = flir_config_video(CameraName, viewOps.CameraFormat, viewOps.exptime);
    Video.Gain = viewOps.gain;
    
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
    liveimage_ax = axes(f, 'Units', 'normalized', ...
                           'Position', [0, 0.25, 1, 0.8]);
%                        , ...
%                            'ButtonDownFcn','disp(''axis callback'')', ...
%                            'BusyAction', 'cancel'); 
    
    man_cmin = viewOps.man_cmin;
    man_cmax = viewOps.man_cmax;

    cmin = viewOps.cmin;
    switch Video.Depth
        case 8
            hImage = imshow(uint8(zeros(imageRes)));
            cmax = viewOps.cmax;
        case 16
            hImage = imshow(uint16(zeros(imageRes)));
            cmax = viewOps.cmax;
    end
    if cmax > 2^Video.Depth-1
        cmax = 2^Video.Depth-1;
    end
    if cmin > cmax || cmin < 0
        cmin = 0;
    end
    
    liveimage_ax.Tag = 'Live Image';        

    axis image
    
   
    ax2 = axes(f, 'Tag', 'Image Histogram', ...
                  'Units', 'normalized', ...
                  'Position', [0.3, 0.05, 0.68, 0.2]); 

    chk_cmin   = uicontrol(f, 'Units', 'pixels', ...
                               'Position', [5 67 100 20], ...
                               'Style', 'checkbox', ...
                               'HorizontalAlignment', 'left', ...
                               'String', 'MIN Intensity:', ...
                               'Value', false, ...
                               'Callback', @toggle_cmin);
                           
    edit_cmin   = uicontrol(f, 'Units', 'pixels', ...
                                'Position', [105 70 35 20], ...
                                'Style', 'edit', ...
                                'String', num2str(cmin), ...
                                'Callback', @change_cmin);
                            
    chk_cmax   = uicontrol(f, 'Units', 'pixels', ...
                               'Position', [5 47 100 20], ...
                               'Style', 'checkbox', ...
                               'HorizontalAlignment', 'left', ...
                               'String', 'MAX Intensity:', ...
                               'Value', false, ...
                               'Callback', @toggle_cmax);
                           
    edit_cmax   = uicontrol(f, 'Units', 'pixels', ...
                                'Position', [105 50 35 20], ...
                                'Style', 'edit', ...
                                'String', num2str(cmax), ...
                                'Callback', @change_cmax);
                               
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
                            
    ghandles.preview = liveimage_ax;
    ghandles.histogram = ax2;
    
    setappdata(hImage, 'UpdatePreviewWindowFcn', callback_function);
    setappdata(hImage, 'hwhandle', hwhandle);
    setappdata(hImage, 'ghandles', ghandles);
    setappdata(hImage, 'viewOps', viewOps);
    setappdata(hImage, 'cmin', cmin);
    setappdata(hImage, 'cmax', cmax);
    setappdata(hImage, 'man_cmin', man_cmin);
    setappdata(hImage, 'man_cmax', man_cmax);
    
    h = preview(cam, hImage);

%     set(h, 'CDataMapping', 'scaled');
    
   if nargout > 0
       varargout{1} = f;
   end
   
    function change_exptime(source,event)
        exptime = str2double(source.String);
        fprintf('New exposure time is: %4.2g\n', exptime);       
        src.Shutter = exptime;       
        edit_exptime.String = num2str(src.Shutter);        
    end

%     function change_framefilename(source,event)
%         
%     end
    
    function grab_frame(source, event) %#ok<*INUSD>
        framename = get(edit_framename, 'String');
        framename = [framename, '.png'];
        imwrite(hImage.CData, framename);
        disp(['Frame grabbed to ' framename]);
    end

    function checkbox_cmin(source, event)
        
    end

    function checkbox_cmax(source, event)
        
    end

    function change_cmin(source, event)
        cmin = str2double(source.String);
        fprintf('New MIN Intensity set to: %4.2g\n', cmin);              
       
        edit_cmin.String = num2str(cmin);
        setappdata(hImage, 'cmin', cmin);
    end

    function change_cmax(source, event)
        cmax = str2double(source.String);
        fprintf('New MAX Intensity set to: %4.2g\n', cmax);              
       
        edit_cmax.String = num2str(cmax);
        setappdata(hImage, 'cmax', cmax);
    end

    function toggle_cmin(source, event)
        man_cmin = false;
        setappdata(hImage, 'man_cmin', false);
    end

    function toggle_cmax(source, event)
        man_cmax = false;
        setappdata(hImage, 'man_cmax', false);
    end



end
