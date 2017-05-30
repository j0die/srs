#!/bin/bash

echo ""

# Root check
if [[ "$UID" -ne 0 ]]; then
	echo "!! This script requires root privileges"
	echo ""
	exit
fi

echo -n "=> Pulling puppycodes/srs image..."
docker pull puppycodes/srs > /dev/null
echo "done."

echo "=> Starting Docker container..."
CID=$(docker run --restart=always -p 80:8080 -v /data/koken/www:/usr/share/nginx/www -v /data/koken/mysql:/var/lib/mysql -d puppycodes/srs /sbin/my_init)

echo -n "=> Waiting for Koken to become available.."

RET=0
while [[ RET -lt 1 ]]; do
	IP=$(docker inspect $CID | grep IPAddress | cut -d '"' -f 4)
	echo -n "."
	sleep 5
    RET=$(curl -s http://$IP:8080 | grep "jquery" | wc -l)
done
echo "done."

echo "=> Ready! Load this server's IP address or domain in a browser to begin using Koken."
echo ""
