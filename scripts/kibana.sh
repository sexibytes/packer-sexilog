#
# https://www.elastic.co/guide/en/kibana/current/deb.html
#
apt-get -y install kibana
#
/bin/systemctl daemon-reload
/bin/systemctl enable kibana.service
#
sed -i -e 's/#server\.host: "localhost"/server\.host: "0\.0\.0\.0"/g' /etc/kibana/kibana.yml
#
/bin/systemctl start kibana.service
# Create index pattern
curl -XPOST "http://localhost:5601/api/saved_objects/index-pattern/logstash-*" -H "Content-Type: application/json" -H "kbn-xsrf: true" -d'
{
  "attributes" : {
    "title" : "logstash-*",
    "timeFieldName" : "@timestamp"
  }
}'
# Make it the default index
curl -XPOST "http://localhost:5601/api/kibana/settings/defaultIndex" -H "Content-Type: application/json" -H "kbn-xsrf: true" -d'
{
  "value" : "logstash-*"
}'
#
# POST <kibana-host>/api/kibana/settings/theme:darkMode
# {
# 	"value": true
# }
# accessibility:disableAnimations
# securitySolution:enableNewsFeed
# telemetry:enabled
