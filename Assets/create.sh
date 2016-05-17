#!/bin/bash

cp camera.png camera-1x.png
cp camera.png camera-2x.png
cp camera.png camera-3x.png
sips -Z 48 camera-1x.png
sips -Z 96 camera-2x.png
sips -Z 144 camera-3x.png

cp settings.png settings-1x.png
cp settings.png settings-2x.png
cp settings.png settings-3x.png
sips -Z 24 settings-1x.png
sips -Z 48 settings-2x.png
sips -Z 72 settings-3x.png

sips -p 1792 1792 video.png
cp video.png video-1x.png
cp video.png video-2x.png
cp video.png video-3x.png
sips -Z 24 video-1x.png
sips -Z 48 video-2x.png
sips -Z 72 video-3x.png

