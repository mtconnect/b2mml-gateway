if (process.argv.length < 3) {
	console.log("Usage node " + process.argv[1] + " <filename> [<uuid>]");
}

var http = require('http');
var fs = require('fs');
var filename = process.argv[2];
var data = null;
var uuid;

if (process.argv.length < 4) {
	uuid = filename;
} else {
	uuid = process.argv[3];
}

console.log(`Sending file ${filename} with uuid ${uuid}`);

var postFile = function(data, type) {
	var options = {
		hostname:  'swim.steptools.com',
		port: 5000,
		path: `/asset/${uuid}?device=OKUMA.MachiningCenter&type=${type}`,
		method: 'POST',
		headers: {
			'Content-Type': 'text/xml',
			'Content-Length': Buffer.byteLength(data)
		}
	};
	
	var req = http.request(options, (res) => {
		console.log(`Status: ${res.statusCode}`);
		console.log(`Headers: ${JSON.stringify(res.headers)}`);
		
		res.on('data', (chunk) => {
			console.log(`result: ${chunk}`);
		})
	});
	req.on('error', (e) => {
		console.log(`Error occurred with request: ${e.message}`);
	})
	
	req.write(data);
	req.end();
}

fs.readFile(filename, 'utf8', (err, data) => {
	if (err) throw err;
	
	console.log("File read...");
	
	var wrapped, type;
	if (filename.endsWith("qif")) {
		// Remvoe the process statement
		var lines = data.split('\n');
		lines.splice(0, 1);
		var newData = lines.join('\n');
		wrapped = "<QIFResult>" + newData + "</QIFResult>";
		type = "QIFResult";
	} else if (filename.endsWith("stp")) {
		wrapped = "<AP242><![CDATA[" + data + "]]></AP242>";
		type = "AP242";		
	} else if (filename.endsWith("stpnc")) {
		wrapped = "<AP238><![CDATA[" + data + "]]></AP238>";
		type = "AP238";		
	}

	postFile(wrapped, type);
});

