#!/bin/bash
sudo apt-get update
sudo apt install git
git clone https://github.com/jtestkc/bash-scriptu.git
chmod a+x node.sh
bash node.sh
curl -sL https://deb.nodesource.com/setup_14.x | bash -
sudo apt-get install nodejs -y
sudo npm install npm@latest -g -y
sudo npm install -g create-react-app -y
sudo create-react-app my-project -y
cd /my-project
npm start
