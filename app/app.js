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

app.get('/node-selection.html',function (req, res) { 


	// add drop down menu approach!
	console.log(req.query["address"]);
	// const route=req.query['origin'] + req.query['dest'];
	
	const address = req.query["address"];
	const get = new hbase.Get(address); 
	
    client.get("cmmurray_hbase_master", get, function(err, row) {
	assert.ok(!err, `get returned an error: #{err}`);
	if(!row){
	    res.send("<html><body>No such node in data</body></html>");
	    return;
	}

	// console.log(row);

	function get_node_id() {
		var node_id = row.cols["info:node_id"].value.toString();
		if(node_id == "")
		return " - ";
		return(node_id)
	}

	const node_id = get_node_id();
	console.log(node_id);
	    
	function avg_noise() {
	    var db_sum = Number(BigIntBuffer.toBigIntBE(row.cols["db:db_sum"].value));
		var db_ct = Number(BigIntBuffer.toBigIntBE(row.cols["db:db_ct"].value));
		console.log(db_sum);
		console.log(db_ct);
	    if(db_ct == 0)
		return " - ";
	    return (db_sum/db_ct).toFixed(1); /* One decimal place */
	}

	var template = filesystem.readFileSync("noise-result.mustache").toString();
	var html = mustache.render(template,  {
		avg_daily_noise : avg_noise(),
		num_noise_complaints: Number(BigIntBuffer.toBigIntBE(row.cols["complaints:noise_complaint"].value));
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
