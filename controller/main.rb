class MainController < Ramaze::Controller

  def index
    page
  end
  
  def info
    CAP.stats
  end

  def capture
    CAP.state ? @capthread = CAP.stop : CAP.start
    CAP.state
  end

  def feed
    feed = getfeed
    response['Content-Type'] = 'text/xml'
    respond feed
  end
  
  private

  def page
    %{
      <?xml version="1.0" ?>
      <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN"
      	"http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
      <html xmlns="http://www.w3.org/1999/xhtml">
      <head>
      	<title>GeoAtom Earth</title>
      	<script type="text/javascript" src="/js/mootools.js"></script>
      	<script type="text/javascript" src="/js/atomearth.js"></script>
      	<script type="text/javascript" src="/js/misc.js"></script>

      	<link rel="stylesheet" href="/css/atomearth.css" type="text/css"/>

      </head>
      <body>
      	<div id="container">
      		<div id="wrapper">
      			<div id="header">
      				<div id="logo">
      					<img src="atomearthlogo.png">
      				</div>
      			</div>
      			<div id="main">
      					<div id="leftstats"><h3>Stats</h3>
      						<table class="zebra" cellpadding="0" cellspacing="0" id="infotable">
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
      						<div id="load"></div>
      						<div id="startstop">
      							<center><b>START / STOP</b></center>
      							<input value="unknown" type="hidden" id="statestatus"></input>
      						</div>
      						<h3>Settings</h3>
      						<table  class="zebra" cellpadding="0" cellspacing="0" id="configtable">
      							<thead>
      								<tr><th>Option</th><th>Setting</th></tr>
      							</thead>
      							<tbody>
      								<tr><td>Root Longitude</td><td>#{GeoAtom::CONF.hostlat}</td></tr>
      								<tr><td>Root Latitude</td><td>#{GeoAtom::CONF.hostlong}</td></tr>
      								<tr><td>Capture Device</td><td>#{GeoAtom::CONF.capdev}</td></tr>
      								<tr><td>Hostname</td><td>#{GeoAtom::CONF.hostname}</td></tr>
      								<tr><td>KML Size</td><td>#{GeoAtom::CONF.kmlsize}</td></tr>
      								<tr><td>Google Earth Feed</td><td>/feed</td></tr>
      							</tbody>
      						</table>
      					</div>
      			</div>
      		</div>
      	</div>
      </body>
      </html>
    }
  end
  
  def kmlheader(feedname)
    %{
      <kml xmlns:atom="http://www.w3.org/2005/Atom" xmlns="http://earth.google.com/kml/2.2">
        <Document>
          <name>#{feedname}</name>
          <Folder>
    }
  end
  
  def kmlstyle
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
  %{
      </Folder>
      </Document>
      </kml>
    }
  end
  
  def kmlpoint(geodata, data)
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
        #{GeoAtom::CONF.hostlat},#{GeoAtom::CONF.hostlong},2357 </coordinates>
      </LineString>
    </Placemark>
  }
  end
  
  def placeinfo(geodata, data)
    out = Array.new
    out << "#{data[1]}<br/>"
    #out << "#{data[:url]}<br/>"
    geodata.each do |x, y|
      out << "#{x} - #{y}<br/>"
    end
    return out.to_s
  end
    
  def getfeed
    feed = Array.new
    feed << kmlheader("Atomearth Feed Live")
    
    c = 0
    CAP.current.each do |data|
      unless data[0]
        if c > GeoAtom::CONF.kmlsize
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
end