# ghost_installer
Ghost Blog CMS simple install in Docker Container and auto config nginx reverse proxy

## First Step:
- Install the nginx server on the host machine
- Install Docker and Certbot

```bash
# Example in Ubuntu 16.04+ x86_64 amd64
# Docker install
apt-get update && apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common -y
    
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

apt-get update && apt-get install docker-ce -y
## END Docker install

# nginx and certbot install
apt-get update && apt-get install \
    nginx \
    certbot -y
## END nginx and certbot install
```

# USE:
 
```bash
mkdir -p /docker/ghost
cd /docker/ghost
git clone https://github.com/JohnTheBoss/ghost_installer.git .
chmod +x install.sh && chmod +x update.sh
```

Note: this script root directory is: /docker/ghost

## Create new Ghost Blog
```bash
./install blog.yourdomain.ltd
```

Note: Don't use www domain because it contains! The reverse proxy automatically redirected to https and non-www. 
*Eg.: blog.yourdomain.ltd create www.blog.yourdomain.ltd and auto redirect http://blog..... or http(?s)://www..... to https://blog.yourdomain.ltd*

Note 2: First setup certbot ask your email

## Update Ghost
```bash
./update blog.yourdomain.ltd
```

Note: Script create backup in .backup/URL_HOUR-MIN_DAY_MONTH_YEAR *Eg.: .backup/blog.yourdomain.ltd_11-53_25_12_2018*
