import time
import requests
from kafka import KafkaProducer

AOT_API_ROOT = "https://api.arrayofthings.org/api/observations"
KAFKA_HOST = "mpcs53014c10-m-6-20191016152730.us-central1-a.c.mpcs53014-2019.internal:2181"
KAFKA_TOPIC = "cmmurray"

def define_request():
    '''
    Takes: nothing?
    Returns: request for Chicago noise intensity from AoT API
    '''

    p = {'project': 'chicago',
        'sensor':'metsense.spv1840lr5h_b.intensity',
        'size': 25}

    r = requests.get(AOT_API_ROOT, params = p)

    if r.raise_for_status():
        return '{}'    
    else:
        return r


def parse_response(r):
    '''
    Takes: request
    Returns: parsed data in list of tuples
    '''

    rj = r.json()

    parsed = []

    for n in rj['data']:

        node_vsn = n['node_vsn']
        timestamp = n['timestamp']
        sensor = n['sensor_path']
        value = n['value']

        parsed.append(node_vsn, timestamp, sensor, value)
    
    return parsed


def create_kafka_producer():
    '''
    Takes: None
    Returns: Kafka producer instance

    Creates a Kafka producer
    Adapted from: https://bit.ly/2P7C9PN
    '''

    producer = None

    try:
        producer = KafkaProducer(bootstrap_servers=KAFKA_HOST)
    except Exception as ex:
        print("Exception creating Kafka producer")
        print(str(ex))
    finally:
        return producer


def send_message(producer, message):
    '''
    Takes: producer, single message tuple
    Returns: nothing

    Sends parsed values to Kafka
    Adapted from: https://bit.ly/2P7C9PN
    '''

    try:
        producer.instance.send(KAFKA_TOPIC, key=time.time(), value = message)
        producer.flush()
        print("Successful publish")
    except Exception as ex:
        print("Exception publishing message")
        print(str(ex))


if __name__ == "__main__":
    
    r = define_request()
    parsed = parse_response(r)

    producer = create_kafka_producer()
    for p in parsed:
        send_message(producer, p)

