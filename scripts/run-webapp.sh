# run the web app

cd ~/chi-pollution/app

echo "npm installing modules..."

npm install express
npm install mustache
npm install hbase-rpc-client
npm install bigint-buffer

echo "running app"

node app.js