#!/bin/bash
apt update
apt install npm -y
apt install   nodejs-legacy sl -y
git clone https://github.com/heroku/node-js-sample /opt/node-js-sample
cd /opt/node-js-sample
npm install
nohup npm start 2> /dev/null &
