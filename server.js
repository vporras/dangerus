//Lets define a port we want to listen to
const PORT=80; 

// var dispatcher = require('httpdispatcher');

// //Lets require/import the HTTP module
// var http = require('http');


// //Lets use our dispatcher
// function handleRequest(request, response){
//     try {
//         //log the request on console
//         console.log(request.url);
//         //Disptach
//         dispatcher.dispatch(request, response);
//     } catch(err) {
//         console.log(err);
//     }
// }

// //For all your static (js/css/images/etc.) set the directory name (relative path).
// dispatcher.setStatic('resources');

// //Display the dashboard  
// dispatcher.onGet("/page1", function(req, res) {
//     res.writeHead(200, {'Content-Type': 'text/plain'});
//     res.end('Page One');
// });    

// //A sample POST request
// dispatcher.onPost("/post1", function(req, res) {
//     res.writeHead(200, {'Content-Type': 'text/plain'});
//     res.end('Got Post Data');
// });

//Create a server
//var server = http.createServer(handleRequest);

var express = require('express');
 
var server = express();
server.use(express.static(__dirname + '/www'));

//Lets start our server
server.listen(PORT, function(){
    //Callback triggered when server is successfully listening. Hurray!
    console.log("Server listening on: http://178.62.84.14:%s", PORT);
});
