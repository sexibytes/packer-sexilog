#
# https://www.elastic.co/guide/en/kibana/current/deb.html
#
apt-get -y install kibana
#
/bin/systemctl daemon-reload
/bin/systemctl enable kibana.service
#
# POST <kibana-host>/api/kibana/settings/theme:darkMode
# {
# 	"value": true
# }
# accessibility:disableAnimations
# securitySolution:enableNewsFeed
# telemetry:enabled
