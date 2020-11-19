#
wget -q --no-proxy https://github.com/sexibytes/sexilog/archive/dev.zip -O /tmp/sexilog-src.zip
unzip /tmp/sexilog-src.zip -d /tmp/
#
cp -R /tmp/sexilog-dev/etc/logstash/conf.d/input-syslog-esxi.conf /etc/logstash/conf.d/
cp -R /tmp/sexilog-dev/etc/logstash/conf.d/filter-syslog-esxi.conf /etc/logstash/conf.d/
cp -R /tmp/sexilog-dev/etc/logstash/conf.d/output-elasticsearch.conf /etc/logstash/conf.d/