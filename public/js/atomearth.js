window.addEvent('domready', function(){
	var statusarea = $('startstop');
	var periodical;
	
	var update = function() {
		
	}
	function updatestate() {
		var state = $('statestatus').get('value');
		if ( state == "false" ) {
			statusarea.morph({
				'duration': 1500,
				'opacity': 1,
				'background-color': '#FF0000'
			});
		}
		if ( state == "true" ) {
			statusarea.morph({
				'duration': 1500,
				'opacity': 1,
				'background-color': '#00FF00'
			});
		}
	}
	
	$('startstop').addEvent('click', function(){
		console.log('click!');
		 var req = new Request({url:'/capture',
			onRequest: function() {
				statusarea.morph({
					'duration': 500,
					'opacity': 1,
					'background-color': '#FFFF00'
				});	
			},
			onSuccess: function(txt) {
				$('statestatus').set('value', txt);
				updatestate();
			},
			onFailure: function() {
			}
		}).send();
	});
	
	updatestate();
});



          