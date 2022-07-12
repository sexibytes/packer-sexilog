#
apt-get -y install logstash
#
/bin/systemctl daemon-reload
/bin/systemctl enable logstash.service
#
# 514 port opening needs root
sed -i -e "s/User=logstash/User=root/g" /etc/systemd/system/logstash.service
sed -i -e "s/Group=logstash/Group=root/g" /etc/systemd/system/logstash.service
#
echo "LS_HEAP_SIZE=2G" >> /etc/default/logstash
#