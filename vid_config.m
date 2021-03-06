function Video = vid_config(CameraName, CameraFormat, exptime)
% VID_CONFIG configures the camera
%
%{
  List of available formats for the Grasshopper3:
    F7_Mono12_1024x768_Mode1 
    F7_Mono12_1024x768_Mode2 
    F7_Mono12_2048x1536_Mode0
    F7_Mono12_2048x1536_Mode7
    F7_Mono16_1024x768_Mode1 
    F7_Mono16_1024x768_Mode2 
    F7_Mono16_2048x1536_Mode0
    F7_Mono16_2048x1536_Mode7
    F7_Mono8_1024x768_Mode1  
    F7_Mono8_1024x768_Mode2  
    F7_Mono8_2048x1536_Mode0 
    F7_Mono8_2048x1536_Mode7 
    F7_Raw12_1024x768_Mode1  
    F7_Raw12_1024x768_Mode2  
    F7_Raw12_2048x1536_Mode0 
    F7_Raw12_2048x1536_Mode7 
    F7_Raw16_1024x768_Mode1  
    F7_Raw16_1024x768_Mode2  
    F7_Raw16_2048x1536_Mode0 
    F7_Raw16_2048x1536_Mode7 
    F7_Raw8_1024x768_Mode1   
    F7_Raw8_1024x768_Mode2   
    F7_Raw8_2048x1536_Mode0  
    F7_Raw8_2048x1536_Mode7    
%}

if nargin < 1 || isempty(CameraName)
    logentry('Need a CameraName. On Artemis, the default camera is a "Grasshopper3".');
    CameraName = 'Grasshopper3';
end

if nargin < 2 || isempty(CameraFormat)
    logentry('Need a CameraFormat. Setting to default, "F7_Raw16_1024x768_Mode2"');
    CameraFormat = 'F7_Raw16_1024x768_Mode2';
end

if nargin < 3 || isempty(exptime)
    switch CameraName
        case 'Grasshopper3'
            exptime = 8;
        case 'Dragonfly2'
            exptime = 16;  % [ms]
        case 'Flea3'
            exptime = 8;
        otherwise
            error('CameraName is not recognized.');
    end
    
    logentry(['Setting default exposure time of ' num2str(exptime) ' milliseconds.']);
end


info = imaqhwinfo('pointgrey');
mycameras(:,1) = {info.DeviceInfo.DeviceName};
queryCameraNumber = contains(mycameras, CameraName);
if sum(queryCameraNumber)
    myCameraInfo = info.DeviceInfo(queryCameraNumber);
else
    error('CameraName is not recognized. Try "Grasshopper3"');
end

%     CameraNumber = info.DeviceInfo(queryCameraNumber).DeviceID;
myformats(:,1) = myCameraInfo.SupportedFormats;
if ~sum(contains(myformats, CameraFormat))
    CameraFormat = myCameraInfo.DefaultFormat;
    logentry(['CameraFormat not recognized Switching to default, which is: ' CameraFormat '.']);   
end


Video.CameraName = myCameraInfo.DeviceName;
Video.CameraNumber = myCameraInfo.DeviceID;
Video.ExposureMode = 'off';
Video.FrameRateMode = 'off';
Video.ShutterMode = 'manual';
Video.Gain = 12;
Video.Gamma = 1.15;
Video.Brightness = 5.8594;
Video.Format = CameraFormat;
Video.SupportedFormats(:,1)  = myCameraInfo.SupportedFormats;

FormatInfo = flir_extract_vidformat(Video.Format);            
            
Video.ImageType = FormatInfo.ImageType;
Video.Height = FormatInfo.Height;
Video.Width = FormatInfo.Width;
Video.Depth = FormatInfo.Depth;
Video.Mode = FormatInfo.Mode;            
Video.ExposureTime = exptime; % [ms]

return
% 
% function FormatInfo = extract_vidformat(VidFormat)
%     mytokens = regexpi(VidFormat, '(F7_|)(Raw|Mono)(\d*)_(\d+)x(\d+)(_Mode\d*|)', 'tokens');
%     mytokens = mytokens{1};
%     mytokens = cellfun(@(s)strrep(s, '_', ''), mytokens, 'UniformOutput', false);
%     
%     FormatInfo.ImageType = mytokens{2};
%     FormatInfo.Height = str2double(mytokens{5});
%     FormatInfo.Width = str2double(mytokens{4});
%     FormatInfo.Depth = str2double(mytokens{3});
%     FormatInfo.Mode = mytokens{6};        
% return

