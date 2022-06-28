#
# https://www.elastic.co/guide/en/elasticsearch/reference/current/deb.html
#
apt-get install -y gnupg2
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
echo "deb https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-8.x.list
#
apt-get update
apt-get install -y elasticsearch
#
sed -i -e "s/#cluster\.name\: my-application/cluster\.name\: sexilog/g" /etc/elasticsearch/elasticsearch.yml
sed -i -e "s/path\.data\: \/var\/lib\/elasticsearch/path\.data\: \/mnt\/efs\/elasticsearch/g" /etc/elasticsearch/elasticsearch.yml
#
# echo "index.number_of_shards: 1" >> /etc/elasticsearch/elasticsearch.yml
# echo "index.number_of_replicas: 0" >> /etc/elasticsearch/elasticsearch.yml
# https://www.elastic.co/guide/en/elasticsearch/reference/current/index-templates.html
#
sed -i -e "s/cluster.initial_master_nodes/#cluster.initial_master_nodes/g" /etc/elasticsearch/elasticsearch.yml
#
echo "indices.memory.index_buffer_size: 50%" >> /etc/elasticsearch/elasticsearch.yml
#
echo "discovery.type: single-node" >> /etc/elasticsearch/elasticsearch.yml
sed -i -e "s/#bootstrap.memory_lock/bootstrap.memory_lock/g" /etc/elasticsearch/elasticsearch.yml
#
# https://discuss.elastic.co/t/cannot-disable-security-in-8-1/299857
sed -i -e "s/xpack\.security\.enabled\: true/xpack\.security\.enabled\: false/g" /etc/elasticsearch/elasticsearch.yml
echo "xpack.security.transport.ssl.enabled: false" >> /etc/elasticsearch/elasticsearch.yml
echo "xpack.security.http.ssl.enabled: false" >> /etc/elasticsearch/elasticsearch.yml
#
chown -R elasticsearch:elasticsearch /mnt/efs/elasticsearch
#
/bin/systemctl daemon-reload
/bin/systemctl enable elasticsearch.service
/bin/systemctl start elasticsearch.service
#
sleep 30
#
curl -X PUT "localhost:9200/_template/default" -H 'Content-Type: application/json' -d'
{ 
 "index_patterns": ["*"],
 "order": -1,
  "settings" : {
    "number_of_shards" : "1",
    "number_of_replicas" : "0"
  }
} '
#
echo 'vm.swappiness = 1' >> /etc/sysctl.conf
#
# es.enforce.bootstrap.checks

# apt-get install -y elasticsearch-curator