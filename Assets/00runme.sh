#!/bin/bash

cp icon.png icon-0016.png
cp icon.png icon-0032.png
cp icon.png icon-0064.png
cp icon.png icon-0128.png
cp icon.png icon-0256.png
cp icon.png icon-0512.png
cp icon.png icon-1024.png

sips -Z 16 icon-0016.png
sips -Z 32 icon-0032.png
sips -Z 64 icon-0064.png
sips -Z 128 icon-0128.png
sips -Z 256 icon-0256.png
sips -Z 512 icon-0512.png
sips -Z 1024 icon-1024.png

cp camera.png camera-1x.png
cp camera.png camera-2x.png
cp camera.png camera-3x.png
sips -Z 64 camera-1x.png
sips -Z 128 camera-2x.png
sips -Z 192 camera-3x.png

cp settings.png settings-1x.png
cp settings.png settings-2x.png
cp settings.png settings-3x.png
sips -Z 32 settings-1x.png
sips -Z 64 settings-2x.png
sips -Z 96 settings-3x.png

cp video.png video-1x.png
cp video.png video-2x.png
cp video.png video-3x.png
sips -Z 32 video-1x.png
sips -Z 64 video-2x.png
sips -Z 96 video-3x.png

