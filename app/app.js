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

// populate drop down menu dynamically?

app.get('/node-selection.html',function (req, res) { 

	console.log(req.query["address"]);	
	const address = req.query["address"];

	// to store the values for the form
	var html_data = {
		avg_daily_noise : " - ",
		num_noise_complaints: " - ",
		current_db : " - "
	}

	var node_vsn = ""

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

	// set node id variable for next table
	node_vsn = get_node_vsn();
	console.log(node_vsn);
	    
	function avg_noise() {
	    var db_sum = row.cols["db:db_sum"].value; 
		var db_ct = row.cols["db:db_ct"].value;

	    if(db_ct == 0)
		return " - ";
	    return (db_sum/db_ct).toFixed(1); /* One decimal place */
	};

	// now set the values of the html response above
	html_data['avg_daily_noise'] = avg_noise();
	html_data['num_noise_complaints'] = row.cols["complaints:noise_complaint"].value;
	});

	// // query the current table
	// const speed_get = new hbase.Get("07A");

	// console.log(speed_get);

	// client.get("cmmurray_hbase_node_names", speed_get, function(err, row) {
	// 	assert.ok(!err, console.log(err));
	// 	console.log("we got to 82 but idk how js works");
	// 	if(!row){
	// 		console.log("no row found");
	// 		// res.send("<html><body>No such node in data</body></html>");
	// 		return;
	// 	}

	// // console.log(row.cols);

	// // query this table for recent noise level
	// html_data['current_db'] = row.cols['value'].value;

	// });

	var template = filesystem.readFileSync("noise-result.mustache").toString();
	var html = mustache.render(template, html_data)
	res.send(html);

});

app.listen(port);
