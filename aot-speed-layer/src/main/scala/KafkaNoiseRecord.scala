import scala.reflect.runtime.universe._


case class KafkaNoiseRecord(
    node_vsn: String,
    timestamp: String, 
    sensor: String, 
    value: Long)