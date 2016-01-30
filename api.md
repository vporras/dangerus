API
===
Fields are not guaranteed to be present.

##Report
+ `location : `
++ `lat : float`
++ `lon : float`
++ `region : string`
+ `type : {"mass_shooting", "bombing", "natural_disaster", "other_major", "minor"}`
+ `subtype : {"flood", "fire", "earthquake", "robbery", "shooting"}`
+ `description : string`
+ `user_id : string`

###Example
    {
        "location" : {
            "lat" : 47.453,
            "lon" : -138.241,
            "region" : "london"
        },
	    "type" : "natural_disaster",
	    "subtype" : "flood",
        "description" : "the Thames is over the Eye!",
        "user_id" : "kjsfj234fh"
    }

##Report Response
+ `report_id : string`

###Example
    { "report_id" : "56acf8c7876ce4471df44f39" }

##Incident
+ `location : `
++ `lat : float`
++ `lon : float`
++ `region : string`
+ `radius : integer` (in meters)
+ `report_count : integer`
+ `level : {"warning", "emergency"}`
+ `message : string`
+ `incident_id : string`

###Example
    {
        "location" : {
            "lat" : 47.0,
            "lon" : -138.0,
            "region" : "london"
        },
        "radius" : 2000,
        "report_count" : 17,
        "level" : "warning",
        "message" : "The Thames mes may be flooding; stay clear of the river.",
        "incident_id" : "56abcb32424bcff22342"
    }
    

