#!/bin/sh

#--------------------------------------------------------#
# 標準出力と標準エラーを画面とログファイルへ出力する設定 #
#--------------------------------------------------------#
FIFO=/tmp/$$.fifo
LOG=/tmp/debug.log
mkfifo ${FIFO}
trap '/bin/rm -f ${FIFO}' EXIT
tee ${LOG} < ${FIFO} &
exec > ${FIFO} 2>&1
#--------------------------------------------------------#
# copied from https://blue21neo.blogspot.com/2015/08/blog-post.html


# Logging start
echo "** `date '+%Y-%m-%d %H:%M:%S'` - START"

# update and upgade
sudo apt-get -y update
sudo apt-get -y dist-upgrade

sudo apt -y install docker.io
sudo usermod -aG docker vagrant
sudo service docker restart

# install nginx
sudo apt install -y nginx
# sudo ln -s /app/uwsgi.conf /etc/nginx/conf.d/uwsgi.conf
sudo service nginx restart

echo "** `date '+%Y-%m-%d %H:%M:%S'` - END"

exit 0

