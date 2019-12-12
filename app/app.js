'use strict';
// const http = require('http');
var assert = require('assert');
const express= require('express');
const app = express();
const mustache = require('mustache');
const filesystem = require('fs');
const url = require('url');
const hbase = require('hbase-rpc-client');
const hostname = '127.0.0.1';
const port = 3686;
// const BigIntBuffer = require('bigint-buffer');

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
	const address = req.query["address"];

	const get = new hbase.Get(address); 
	
    client.get("cmmurray_hbase_master", get, function(err, row) {
	assert.ok(!err, `get returned an error: #{err}`);
	if(!row){
	    res.send("<html><body>No such node in data</body></html>");
	    return;
	}

	function get_node_vsn() {
		var node_vsn = row.cols["info:node_vsn"].value.toString();
		if(node_vsn == "")
		return " - ";
		return(node_vsn)
	}

	// const node_vsn = get_node_id();
	// console.log(node_vsn);
	    
	function avg_noise() {
	    var db_sum = row.cols["db:db_sum"].value; 
		var db_ct = row.cols["db:db_ct"].value;
		console.log(db_sum);
		console.log(db_ct);
	    if(db_ct == 0)
		return " - ";
	    return (db_sum/db_ct).toFixed(1); /* One decimal place */
	}

	var template = filesystem.readFileSync("noise-result.mustache").toString();
	var html = mustache.render(template,  {
		avg_daily_noise : avg_noise(),
		num_noise_complaints: row.cols["complaints:noise_complaint"].value
	});
	res.send(html);
	});
	

});

app.listen(port);
