#!/bin/sh

if [ $# -lt 1 ]
then
  echo "Use: ./update.sh URL"
  exit 1
fi

PORT=`docker port $1 | grep 0.0.0.0.* | cut -f2 -d:`

NOW=$(date +"%H-%M_%d_%m_%Y")

docker stop $1

echo "Create content backup .backup/${1}_${NOW}"
mkdir -p .backup
cp -r $1 .backup/${1}_${NOW}/
echo "Backup Done!"

docker rm $1
docker pull ghost:latest

docker run --name $1  -p $PORT:2368  -e url=https://$1 -v /docker/ghost/$1:/var/lib/ghost/content  --restart=always -d ghost:latest

echo "Update Done!"
