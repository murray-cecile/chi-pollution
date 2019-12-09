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
const port = 3000;
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
app.get('/delays.html',function (req, res) {
    const route=req.query['origin'] + req.query['dest'];
    const get = new hbase.Get(route);
    console.log('bar');
    client.get("spertus_weather_delays_by_route", get, function(err, row) {
	console.log('foo');
	assert.ok(!err, `get returned an error: #{err}`);
	if(!row){
	    res.send("<html><body>No such route in data</body></html>");
	    return;
	}
	    
	function weather_delay(weather) {
	    var flights = Number(BigIntBuffer.toBigIntBE(row.cols["delay:" + weather + "_flights"].value));
	    var delays = Number(BigIntBuffer.toBigIntBE(row.cols["delay:" + weather + "_delays"].value));
	    if(flights == 0)
		return " - ";
	    return (delays/flights).toFixed(1); /* One decimal place */
	}

	var template = filesystem.readFileSync("result.mustache").toString();
	var html = mustache.render(template,  {
	    origin : req.query['origin'],
	    dest : req.query['dest'],
	    clear_dly : weather_delay("clear"),
	    fog_dly : weather_delay("fog"),
	    rain_dly : weather_delay("rain"),
	    snow_dly : weather_delay("snow"),
	    hail_dly : weather_delay("hail"),
	    thunder_dly : weather_delay("thunder"),
	    tornado_dly : weather_delay("tornado")
	});
	res.send(html);
    });
});
	
/* Send simulated weather to kafka */
var kafka = require('kafka-node');
var Producer = kafka.Producer;
var KeyedMessage = kafka.KeyedMessage;
var kafkaClient = new kafka.KafkaClient({kafkaHost: 'mpcs53014c10-m-6-20191016152730.us-central1-a.c.mpcs53014-2019.internal:6667'});
var kafkaProducer = new Producer(kafkaClient);


app.get('/weather.html',function (req, res) {
    var station_val = req.query['station'];
    var fog_val = (req.query['fog']) ? true : false;
    var rain_val = (req.query['rain']) ? true : false;
    var snow_val = (req.query['snow']) ? true : false;
    var hail_val = (req.query['hail']) ? true : false;
    var thunder_val = (req.query['thunder']) ? true : false;
    var tornado_val = (req.query['tornado']) ? true : false;
    var report = {
	station : station_val,
	clear : !fog_val && !rain_val && !snow_val && !hail_val && !thunder_val && !tornado_val,
	fog : fog_val,
	rain : rain_val,
	snow : snow_val,
	hail : hail_val,
	thunder : thunder_val,
	tornado : tornado_val
    };

    kafkaProducer.send([{ topic: 'weather-reports', messages: JSON.stringify(report)}],
			   function (err, data) {
			       console.log(data);
			   });
    console.log(report);
    res.redirect('submit-weather.html');
});

app.listen(port);
