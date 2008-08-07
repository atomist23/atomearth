var LiveGauges = new Class({	
	//initialization

	initialize: function() {
		this.capturing = false;
		this.createElements();
	},

	//creates the box and percentage elements
	createElements: function() {		
		var box = new Element('div', {'id': 'load_box'} );
		var percent = new Element('div', {'id': 'load_percent' });
		percent.inject(box);
		box.inject('load');
	},

	//calculates width in pixels from percentage
	calculate: function(percentage) {
		boxwidth = $('load_box').getStyle('width').replace('px','');
		return (boxwidth * (percentage / 100)).toInt();
	},

	//animates the change in percentage
	animate: function(percent) {
		var morphtopx = this.calculate(percent.toInt());	
		$('load_percent').set('morph', { duration: 1000, link:'cancel' }).morph({width:morphtopx});
		$('load_percent').set('text', percent + '%');	
	},

	//sets the percentage from its current state to desired percentage
	setpercent: function(percent) {
		this.animate(percent);
	},
	
	setstats: function(stats) {
		$('total').set('text', stats.total);
		$('last').set('text', stats.last);
		$('high').set('text', stats.high);
		$('average').set('text', stats.average);
	},
	setbar: function(color) {
		$('startstop').morph({
			'duration': 1500,
			'opacity': 1,
			'background-color': color
		});
	},
	setgauge: function(value, gauge, dir) {
		this.set(value);
	},
	
	state: function(status) {		
		if (status != this.capturing) {
			if ( status == true)
				{
					this.setbar("#00FF00");
				}
			else if ( status == false)
				{
					this.setbar("#FF0000");
				}
				this.capturing = status;	
		}
	}
});

		
	window.addEvent('domready', function(){		
		var pb = new LiveGauges();

		function updateTime() {
				var currentTime = new Date();

				dispMinutes = currentTime.getMinutes();
				if (dispMinutes < 10) {
					dispMinutes = "0" + dispMinutes;
				}
				disptime = currentTime.getHours() + ':' + dispMinutes;
				$('headertime').set('text', disptime);
		}
		
		function ajaxStats() {
			var request = new Request.JSON(
				{url: "/info",
				onComplete: function(json) {
					var stats = json.atomearth.stats;
					var state = json.atomearth.capturing;					
					pb.setpercent(stats.percent);
					//pb.setpercent(50);
					
					pb.setstats(stats);
					pb.state(state);
					//console.log(json);
					//var cap = pb.getstate();
					//console.log(cap);
					//pb.setstate(state);
					}
				}).send();
			//getData('cpu');
			//getData('qaverage');
			//getData('state');
			updateTime();
		}
			
		ajaxStats.periodical(1000);
		
		var zTables = new ZebraTables('zebra');

		$('startstop').addEvent('click', function(){
			var req = new Request({url:'/capture',
			onRequest: function() {
				pb.setbar("#FFFF00");
			}}).send();
		});
	});
	
          