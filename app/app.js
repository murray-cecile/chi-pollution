'use strict';
// const http = require('http');
var assert = require('assert');
const express= require('express');
const app = express();
const mustache = require('mustache');
const filesystem = require('fs');
// const url = require('url');
const hbase = require('hbase-rpc-client');
const hostname = '127.0.0.1';
const port = 3686;
// const BigIntBuffer = require('bigint-buffer');

var client = hbase({
    zookeeperHosts: ["mpcs53014c10-m-6-20191016152730.us-central1-a.c.mpcs53014-2019.internal:2181"],
    zookeeperRoot: "/hbase-unsecure"
});

client.on('error', function(err) {
  console.log(err)
})

app.use(express.static('public'));

// based on https://medium.com/@osiolabs/read-write-json-files-with-node-js-92d03cc82824
filesystem.readFile('node_addresses.json', 'utf8', (err, jsonString) => {
    if (err) {
        console.log("Error reading file from disk:", err)
        return
    }
    try {
        const nodes = JSON.parse(jsonString)
        console.log("nodes") 
} catch(err) {
        console.log('Error parsing JSON string:', err)
    }
});

app.get('/node-selection.html',function (req, res) { 

	// // populate drop down menu dynamically?
	// var dropdown = app.getElementById('address-dropdown');
	// var option = app.createElement("option");
	// option1.text("Cottage Grove Ave & 115th St Chicago IL");
	// dropdown.add(option);
	// option2.text("State St & Washington St Chicago IL");
	// dropdown.add(option);

	console.log(req.query["address"]);	
	const address = req.query["address"];

	
	var node_vsn = "";

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

	// to store the values for the form
	var html_data = {
		avg_daily_noise : " - ",
		num_noise_complaints: " - ",
		current_db : " - ",
		last_seen : " - "
	};

        console.log(row.cols);

	// now set the values of the html response above
	html_data['avg_daily_noise'] = avg_noise();
	html_data['num_noise_complaints'] = row.cols["complaints:noise_complaint"].value;
	html_data['last_seen'] = row.cols["speed:last_seen"].value;
	html_data['current_db'] = row.cols["speed:current_db"].value;

	var template = filesystem.readFileSync("noise-result.mustache").toString();
	var html = mustache.render(template, html_data)
	res.send(html);
	});

	// query the current table
	// const speed_get = new hbase.Get("07A");
	// console.log(speed_get);

	// client.get("cmmurray_hbase_node_names", speed_get, function(err, row) {
	// 	assert.ok(!err, console.log(err));
	// 	console.log("we got to 82 but idk how js works");
	// 	if(!row){
	// 		console.log("no row found");
	// 		res.send("<html><body>No such node in data</body></html>");
	// 		return;
	// 	}

	// // console.log(row.cols);

	// // query this table for recent noise level
	// html_data['current_db'] = row.cols['value'].value;

	// });

	

});

app.listen(port);
