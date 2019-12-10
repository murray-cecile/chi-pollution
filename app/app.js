'use strict';
const http = require('http');
var assert = require('assert');
const express= require('express');
const app = express();
const mustache = require('mustache');
const filesystem = require('fs');
const url = require('url');
const hbase = require('hbase-rpc-client');
const hostname = '127.0.0.1';
const port = 3686;
const BigIntBuffer = require('bigint-buffer');


/* Commented out lines are for running on our cluster */
var client = hbase({
    zookeeperHosts: ["mpcs53014c10-m-6-20191016152730.us-central1-a.c.mpcs53014-2019.internal:2181"],
    zookeeperRoot: "/hbase-unsecure"
});

client.on('error', function(err) {
  console.log(err)
})

app.use(express.static('public'));
app.get('/delays.html',function (req, res) { // change the name of the webpage
	// const route=req.query['origin'] + req.query['dest'];
	
	// fix this so client can get variable rows
	const node = '001e06115382';
	const get = new hbase.Get(node); 
	// console.log('bar');
	
    client.get("cmmurray_hbase_node_names", get, function(err, row) {
	// console.log('foo');
	assert.ok(!err, `get returned an error: #{err}`);
	if(!row){
	    res.send("<html><body>No such node in data</body></html>");
	    return;
	}

	console.log(row);

	function get_node_id() {
		var node_id = row.cols["in:node_id"].value;
		if(node_id == "")
		return " - ";
		return(node_id)
	}

	const node_id = get_node_id();
	console.log(node_id);
	    
	function avg_daily_noise() {
	    var db_sum = Number(BigIntBuffer.toBigIntBE(row.cols["db:db_sum"].value));
		var db_ct = Number(BigIntBuffer.toBigIntBE(row.cols["db:db_ct"].value));
		var db_days = Number(BigIntBuffer.toBigIntBE(row.cols["db:days"].value));
	    if(db_ct == 0 | days == 0)
		return " - ";
	    return (db_sum/db_ct/db_days).toFixed(1); /* One decimal place */
	}

	function get_node_location() {
		var node_loc = row.cols["info:address"].value;
		if(node_loc == "")
		return " - ";
		return(node_loc)
	}


	var template = filesystem.readFileSync("result.mustache").toString();
	var html = mustache.render(template,  {
	    node_name : get_node_location(),
	    avg_daily_noise : avg_daily_noise()
	});
	res.send(html);
    });
});
	
/* Send simulated weather to kafka */
// var kafka = require('kafka-node');
// var Producer = kafka.Producer;
// var KeyedMessage = kafka.KeyedMessage;
// var kafkaClient = new kafka.KafkaClient({kafkaHost: 'mpcs53014c10-m-6-20191016152730.us-central1-a.c.mpcs53014-2019.internal:6667'});
// var kafkaProducer = new Producer(kafkaClient);


// app.get('/weather.html',function (req, res) {
//     var station_val = req.query['station'];
//     var fog_val = (req.query['fog']) ? true : false;
//     var rain_val = (req.query['rain']) ? true : false;
//     var snow_val = (req.query['snow']) ? true : false;
//     var hail_val = (req.query['hail']) ? true : false;
//     var thunder_val = (req.query['thunder']) ? true : false;
//     var tornado_val = (req.query['tornado']) ? true : false;
//     var report = {
// 	station : station_val,
// 	clear : !fog_val && !rain_val && !snow_val && !hail_val && !thunder_val && !tornado_val,
// 	fog : fog_val,
// 	rain : rain_val,
// 	snow : snow_val,
// 	hail : hail_val,
// 	thunder : thunder_val,
// 	tornado : tornado_val
//     };

//     kafkaProducer.send([{ topic: 'weather-reports', messages: JSON.stringify(report)}],
// 			   function (err, data) {
// 			       console.log(data);
// 			   });
//     console.log(report);
//     res.redirect('submit-weather.html');
// });

app.listen(port);
