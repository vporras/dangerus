var ObjectID = require('mongodb').ObjectID;

dbDriver = function(db) {
    this.db = db;
};

dbDriver.prototype.getCollection = function(collectionName, callback) {
  this.db.collection(collectionName, function(error, the_collection) {
    if( error ) callback(error);
    else callback(null, the_collection);
  });
};

dbDriver.prototype.findAll = function(collectionName, callback) {
    this.getCollection(collectionName, function(error, the_collection) { //A
      if(error)
	  callback(error);
      else {
        the_collection.find().toArray(function(error, results) { //B
          if( error ) callback(error);
          else callback(null, results);
        });
      }
    });
};

dbDriver.prototype.get = function(collectionName, id, callback) { //A
    this.getCollection(collectionName, function(error, the_collection) {
        if (error)
	    callback(error);
        else {
            var checkForHexRegExp = new RegExp("^[0-9a-fA-F]{24}$"); //B
            if (!checkForHexRegExp.test(id)) callback({error: "invalid id"});
            else the_collection.findOne({'_id':ObjectID(id)}, function(error,doc) {
                if (error) callback(error);
                else callback(null, doc);
            });
        }
    });
};

dbDriver.prototype.create = function(collectionName, obj, callback) {
    this.getCollection(collectionName, function(error, the_collection) {
      if (error)
	  callback(error)
      else {
          the_collection.insert(obj, function() {
	      console.log(obj);
              callback(null, obj);
          });
      }
    });
};

dbDriver.prototype.update = function(collectionName, obj, entityId, callback) {
    this.getCollection(collectionName, function(error, the_collection) {
        if (error) callback(error);
        else {
            obj._id = ObjectID(entityId);
            obj.updated_at = new Date();
            the_collection.save(obj, function(error,doc) {
                if (error) callback(error);
                else callback(null, obj);
            });
        }
    });
};


exports.dbDriver = dbDriver;
