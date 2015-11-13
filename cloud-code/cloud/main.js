
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");
});

Parse.Cloud.afterSave("Snap", function(request) {
	if (request.object.existed() == false) {
	  var toUser = request.object.get('destination');
	  var fromUser = request.object.get('sender');
	  fromUser.fetch({
	  	success: function(user) {
			  var pushQuery = new Parse.Query(Parse.Installation);
			  pushQuery.equalTo('user', toUser);
			    
			  Parse.Push.send({
			    where: pushQuery, // Set our Installation query
			    data: {
			      alert: "You've got a new snap from " + user.get('username'),
			      sound: "default"
			    }
			  }, {
			    success: function() {
			      // Push was successful
			    },
			    error: function(error) {
			      throw "Got an error " + error.code + " : " + error.message;
			    }
			  });
		  	},
		error: function(error) {
				throw "Got an error fetching sender " + error.code + ": " + error.message;
		  	}
	  	});	  
	}
});