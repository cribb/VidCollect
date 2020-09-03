# Using VidCollect (Last Updated 7/27/2020)

## A Note on the Hardware

This project is set to work on the Adhession Assay setup, which is currently a Grasshopper3 camera connected to the 2nd optical path
of a TE-2000E Nikon microscope. Any changes to the hardware may result in a need to change the optical path and/or microscope type 
within the code.

## Using `vid_app`

### Getting Started

To run `vid_app`, simply double click `vid_app.mlapp` in the File Explorer. This will open up the Matlab console, along with two 
additional windows below:

# TODO: PUT PICS HERE!!

The window to the left is a control panel and the window to the right is the preview window.

The control panel interface is composed of two main sections: General and Parameters. Both of these functions are accessible by 
separate tabs.

The General section is composed of the following:

- File Name - the desired filename of the output .bin file
- Duration (s) - the desired length of the video, in units of seconds
- Video Capture In Progress - turns on to indicate that the camera is in the process of taking a video
- Start - start the video capture process, automatically stops recording after the amount of time indicated by Duration (s) has
elapsed
- Abort - aborts the video capture process before the amount of time indicated by Duration (s) has elapsed

The Parameters section is composed of camera parameters, the default values of which are taken from `vid_config.m`. They are as follows:

- Exposure Mode
- Frame Rate Mode
- Shutter Mode
- Gain
- Gamma
- Brightness
- Exposure Time - corresponds to the Shutter property of the camera

The preview window displays the current view of the camera. Closing this window does not affect the functionality of the program.
It should also be noted that the video feed of the preview window stops when the video recording starts.

When you open up the app, a message of "Ready to begin video capture" will appear in the console.

### Recording a Video

To record a video, first ensure the preview window is displaying the view of the location you want to record. Then, type what you'd like
the output file .bin file to be named in the "File Name" field and the desired length of the video in the "Duration (s)" field. Make sure the file name isn't the same as anything in your working directory
or the program will throw an error!

It should be noted that if you forget to input anything in the "File Name" field, the program will still run, but will save the output file
as ".bin" instead.

Click the start button to start the video capture process. When you do so, the "Video Capture In Progress" light should turn on and the message 
"Beginning video capture..." will appear in the console. The video capture should then stop automatically after the desired amount of time. At this point
the "Video Capture In Progress" light should turn off and the message "Video capture complete" should appear in the console.

If you want to stop the video capture process at any time, click the Abort button. If the program is successfully aborted this way, the "Video Capture
in Progress" light should turn off and the message "Video capture aborted" should appear in the console.

Regardless of whether the video capture is aborted or not, after the video capture process is stopped, the app is immediately ready to begin recording another video
once the Start button is pressed.

### Changing Parameters

To change the default video parameters within the app, you can do so in the Parameters tab. Simply change the desired fields, then click the "Update Parameters" button
when you are finished to apply the changes. The preview window, if open, should close and a new preview window will open. A message of "Video capture parameters have been 
successfully updated" should appear in the console.

If you want to change the default values themselves, you will have to do so manually through editing the file `vid_config.m`.

### Closing the App

To close the preview and app windows at once, click the "Close Application" button on the control panel.