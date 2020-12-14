#
apt-get -y install logstash
#
/bin/systemctl daemon-reload
/bin/systemctl enable logstash.service
#
sed -i -e "s/User=logstash/User=root/g" /etc/systemd/system/logstash.service
sed -i -e "s/Group=logstash/Group=root/g" /etc/systemd/system/logstash.service
#