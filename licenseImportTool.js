#!/usr/bin/env node
//
var querystring = require('querystring');
var http = require('http');
var fs = require('fs');
var path = require('path');
var util = require('util');
var utils = require('./utils');
var LOGI_HOME = process.env.LOGI_HOME;
var logger = utils.createLogger('licenseImportTool.log');
var args = utils.parseCLIArgs(process.argv);
var licensefile = path.join(LOGI_HOME, 'logiTrial03.lic');
var readData = fs.readFileSync(licensefile).toString();



if (!args.username && !args.password){
	logger.log('error', "username and password parameters are required");
	return logger.exitAfterFlush(1);
}
else if(!args.password) {
	logger.log('error', "password parameter is required");
	return logger.exitAfterFlush(1);
}
else if(!args.username) {
	logger.log('error', "username parameter is required");
	return logger.exitAfterFlush(1);
}


var post_data = JSON.stringify({
  "username":args.username,
  "password":args.password
});




var authenticationPostData = {
  protocol: 'http:',
  hostname: 'localhost',
  port: 3000,
  path: '/api/platform/system.authentication?action=authenticate',
  method: 'POST',
  body: post_data,
  headers: {
    'Content-Type': 'application/json',
    'Content-Length': Buffer.byteLength(post_data)
	}
};

// loop function to make a request for every 10 seconds max time 100 sec
var retry = (function() {
  var count = 0;

	return function(max, timeout, next) {
		logger.log('INFO', 'calling retry');
		var authenticationReq =  http.request(authenticationPostData, (res) => {
			res.on('data', (chunk) => {
			logger.log('info', `${chunk}`);
			if (res.statusCode == 401) {
				return logger.exitAfterFlush(1);
			}
		});
		if (res.statusCode != 200) {
				logger.log('error', 'fail');
				logger.log('INFO', "statusCode: ",  res.statusCode);
				if (count++ < max) {
				return setTimeout(function() {
						retry(max, timeout, next);
					}, timeout);
				} else {
					return next(new Error('max retries reached'));
				}
			}
			next(null, res);
		});
		authenticationReq.write(post_data);
		authenticationReq.end();
	}
})();

// calling the loop to make a request 
retry(10, 13000, function(err, res) {
	if (err){
		logger.log('error', err);
		process.exit(1);
	} else {
		var logauth = JSON.stringify(res.headers["x-logi-auth"]);
		res.setEncoding('utf8');
		logger.log('info', "successful statusCode: ",  res.statusCode);
		trialLicense(logauth)
	}
	
});


//clientsecret post request
function trialLicense(logiAuth){
    var licensePostData = {
			protocol: 'http:',
			hostname: 'localhost',
			port: 3000,
			path: '/api/platform/system.licenses/logiTrial03',
			method: 'POST',
			body: readData,
			headers: {
				'Content-Type': 'application/json',
				'Authorization':'Bearer ' + logiAuth
			}	
	};
	
		// Set up the request
	var licenseReq = http.request(licensePostData, (res) => {
		res.setEncoding('utf8');
		res.on('data', function(chunk) {
			var body = JSON.parse(chunk);
			if (res.statusCode == 201){
				logger.log('info', "license successfully added");
			}
			else {
			logger.log('info',body);
			return logger.exitAfterFlush(1);
			}
		});
	});
licenseReq.write(readData);
licenseReq.end();


}
