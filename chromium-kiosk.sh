#!/bin/bash
# Start an X server
sudo X &
# Start a webserver
python -m http.server 8000 -d /app/games-gh-pages &
# Start chromium
DISPLAY=:0 chromium-browser --start-fullscreen --window-size=1920,1080 --kiosk --noerrdialogs --disable-translate --no-first-run --fast --fast-start --disable-infobars --disable-features=TranslateUI --disk-cache-dir=/dev/null  --password-store=basic http://localhost:8000
#DISPLAY=:0 chromium-browser --start-fullscreen --window-size=1920,1080 http://localhost:8000
# Chromium has died, kill X and python
sudo kill $$
sudo kill $$
sudo killall Xorg