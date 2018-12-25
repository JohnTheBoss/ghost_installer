#!/bin/sh

if [ $# -lt 1 ]
then
  echo "Use: ./install.sh URL"
  exit 1
fi

url=$1

echo "Create nginx site config"
cat <<EOF > /etc/nginx/sites-available/$url
server {
    listen 80;
    server_name $url www.$url;
    root /var/www/html;

    location /.well-known/ {
        root /var/www/html/;
    }

    location / {
        return 301 https://$url\$request_uri;
    }
}
EOF

if [ ! -f /etc/nginx/sites-enabled/$url ]
then
    echo "Enable nginx site config"
    ln -s /etc/nginx/sites-available/$url /etc/nginx/sites-enabled/
fi
echo "Restart nginx server"
systemctl reload nginx

echo "Search Free Port"
freePort=2368
while [ `docker ps --format "{{.Ports}}" | grep $freePort` ]
do
    freePort=$((freePort+1))
done
echo "Ghost new port is: $freePort"

echo "Create ghost folder"
mkdir -p /docker/ghost/$url
echo "Ghost data here: /docker/ghost/$url"

echo "Pull latest Ghost and create"
docker pull ghost:latest
docker run --name $url --network bridge -p $freePort:2368 -e url=https://$url -v /docker/ghost/$url/content:/var/lib/ghost/content --restart=always -d ghost:latest
echo "ghost created!"

echo "Create SSL cert"
certbot certonly --authenticator webroot -w /var/www/html -d $url -d www.$url --agree-tos

echo "Update nginx site config, add SSL"
cat <<EOF > /etc/nginx/sites-available/$url
server {
    listen 80;
    server_name $url www.$url;
    root /var/www/html;

    location /.well-known/ {
        root /var/www/html/;
    }

    location / {
        return 301 https://$url\$request_uri;
    }
}

server {
    listen 443 ssl;
    server_name $url;

    ssl_certificate /etc/letsencrypt/live/$url/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$url/privkey.pem;

    client_max_body_size 64M;

    location / {
        proxy_pass http://127.0.0.1:$freePort;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_redirect off;
    }
}

server {
    listen 443 ssl;
    server_name www.$url;

    ssl_certificate /etc/letsencrypt/live/$url/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$url/privkey.pem;

    location / {
        return 301 https://$url\$request_uri;
    }
}
EOF

echo "Restart nginx server"
systemctl reload nginx

echo "Install DONE!"
