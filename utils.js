var http = require('http');
var path = require('path');
var util = require('util');
var fs = require('fs');
var os = require('os');

exports.parseCLIArgs = function parseCLIArgs(args) {
	var parsedArgs = {};
	var argMatcher = /--([^-=]+)=(.+)/;

	args.forEach(function(arg) {
		var match = arg.match(argMatcher);
		if (match) {
			parsedArgs[match[1]] = match[2];
		}
	});

	return parsedArgs;
};

exports.makeRequest = function makeRequest(logger, logiAuth, path, method, postData){
	var requestOptions = {
		protocol: 'http:',
		hostname: 'localhost',
		port: 3000,
		path: '/api/platform/' + path,
		method: method,
		headers: {
			'Content-Type': 'application/json',
			'Authorization':'Bearer ' + logiAuth
		}
	};
	
	return new Promise(function(resolve, reject) {
		var data = "";
		// Set up the request
		var request = http.request(requestOptions, (res) => {
			res.setEncoding('utf8');
			res.on('data', function(chunk) {
				data += String(chunk);
			});

			res.on('end', function() {
				var body;
				try {
					body = JSON.parse(data);
				} catch(e) {
					body = data;
				}

				res.body = body;

				if (String(res.statusCode).startsWith('2')) {
					resolve(res);
				} else {
					reject(res);
				};
			});
		});

		request.on('error', function(e) {
			logger.log('error', 'Error reaching server');
			reject(e);
		})

		if (postData) {
			request.write(postData);
		}
		request.end();
	});
};

exports.attemptLogin = function attemptLogin(logger, username, password, maxAttempts, timeBetweenRequests) {
	if (!maxAttempts) maxAttempts = 10;
	if (!timeBetweenRequests) timeBetweenRequests = 13000;

	var post_data = JSON.stringify({
		"username":username,
		"password":password
	});
	
	var authenticationRequestOptions = {
		protocol: 'http:',
		hostname: 'localhost',
		port: 3000,
		path: '/api/platform/system.authentication?action=authenticate',
		method: 'POST',
		headers: {
			'Content-Type': 'application/json'
		}
	};

	// loop function to make a request for every 10 seconds max time 100 sec
	return new Promise(function(resolve, reject) {
		var attempts = 0;
		var retry = function(max, timeout) {
			var data = "";
			var authenticationReq = http.request(authenticationRequestOptions, (res) => {
				res.setEncoding('utf8');
				res.on('data', (chunk) => {
					data += String(chunk);
				});

				res.on('end', () => {
					// Try to parse the return.
					try {
						data = JSON.parse(data);
					} catch(e) {
						data = {};
					}

					if (res.statusCode == 401) {
						reject(new Error(`Invalid credentials`));
					}
					else if (res.statusCode != 200) {
						logger.log('warn', `Response statusCode: ${res.statusCode}`);
						logger.log('warn', `Error Message: ${data.message}`);

						if (attempts++ < max) {
							logger.log('warn', `Login attempt failed. Retrying in ${timeout / 1000} seconds`);
							setTimeout(function() {
								retry(max, timeout);
							}, timeout);
						} else {
							reject(new Error('error', 'Max attempts reached. Exiting'));
						}
					}
					else {
						logger.log('info', `Logged in successfully`);
						resolve(res.headers["x-logi-auth"]);
					}
				});
			});
			authenticationReq.on('error', function(e) {
				logger.log('warn', `Error reaching REST server: ${e.message}`);

				if (attempts++ < max) {
					logger.log('warn', `Login attempt failed. Retrying in ${timeout / 1000} seconds`);
					setTimeout(function() {
						retry(max, timeout);
					}, timeout);
				} else {
					reject(new Error('error', 'Max attempts reached. Exiting'));
				}
			});

			authenticationReq.write(post_data);
			authenticationReq.end();
		};

		retry(maxAttempts, timeBetweenRequests);
	});
};

//function to get customized timestamp.
function timestamp(){
  function pad(n) {return n<10 ? "0"+n : n}
  var d = new Date()
  var dash = "-"
  var colon = ":"
  var timezone_offset_min = new Date().getTimezoneOffset(),
	offset_hrs = parseInt(Math.abs(timezone_offset_min/60)),
	offset_min = Math.abs(timezone_offset_min%60),
	timezone_standard;

	if(offset_hrs < 10)
		offset_hrs = '0' + offset_hrs;

	if(offset_min < 10)
		offset_min = '0' + offset_min;
	if(timezone_offset_min < 0)
		timezone_standard = '+' + offset_hrs + ':' + offset_min;
	else if(timezone_offset_min > 0)
		timezone_standard = '-' + offset_hrs + ':' + offset_min;
	else if(timezone_offset_min == 0)
		timezone_standard = 'Z';
  return d.getFullYear()+dash+
  pad(d.getMonth()+1)+dash+
  pad(d.getDate())+"T"+
  pad(d.getHours())+colon+
  pad(d.getMinutes())+colon+
  pad(d.getSeconds())+
  pad(timezone_standard);
}

//function to create and write log file
exports.createLogger = function createLogger(filename) {
	var LOGI_HOME = process.env.LOGI_HOME;
	var logFilename = path.join(LOGI_HOME, 'platform', 'logs', filename);
	var logFile = fs.createWriteStream(logFilename, {flags : 'a'});
	var logger = {
		log: function log(level) {

			var formatted = util.format.apply(util, Array.prototype.slice.call(arguments, 1));
			var message = `[${timestamp()}] [${level.toUpperCase()}] - ${formatted}`;
			
			logFile.write(message + os.EOL);
			console.log(message);
		},
		exitAfterFlush: function exitAfterFlush(exitCode) {
			logFile.end();
			logFile.on('finish', () => {
				process.exit(exitCode);
			});
		}
	};

	return logger;
};