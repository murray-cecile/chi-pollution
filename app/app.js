'use strict';
var assert = require('assert');
const express= require('express');
const app = express();
const mustache = require('mustache');
const filesystem = require('fs');
const hbase = require('hbase-rpc-client');
const hostname = '127.0.0.1';
const port = 3868;
const BigIntBuffer = require('bigint-buffer');

var client = hbase({
    zookeeperHosts: ["mpcs53014c10-m-6-20191016152730.us-central1-a.c.mpcs53014-2019.internal:2181"],
    zookeeperRoot: "/hbase-unsecure"
});

client.on('error', function(err) {
  console.log(err)
})

app.use(express.static('public'));

app.get('/node-selection.html',function (req, res) { 

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
	    
	function avg_noise() {
		if(typeof row.cols["db:db_sum"] == "undefined") {
			return " - ";
		};
	    var db_sum = row.cols["db:db_sum"].value; 
		var db_ct = row.cols["db:db_ct"].value;
		// don't try to divide by zero
		if(db_ct == 0)
		return " - ";
	    return (db_sum/db_ct).toFixed(1); /* One decimal place */
	};

	// to store the values for the form
	var html_data = {
		avg_daily_noise : " - ",
		db_max : " - ",
		num_noise_complaints: " - ",
		current_db : " - ",
		last_seen : " - "
	};

	console.log(row.cols["db:db_max"]);

	// now set the values of the html response above
	html_data['avg_daily_noise'] = avg_noise();
	html_data['db_max'] = row.cols["db:db_max"].value;
	html_data['num_noise_complaints'] = row.cols["complaints:noise_complaint"].value;
	
	if(typeof row.cols["speed:last_seen"] !== "undefined" ) {
		html_data['last_seen'] =  Date(row.cols["speed:last_seen"].value).toLocaleDateString('en-US', { timeZone: 'America/Chicago' });
		html_data['current_db'] = Number(BigIntBuffer.toBigIntBE(row.cols["speed:current_db"].value));
	};

	var template = filesystem.readFileSync("noise-result.mustache").toString();
	var html = mustache.render(template, html_data)
	res.send(html);
	});	

});

app.listen(port);
