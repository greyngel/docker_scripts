#!/bin/sh

#Generate random password -- never use defaults
#linux
#password=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1`

#mac
password=`cat /dev/urandom | env LC_CTYPE=C tr -dc a-zA-Z0-9 | head -c 8`

#stop existing
docker stop openvas

#remove existing
docker rm openvas

#pull new image
docker pull mikesplain/openvas

#fire up new container
docker run -d -p 443:443 -v openvas_data:/var/lib/openvas/mgr/ --name openvas mikesplain/openvas

#let people kknow the password... comment this out if you dont
echo "*"
echo "username: admin"
echo "*"
echo "password: " $password
echo "*"
echo "*"
echo "now go to https://localhost"
#generate an update script you can put on a cron or whatever
echo "#!/bin/sh
docker exec openvas greenbone-nvt-sync
docker exec openvas openvasmd --rebuild --progress
docker exec openvas greenbone-certdata-sync
docker exec openvas greenbone-scapdata-sync
docker exec openvas openvasmd --update --verbose --progress

docker exec openvas /etc/init.d/openvas-manager restart

#this part hangs, still working on it - restarting container instead
#docker exec -i openvas /etc/init.d/openvas-scanner restart
docker restart openvas" > greenbone_update.sh

#make the script executable - comment ths out if you dont want to
chmod +x greenbone_update.sh

#waiting for system before setting password
echo Wait until your system CPU dies down before logging in, this can take a while.... hit ENTER to continue.
sleep 10
read something
docker exec openvas openvasmd --user=admin --new-password=$password
echo "username:admin
password: $password " > greenbone_creds.txt
