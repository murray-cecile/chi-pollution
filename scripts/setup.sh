# setup

# create virtual environment for Python package installation
python3 -mvenv venv
source ./venv/bin/activate
pip install -r requirements.txt

# make directory for the logs from nohup
mkdir logs

# create a Kafka topic 
/usr/hdp/current/kafka-broker/bin/kafka-topics.sh --create --zookeeper mpcs53014c10-m-6-20191016152730.us-central1-a.c.mpcs53014-2019.internal:2181 --replication-factor 1 --partitions 1 --topic cmmurray

# send some test messages if desired
# /usr/hdp/current/kafka-broker/bin/kafka-console-producer.sh --broker-list mpcs53014c10-m-6-20191016152730.us-central1-a.c.mpcs53014-2019.internal:6667 --topic cmmurray

# consume messages from another terminal 
# /usr/hdp/current/kafka-broker/bin/kafka-console-consumer.sh --bootstrap-server mpcs53014c10-m-6-20191016152730.us-central1-a.c.mpcs53014-2019.internal:6667 --topic cmmurray --from-beginning

# moving jar file manually right now, should zip the thing later probably
gcloud compute scp aot-speed-layer/target/uber-aot-speed-layer-0.0.1-SNAPSHOT.jar cmmurray@mpcs53014c10-m-6-20191016152730:chi-pollution

