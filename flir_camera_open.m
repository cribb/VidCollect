function [cam, src] = flir_camera_open(Video)

    % Camera Setup
    imaqmex('feature', '-previewFullBitDepth', true);
    cam = videoinput('pointgrey', Video.CameraNumber, Video.Format);
    cam.ReturnedColorspace = 'grayscale';

    src = getselectedsource(cam); 
    src.ExposureMode = Video.ExposureMode; 
    src.FrameRateMode = Video.FrameRateMode;
    src.ShutterMode = Video.ShutterMode;
    src.Gain = Video.Gain;
    src.Gamma = Video.Gamma;
    src.Brightness = Video.Brightness;
    src.Shutter = Video.ExposureTime;   % Camera, exposure time [ms]

return