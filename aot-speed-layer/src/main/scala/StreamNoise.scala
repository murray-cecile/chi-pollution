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
import org.apache.hadoop.hbase.client.Get
import org.apache.hadoop.hbase.client.Put
import org.apache.hadoop.hbase.util.Bytes

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
  val nodeTable = hbaseConnection.getTable(TableName.valueOf("cmmurray_hbase_nodes")) 
  val masterTable = hbaseConnection.getTable(TableName.valueOf("cmmurray_hbase_master"))
  
  def putLatestNoise(knr : KafkaNoiseRecord) : String = {
     
    // get address from node lookup table
    val node_info = nodeTable.get(new Get(Bytes.toBytes(knr.node_vsn)))
    val address = Bytes.toString(node_info.getValue(Bytes.toBytes("info"), Bytes.toBytes("address")))
    
    // create put
    val put = new Put(Bytes.toBytes(address))
    // add data
    val cfByte = Bytes.toBytes("speed") 
    put.addColumn(cfByte, Bytes.toBytes("last_seen"), Bytes.toBytes(knr.timestamp))
    put.addColumn(cfByte, Bytes.toBytes("current_db"), Bytes.toBytes(knr.value))
    masterTable.put(put)
    return "Updated master table for node " + address
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