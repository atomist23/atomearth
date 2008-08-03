# Default url mappings are:
#  a controller called Main is mapped on the root of the site: /
#  a controller called Something is mapped on: /something
# If you want to override this, add a line like this inside the class
#  map '/otherurl'
# this will force the controller to be mounted on: /otherurl
#data = data.merge(@geo.look_up(srcpktip)) unless is_intnet(srcpktip)  

class MainController < Ramaze::Controller
  helper :GAtom
  @@geo = GeoIPCity::Database.new('data/GeoLiteCity.dat')  
  
  def index
    @title = "Atomearth"
    @capstate = @@cap.state
    page
  end

  def checkstate
    @@cap.state
  end
  
  def capture
    @@cap.state ? @capthread = @@cap.stop : @@cap.run
    @@cap.state
  end
  
  def stats
    @@cap.stats
  end
  
  def geturls
    @@cap.current
  end
  
  def feed
    feed = getfeed
    response['Content-Type'] = 'text/xml'
    respond feed
  end
  
  def getfeed
    feed = Array.new
    feed << kmlheader("Atomearth Feed Live")
    
    @@cap.current.each do |data|
      unless data[:intsrcip]
        feed << kmlplacemark(@@geo.look_up(data[:srcip]), data)
      end
    end
    feed << kmlfooter
    return feed.to_s
  end
  
  def page
    %{
    <?xml version="1.0" ?>
    <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN"
      "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
    <html xmlns="http://www.w3.org/1999/xhtml">
      <head>
        <title>#{@title}</title>
      	<script type="text/javascript" src="js/mootools.js"></script>
      	<script type="text/javascript" src="js/atomearth.js"></script>
        <link rel="stylesheet" href="css/atomearth.css" type="text/css"/>
      </head>
      <body>
    	<div id="container">
    		<div id="wrapper">
      		<div id="header">
      		      <div id="logo">
      		        AtomEarth Live
      		      </div>
      		      <div id="time">
      		        <span id="headertime">#{Time.now()}</span>
      		      </div
          </div>
          <div id="main">
            <div id="livestats">
            </div>
          </div>
          <div id="footer">
      		<div id="startstop">
      			<input value="#{@capstate}" type="hidden" id="statestatus"></input>
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
      </Document>
      </kml>
    }
  end
  
  def kmlplacemark(geodata, data)
  %{
    <Placemark>
      <name>#{data[:dsthost]}</name>
      <description>#{placeinfo(geodata, data)}</description>
      <Point>
        <coordinates>#{geodata[:longitude]},#{geodata[:latitude]},0</coordinates>
      </Point>
    </Placemark>
  }
  end
  
  def placeinfo(geodata, data)
    out = Array.new
    out << "#{data[:dsthost]}<br/>"
    #out << "#{data[:url]}<br/>"
    geodata.each do |x, y|
      out << "#{x} - #{y}<br/>"
    end
    return out.to_s
  end
end