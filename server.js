//Lets define a port we want to listen to
const PORT = process.argv[2] || 80;

var http = require('http'),
express = require('express'),
path = require('path'),
MongoClient = require('mongodb').MongoClient,
dbDriver = require('./dbDriver').dbDriver;;

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

app.use(express.static(path.join(__dirname, 'public')));

app.get('/', function (req, res) {
    res.send('<html><body><h1>Welcome to Safety Circle!</h1></body></html>');
});

app.get('/:collection', function(req, res) { 
    var params = req.params;
    var query = {};
    var key;
    for (key in req.query)
	if (key.match(/\w+/))
	    query[key] = req.query[key];
    console.log(query);

    dbDriver.findAll(req.params.collection, query, function(error, objs) { 
    	if (error) { res.send(400, error); } 
	else { 
	    if (req.accepts('html')) { 
    	        res.render('data',{objects: objs, collection: req.params.collection}); 
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
    dbDriver.create(collection, object, function(err,docs) {
        if (err) { res.send(400, err); } 
        else {
	    var wrapped_id = {};
	    wrapped_id[collection.slice(0, -1) + '_id'] = docs._id;
	    res.send(201, wrapped_id);
	} 
    });
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
