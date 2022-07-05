#
# https://www.elastic.co/guide/en/kibana/current/deb.html
#
apt-get -y install kibana
#
sed -i -e 's/#server\.host: "localhost"/server\.host: "0\.0\.0\.0"/g' /etc/kibana/kibana.yml
# disable telemetry
echo "telemetry.enabled: false" >> /etc/kibana/kibana.yml
echo "security.showInsecureClusterWarning: false" >> /etc/kibana/kibana.yml
#
/bin/systemctl daemon-reload
/bin/systemctl enable kibana.service
/bin/systemctl start kibana.service
sleep 60s
# Create index pattern
curl -XPOST "http://localhost:5601/api/saved_objects/index-pattern/logstash-*" -H "Content-Type: application/json" -H "kbn-xsrf: true" -d'
{
  "attributes" : {
    "title" : "logstash-*",
    "timeFieldName" : "@timestamp"
  }
}'
sleep 5s
# Make it the default index
curl -XPOST "http://localhost:5601/api/kibana/settings/defaultIndex" -H "Content-Type: application/json" -H "kbn-xsrf: true" -d'
{
  "value" : "logstash-*"
}'
# Make discover default home
curl -XPOST "http://localhost:5601/api/kibana/settings/defaultRoute" -H "Content-Type: application/json" -H "kbn-xsrf: true" -d'
{
  "value" : "/app/discover"
}'
#
curl -XPOST "http://localhost:5601/api/kibana/settings/accessibility:disableAnimations" -H "Content-Type: application/json" -H "kbn-xsrf: true" -d'
{
  "value" : "true"
}'
#
curl -XPOST "http://localhost:5601/api/kibana/settings/securitySolution:enableNewsFeed" -H "Content-Type: application/json" -H "kbn-xsrf: true" -d'
{
  "value" : "false"
}'
#
curl -XPOST "http://localhost:5601/api/kibana/settings/doc_table:hideTimeColumn" -H "Content-Type: application/json" -H "kbn-xsrf: true" -d'
{
  "value" : "true"
}'
#
curl -XPOST "http://localhost:5601/api/kibana/settings/defaultColumns" -H "Content-Type: application/json" -H "kbn-xsrf: true" -d'
{
  "value" : ["message"]
}'
#
# POST <kibana-host>/api/kibana/settings/theme:darkMode
# {
# 	"value": true
# }
# accessibility:disableAnimations
# securitySolution:enableNewsFeed
# telemetry:enabled
