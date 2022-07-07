#
apt-get -y install logstash
#
/bin/systemctl daemon-reload
/bin/systemctl enable logstash.service
#
# 514 port opening needs root
sed -i -e "s/User=logstash/User=root/g" /usr/lib/systemd/system/logstash.service
sed -i -e "s/Group=logstash/Group=root/g" /usr/lib/systemd/system/logstash.service
# sed -i -e 's/LS_USER=\"logstash\"/LS_USER=\"root\"/g' /etc/default/logstash
# sed -i -e 's/LS_GROUP=\"logstash\"/LS_GROUP=\"root\"/g' /etc/default/logstash
#
echo "LS_HEAP_SIZE=2G" >> /etc/default/logstash
#