import kafka.serializer.StringDecoder
import org.apache.spark.streaming._
import org.apache.spark.streaming.kafka._
import org.apache.spark.SparkConf
import com.fasterxml.jackson.databind.{ DeserializationFeature, ObjectMapper }
import com.fasterxml.jackson.module.scala.experimental.ScalaObjectMapper
import com.fasterxml.jackson.module.scala.DefaultScalaModule
import org.apache.hadoop.conf.Configuration
import org.apache.hadoop.hbase.TableName
import org.apache.hadoop.hbase.HBaseConfiguration
import org.apache.hadoop.hbase.client.ConnectionFactory
import org.apache.hadoop.hbase.client.Put
import org.apache.hadoop.hbase.client.Increment
import org.apache.hadoop.hbase.util.Bytes
import java.util.Calendar

object StreamNoise {
  val mapper = new ObjectMapper()
  mapper.registerModule(DefaultScalaModule)
  val hbaseConf: Configuration = HBaseConfiguration.create()

  // Use the following two lines if you are building for the cluster 
   hbaseConf.set("hbase.zookeeper.quorum", "mpcs53014c10-m-6-20191016152730.us-central1-a.c.mpcs53014-2019.internal")
   hbaseConf.set("zookeeper.znode.parent", "/hbase-unsecure")
  
  // Use the following line if you are building for the VM
  //  hbaseConf.set("hbase.zookeeper.quorum", "localhost")
  
  val hbaseConnection = ConnectionFactory.createConnection(hbaseConf)
  
  // switch between tables depending on the hour
  var dT = Calendar.getInstance()
  var currentHour = dT.get(Calendar.HOUR_OF_DAY)
  if(currentHour % 2 == 0) {
    val latestNoise = hbaseConnection.getTable(TableName.valueOf("cmmurray_hbase_latest_noise_even"))
  } else {
    val latestNoise = hbaseConnection.getTable(TableName.valueOf("cmmurray_hbase_latest_noise_odd"))
  }
  
  // do this once, on startup
  def initalizeLatestNoise(knr : KafkaNoiseRecord) : String = {
    // create put
    val put = new Put(Bytes.toBytes(knr.node_vsn))
    // add data
    val cfByte = Bytes.toBytes("db") 
    put.add(cfByte, Bytes.toBytes("timestamp"), Bytes.toBytes(0))
    put.add(cfByte, Bytes.toBytes("sensor"), Bytes.toBytes(" "))
    put.add(cfByte, Bytes.toBytes("db_count"), Bytes.toBytes(0))
    put.add(cfByte, Bytes.toBytes("db_sum"), Bytes.toBytes(0))
    latestNoise.put(put)
    return "Initialized speed layer for node " + knr.node_vsn
}
  
 // do this for every message in Kafka
 def incrementLatestNoise(knr : KafkaNoiseRecord) : String = {
    // create increment
    val inc = new Put(Bytes.toBytes(knr.node_vsn))
    // add data
    val cfByte = Bytes.toBytes("db") 
    inc.addColumn(cfByte, Bytes.toBytes("timestamp"), Bytes.toBytes(knr.timestamp))
    inc.addColumn(cfByte, Bytes.toBytes("sensor"), Bytes.toBytes(knr.sensor))
    inc.addColumn(cfByte, Bytes.toBytes("db_count"), Bytes.toBytes(knr.sensor))
    inc.addColumn(cfByte, Bytes.toBytes("db_sum"), Bytes.toBytes(knr.value))
    latestNoise.increment(inc)
    return "Updated speed layer for node " + knr.node_vsn
}
  
  def main(args: Array[String]) {
    if (args.length < 1) {
      System.err.println(s"""
        |Usage: StreamNoise <brokers> 
        |  <brokers> is a list of one or more Kafka brokers
        | 
        """.stripMargin)
      System.exit(1)
    }
    
    val Array(brokers) = args

    // Create context with 2 second batch interval
    val sparkConf = new SparkConf().setAppName("StreamNoise")
    val ssc = new StreamingContext(sparkConf, Seconds(2))

    // Create direct kafka stream with brokers and topics
    val topicsSet = Set("cmmurray")
    
    // Create direct kafka stream with brokers and topics
    val kafkaParams = Map[String, String]("metadata.broker.list" -> brokers)
    val messages = KafkaUtils.createDirectStream[String, String, StringDecoder, StringDecoder](
      ssc, kafkaParams, topicsSet)
   
    // parse the JSON records
    val jsonRecords = messages.map(_._2);

    val kafkaRecords = jsonRecords.map(rec => mapper.readValue(rec, classOf[KafkaNoiseRecord]))

    // Update speed table    
    val processedNoise = kafkaRecords.map(putLatestNoise)
    processedNoise.print()
    // Start the computation
    ssc.start()
    ssc.awaitTermination()
  }

}