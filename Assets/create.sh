#!/bin/bash

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

