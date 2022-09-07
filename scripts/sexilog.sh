#
wget -q --no-proxy https://github.com/sexibytes/sexilog/archive/dev.zip -O /tmp/sexilog-src.zip
unzip /tmp/sexilog-src.zip -d /tmp/
#
cp -R /tmp/sexilog-dev/etc/logstash/conf.d/input-syslog-esxi.conf /etc/logstash/conf.d/
cp -R /tmp/sexilog-dev/etc/logstash/conf.d/filter-syslog-esxi.conf /etc/logstash/conf.d/
cp -R /tmp/sexilog-dev/etc/logstash/conf.d/output-elasticsearch.conf /etc/logstash/conf.d/
#
cp -R /tmp/sexilog-dev/opt/elasticsearch-curator/curator.yml /opt/elasticsearch-curator/
cp -R /tmp/sexilog-dev/opt/elasticsearch-curator/action.yml /opt/elasticsearch-curator/
#
cp -R /tmp/sexilog-dev/etc/logrotate.d/* /etc/logrotate.d/
#
# https://www.elastic.co/guide/en/elasticsearch/reference/current/built-in-users.html
#
echo "xpack.security.enabled: true" >> /etc/elasticsearch/elasticsearch.yml
echo "xpack.security.transport.ssl.enabled: true" >> /etc/elasticsearch/elasticsearch.yml
#
/bin/systemctl restart elasticsearch.service
#
sleep 30
#
echo "Sex!L0g" | /usr/share/elasticsearch/bin/elasticsearch-keystore add -xf bootstrap.password
#
echo 'elasticsearch.username: "elastic"' >> /etc/kibana/kibana.yml
echo 'elasticsearch.password: "Sex!L0g"' >> /etc/kibana/kibana.yml
#
echo '/opt/elasticsearch-curator/curator --config /opt/elasticsearch-curator/curator.yml /opt/elasticsearch-curator/action.yml &>/dev/null' >> /etc/cron.hourly/curator
echo "#resize curator limit based on partition size" >> /etc/crontab
echo "@reboot   root    sed -i -r -e \"s/disk_space\: .+/disk_space\: \$(( $(df /mnt/efs | awk '/[0-9]%/{print $(NF-4)}') / 100 * 80 / 1048576))/g\" /opt/elasticsearch-curator/action.yml" >> /etc/crontab
#
# TODO https://github.com/lizozom/custom-kibana-logo/blob/main/public/index.scss
# TODO PullGuestInfos