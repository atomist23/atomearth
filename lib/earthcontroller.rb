# This is the controller for ramaze
class MainController < Ramaze::Controller
  # Load GEO Geo IP City Database
  GEO = GeoIPCity::Database.new(CONFIG.geoip)
  # Initialize the atomearth capture model for ramaze to access
  CAP = AtomEarth::Capture.new
  
  def index
    # Index page /
    page
  end
  
  def info
    # Stats in json format for the realtime statistics
    CAP.stats
  end

  def capture
    # Start / Stop capture toggle via json call
    CAP.state ? @capthread = CAP.stop : CAP.start
    CAP.state
  end

  def feed
    # Return a XML/KML feed for google earth
    feed = getfeed
    response['Content-Type'] = 'text/xml'
    respond feed
  end
  
  def error
    # Errorhandler
    @error = Ramaze::Dispatcher::Error.current
    %{
      <?xml version="1.0" ?>
      <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN"
      	"http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
      <html xmlns="http://www.w3.org/1999/xhtml">
      <head>
      	<title>AtomEarth Earth</title>
      	<script type="text/javascript" src="/jscript/mootools"></script>
      	<script type="text/javascript" src="/jscript/moomore"></script>
      	<script type="text/javascript" src="/jscript/error"></script>
      	<link rel="stylesheet" href="/stylesheet" type="text/css"/>
      </head>
      <body>
      	<div id="error" class="wrapper">
          <a id="error_toggle" name="error_toggle" href="#"><h1>Error: #{@error.message}</h1></a>
          <div id="error_slide">
            #{@error.backtrace.join('<br/>')}
          </div>
    		</div>
    		<div class="footer" id="footer">
          #{CAP.version}  
        </div>
      </body>
      </html>
    }
  end
  
  def stylesheet
    # Return the css stylesheet /stylesheet
    response['Content-Type'] = 'text/css'
    respond css
  end
  
  def jscript name
    # Return javascript /jscript/
    response['Content-Type'] = 'text/javascript'
    respond javascript(name)
  end
  
  def img name
    # Return a png image /img/
    response['Content-Type'] = 'image/png'
    respond image(name)
  end
  
  
  private

  def page
    # Render the default index page
    %{
      <?xml version="1.0" ?>
      <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN"
      	"http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
      <html xmlns="http://www.w3.org/1999/xhtml">
      <head>
      	<title>AtomEarth Earth</title>
      	<script type="text/javascript" src="/jscript/mootools"></script>
      	<script type="text/javascript" src="/jscript/atomearth"></script>
      	<script type="text/javascript" src="/jscript/zebra"></script>
      	<link rel="stylesheet" href="/stylesheet" type="text/css"/>

      </head>
      <body>
      		<div id="main" class="wrapper">
    			  <table id="maintable">
      			  <thead>
      			    <tr id="logotr"><th colspan="2"><img src="/img/logo" alt="AtomEarth Live"></img></th></tr>
        			  <tr id="labeltr"><th>STATS</th><th>SETTINGS</th></tr>
      			  </thead>
      			  <tbody>
        			  <tr id="infotr">
        			    <td VALIGN="TOP">
          			    <table class="zebra" cellpadding="0" cellspacing="0" id="infotable" summary="Infotable with live statistics">
        							<thead>
        								<tr><th>Item</th><th>Value</th></tr>
        							</thead>
        							<tbody>
        							  <tr><td>Current Time</td><td id="headertime"></td></tr>
        							  <tr><td>Queries Total</td><td id="total"></td></tr>
        								<tr><td>Queries Last</td><td id="last"></td></tr>
        								<tr><td>Queries High</td><td id="high"></td></tr>
        								<tr><td>Queries Average</td><td id="average"></td></tr>
        							</tbody>
        						</table>
        					</td>
        			    <td VALIGN="TOP">
        					  <table class="zebra" cellpadding="0" cellspacing="0" id="configtable" summary="Configuration settings">
        							<thead>
        								<tr><th>Option</th><th>Setting</th></tr>
        							</thead>
        							<tbody>
        								<tr><td>Longitude</td><td>#{CONFIG.lat}</td></tr>
        								<tr><td>Latitude</td><td>#{CONFIG.long}</td></tr>
        								<tr><td>Capture</td><td>#{CONFIG.device}</td></tr>
        								<tr><td>Hostname</td><td>#{CONFIG.host}</td></tr>
        								<tr><td>KML Size</td><td>#{CONFIG.size}</td></tr>
        								<tr><td>Feedurl</td><td>/feed</td></tr>
        							</tbody>
        						</table>
        					</td>
        				</tr>
        				<tr id="starttr">
          				<td colspan="2">
          				  <div id="load"></div>
        						<div id="startstop">
        							<center><b>START / STOP</b></center>
        							<input value="unknown" type="hidden" id="statestatus"></input>
        						</div>
        					</td>
      				  </tr>
      				  <tr class="footer">
      				    <td colspan="2">
      				      #{CAP.version}
                  </td>
                </tr>
    			    </tbody>
    		    </table>
      		</div>
      </body>
      </html>
    }
  end
  
  def kmlheader(feedname)
    # KML Header for the kml feed
    %{
      <kml xmlns:atom="http://www.w3.org/2005/Atom" xmlns="http://earth.google.com/kml/2.2">
        <Document>
          <name>#{feedname}</name>
          <Folder>
    }
  end
  
  def kmlstyle
    # KML Style Element for the kml feed
  %{
    <Style id="myStyle">
      <PolyStyle>
        <color>ffff0000</color>
        <outline>0</outline>
      </PolyStyle>
    </Style>
  }
  end
  
  def kmlfooter
    # KML Footer for the kml feed
  %{
      </Folder>
      </Document>
      </kml>
    }
  end
  
  def kmlpoint(geodata, data)
    # KML Waypoint for the kml feed
  %{
    <Placemark>
      <name>#{data[3]}</name>
      <description>#{placeinfo(geodata, data)}</description>
      <Style>
        <IconStyle>
          <Icon>
            <href>root://icons/palette-10.png</href>
          </Icon>
        </IconStyle>
      </Style> 
      <Point>
        <coordinates>#{geodata[:longitude]},#{geodata[:latitude]},0</coordinates>
      </Point>
    </Placemark>
  }
  end
  
  def kmlline(geodata, data)
    # KML Line between 2 places for kml feed
  %{
    <Placemark>
    <name>#{data[3]}</name>
    <description>#{placeinfo(geodata, data)}</description>   
    <Style>
      <LineStyle>
        <color>ff33ff00</color>
        <width>2</width>
      </LineStyle>
    </Style>
      <LineString>
        <tessellate>1</tessellate>
        <coordinates> #{geodata[:longitude]},#{geodata[:latitude]},2357           
        #{CONFIG.lat},#{CONFIG.long},2357 </coordinates>
      </LineString>
    </Placemark>
  }
  end
  
  def placeinfo(geodata, data)
    # Generate the place info html bubble
    out = Array.new
    out << "#{data[1]}<br/>"
    geodata.each do |x, y|
      out << "#{x} - #{y}<br/>"
    end
    return out.to_s
  end
    
  def getfeed
    # Return the kml feed
    feed = Array.new
    feed << kmlheader("Atomearth Feed Live")
    
    c = 0
    CAP.urls.each do |data|
      unless data[0]
        if c > CONFIG.size
          break
        end
        c += 1
        feed << kmlpoint(GEO.look_up(data[2]), data)
        feed << kmlline(GEO.look_up(data[2]), data)
      end
    end
    feed << kmlfooter
    return feed.to_s
  end
  
  def css
    # Default CSS
    %{body { background-color:#DEDEDE; color:#222222; font-family:Arial,Helvetica,Sans-serif; font-size:13px; line-height:1.5; margin: 20px 0 0 0; padding: 0px; }
table#maintable { background-color:#000033; border:1px solid #555555; margin: 0px; padding: 0px; width:500px }
div#startstop {	background-color:#FFAA00; border-top:3px solid #999; height:26px; width:100%; }
tr#infotr { background: #FEFEFE; }
tr#labeltr { background: #FFFF00; }
tr#starttr { background: #9A9A9A; height: 50px; }
a:hover, a:active { color:#D15227; }
a:link, a:visited { color:#3D4D5B; }
#load_box { width: 100%; height:20px; }
#load_percent { background:#FFD700; height:20px; text-align: center;}
.zebra { width: 250px; }
.highlight { background:#d5fcdc; }
.even { background:#fff; }
.mo	{ background:#e3f1fb; }
.odd { background:#eee; }
.zebra th { padding:5px; background:#ddd; border-bottom:1px solid #999; text-align:left; font-weight:bold; }
.zebra td { padding:5px 20px 5px 5px; border-bottom:1px solid #ddd; }
.wrapper { margin-left:auto; margin-right:auto; }
#main { width: 600px; }
#error { border:1px solid #555555; background: #ff5555; width: 600px; }
#error h1 { font-size:21px; margin:0; padding:0; text-align: center; }
#error_slide { background:#FAFAFA none repeat scroll 0 0; font-size:10px; padding:5px; }
.footer { background:#000055 none repeat scroll 0 0; color:#FFF00F; font-weight:bold; height:20px; text-align:right; }
#footer { margin-left:auto; margin-right:auto; width:600px;}
      }
    end
    
    def javascript(route)
      # Javascript generator
      case route
      when 'atomearth':
        %{
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
        }
    when "zebra":
      %{
        var ZebraTables = new Class({
        	//initialization
        	initialize: function(table_class) {

        		//add table shading
        		$$('table.' + table_class + ' tr').each(function(el,i) {

        			//do regular shading
        			var _class = i % 2 ? 'even' : 'odd'; el.addClass(_class);

        			//do mouseover
        			el.addEvent('mouseenter',function() { if(!el.hasClass('highlight')) { el.addClass('mo').removeClass(_class); } });

        			//do mouseout
        			el.addEvent('mouseleave',function() { if(!el.hasClass('highlight')) { el.removeClass('mo').addClass(_class); } });

        			//do click
        			el.addEvent('click',function() {
        				//click off
        				if(el.hasClass('highlight'))
        				{
        					el.removeClass('highlight').addClass(_class);
        				}
        				//click on
        				else
        				{
        					el.removeClass(_class).removeClass('mo').addClass('highlight');
        				}
        			});

        		});
        	}
        });
      }
    when "error":
      %{
        window.addEvent('domready', function(){	
        	var errorSlide = new Fx.Slide('error_slide').hide();	

        	$('error_toggle').addEvent('click', function(e){
        		e.stop();
        		errorSlide.toggle();
        	});
        });  
      }
    when "mootools":
      IO.read(File.join(File.dirname(__FILE__), '..', 'dist', 'mootools.js'))
    when "moomore":
      IO.read(File.join(File.dirname(__FILE__), '..', 'dist', 'mootools-misc.js'))
    end
  end
  
  def image(name)
    # Image generator
    case name
    when "logo":
      IO.read(File.join(File.dirname(__FILE__), '..', 'dist', 'atomearth.png'))
    end
  end
end