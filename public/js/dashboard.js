function loadIncident(id) {
    $.ajax(
	{ url: "dashboard/" + id,
	  dataType: "html",
	  success: function(result) {
	      $("#incident-container").html(result);
	      $("#submit-button").click(function() {
		  var status =  $("#status-active").is(':checked') ? "active" : "inactive";
		  var data = {
		      _id: id,
		      region: $("#region").val(),
		      time: $("#time").val(),
		      report_count: $("#report_count").val(),
		      status: status,
		      type: $("#type").val(),
		      subtype: $("#subtype").val(),
		      level: $("#level").val(),
		      radius: $("#radius").val() * 1,
		      lat: $("#lat").val() * 1.0,
		      lon: $("#lon").val() * 1.0,
		      message: $("#message").val(),
		      notes: $("#notes").val()
		  };
		  $.ajax({
		      url: "incidents/" + id,
		      type: "put",
		      dataType: "json",
		      data: data,
		      success: function(data) {
			  location.reload(true);
                      },
		      error: function(err) {
			  alert("changes FAILED to save");
			  console.log(err);
		      }
		  });
	      });
	  }
	});
}

var map;
$(document).ready(function() {
    $(".inc-row").click(function(e) {
	$(".inc-row").removeClass("selected");
	$(e.currentTarget).addClass("selected");
	loadIncident(e.currentTarget.id);
    });

    
    map = new GMaps({
	div: '#map',
	lat: 0,
	lng: 0,
	zoom: 2 
    });

    $("#marker-list").children().each(function(i) {
	var id = this.id;
	map.addMarker({
            lat: $(this).children(".lat").first().text() * 1.0,
            lng: $(this).children(".lon").first().text() * 1.0,
            title: $(this).children(".region").first().text(),
            click: function(e){
		loadIncident(id);
            }
      });
    });
});       
