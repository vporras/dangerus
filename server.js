//Lets define a port we want to listen to
const PORT = process.argv[2] || 80;
const DEFAULT_RADIUS = 1000.0;

var http = require('http'),
express = require('express'),
path = require('path'),
MongoClient = require('mongodb').MongoClient,
dbDriver = require('./dbDriver').dbDriver,
favicon = require('serve-favicon');

var app = express();
app.set('port', PORT); 

app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'jade');

var mongoHost = 'localhost'; 
var mongoPort = 27017; 
var dbDriver;

var url = 'mongodb://localhost:27017/local';
MongoClient.connect(url, function(err, db) {
    if (err) {
	console.error("Error! Exiting... Must start MongoDB first");
	process.exit(1); 
    } else {
	dbDriver = new dbDriver(db); 
    }
});

app.use(express.bodyParser());

app.use(favicon(__dirname + '/public/favicon.ico'));

app.use(express.static(path.join(__dirname, 'public')));

app.get('/', function (req, res) {
    res.send('<html><body><h1>Welcome to Safety Circle!</h1></body></html>');
});

app.get('/dashboard', function (req, res) {
    dbDriver.findAll("incidents", {}, function(error, objs) { 
    	if (error) { res.send(400, error); } 
	else {
	    if (req.accepts('html')) { 
    	        res.render('dashboard',{incidents: objs}); 
            } else {
	        res.set('Content-Type','application/json');
                res.send(200, objs); 
            }
        }
    });
});


app.get('/dashboard/:entity', function (req, res) {
    var params = req.params;
    var entity = params.entity;
    dbDriver.get("incidents", entity, function(error, incident) { 
    	if (error) { res.send(400, error); } 
	else {
	    var query = {incident_id: incident._id};
	    dbDriver.findAll("reports", query, function(error, reports) {
		if (req.accepts('html')) {
		    console.log(incident);
    	            res.render('incident', {
			incident: incident,
			reports: reports
		    }); 
		} else {
	            res.set('Content-Type','application/json');
                    res.send(200, reports);
		}
            });
        }
    });
});

app.get('/:collection', function(req, res) { 
    var params = req.params;
    var collection = req.params.collection;
    var query = {};
    var key;
    for (key in req.query)
	if (key.match(/\w+/))
	    query[key] = req.query[key];

    dbDriver.findAll(collection, query, function(error, objs) { 
    	if (error) { res.send(400, error); } 
	else {
	    for (var i = 0; i < objs.length; i++) {
		objs[i][collection.slice(0, -1) + '_id'] = objs[i]._id;
		delete objs[i]._id;
	    }
	    if (req.accepts('html')) { 
    	        res.render('data',{objects: objs, collection: collection}); 
            } else {
	        res.set('Content-Type','application/json');
                res.send(200, objs); 
            }
        }
    });
});

app.get('/:collection/:entity', function(req, res) { 
    var params = req.params;
    var entity = params.entity;
    var collection = params.collection;
    if (entity) {
	dbDriver.get(collection, entity, function(error, objs) { 
            if (error) { res.send(400, error); }
            else { res.send(200, objs); } 
	});
    } else {
	res.send(400, {error: 'bad url', url: req.url});
    }
});

app.post('/:collection', function(req, res) { 
    var object = req.body;
    var collection = req.params.collection;

    var callback = function(object) {
	dbDriver.create(collection, object, function(err,docs) {
            if (err) { res.send(400, err); } 
            else {
		var wrapped_id = {};
		wrapped_id[collection.slice(0, -1) + '_id'] = docs._id;
		res.send(201, wrapped_id);
	    }
	});
    };


    // search for related incidents
    if (collection === "reports") {
	var query = {
	    status: "active",
	    "region": object.region
	};
	dbDriver.findAll("incidents", query,  function(error, objs) { 
    	    if (error) { console.log(error); } 
	    else if (objs.length === 0) {
		var incident = {
		    region: object.region,
		    time: object.time,
		    lat: object.lat,
		    lon: object.lon,
		    radius: DEFAULT_RADIUS,
		    report_count: 1,
		    status: "active",
		    level: "warning",
		    message: "An incident may have occurred in " + object.region
		};
		dbDriver.create("incidents", incident, function(err,docs) {
		    object.incident_id = docs._id;
		    callback(object);
		});
	    } else {
		var incident = objs[0];
		object.incident_id = incident._id;
		incident.report_count++;
		dbDriver.update("incidents", incident,
				incident._id, function(err, docs) {
		    callback(object);
		});
	    }
	});
    } else {
	callback(object);
    }
});

app.put('/:collection/:entity', function(req, res) { 
    var params = req.params;
    var entity = params.entity;
    var collection = params.collection;
    if (entity) {
	dbDriver.update(collection, req.body, entity, function(error, objs) {
            if (error) { res.send(400, error); }
            else { res.send(200, objs); } 
	});
    } else {
	var error = { "message" : "Cannot PUT a whole collection" };
	res.send(400, error);
    }
});

app.use(function (req,res) { 
    res.render('404', {url:req.url}); 
});

http.createServer(app).listen(app.get('port'), function(){
    console.log('Express server listening on port ' + app.get('port'));
});
