#
# https://www.elastic.co/guide/en/elasticsearch/reference/current/deb.html
#
apt-get install -y gnupg2
#
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-7.x.list
#
apt-get update
apt-get install -y elasticsearch
#
sed -i -e "s/#cluster\.name\: my-application/cluster\.name\: sexilog/g" /etc/elasticsearch/elasticsearch.yml
sed -i -e "s/path\.data\: \/var\/lib\/elasticsearch/path\.data\: \/mnt\/efs\/elasticsearch/g" /etc/elasticsearch/elasticsearch.yml
#
sed -i -e "s/cluster.initial_master_nodes/#cluster.initial_master_nodes/g" /etc/elasticsearch/elasticsearch.yml
#
echo "indices.memory.index_buffer_size: 50%" >> /etc/elasticsearch/elasticsearch.yml
#
echo "discovery.type: single-node" >> /etc/elasticsearch/elasticsearch.yml
sed -i -e "s/#bootstrap.memory_lock/bootstrap.memory_lock/g" /etc/elasticsearch/elasticsearch.yml
sed -i -e "s/http\.host\: 0\.0\.0\.0/http\.host\: 127\.0\.0\.1/g" /etc/elasticsearch/elasticsearch.yml
#
chown -R elasticsearch:elasticsearch /mnt/efs/elasticsearch
#
# https://sleeplessbeastie.eu/2020/02/29/how-to-prevent-systemd-service-start-operation-from-timing-out/
mkdir /etc/systemd/system/elasticsearch.service.d
echo -e "[Service]\nTimeoutStartSec=180" | sudo tee /etc/systemd/system/elasticsearch.service.d/startup-timeout.conf
#
/bin/systemctl daemon-reload
/bin/systemctl enable elasticsearch.service
/bin/systemctl start elasticsearch.service
#
sleep 30
#
curl -X PUT "localhost:9200/_template/default" -H 'Content-Type: application/json' -d'
{ 
 "template" : "*",
 "order": -1,
  "settings" : {
    "number_of_shards" : "1",
    "number_of_replicas" : "0"
  }
} '
#
sleep 3
#
curl -X PUT "localhost:9200/_cluster/settings?flat_settings=true&pretty" -H 'Content-Type: application/json' -d'
{
    "transient" : {
        "logger.org.elasticsearch.deprecation": "ERROR"
    }
}'
echo 'vm.swappiness = 1' >> /etc/sysctl.conf
#
# es.enforce.bootstrap.checks
#
# Install & configure Curator
wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb [arch=amd64] https://packages.elastic.co/curator/5/debian9 stable main" > /etc/apt/sources.list.d/curator.list
#
apt-get update
apt-get install -y elasticsearch-curator
mkdir -p /var/log/elasticsearch-curator