#!/bin/bash

if ping -c 1 1.1.1.1; then
	/app/mk-games.sh
fi
cd /app/games-gh-pages
/app/chromium-kiosk.sh