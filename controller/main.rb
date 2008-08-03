class MainController < Ramaze::Controller

  def index
    page
  end

  def checkstate
    CAP.state
  end
  
  def capture
    CAP.state ? @capthread = CAP.stop : CAP.start
    CAP.state
  end
  
  def stats
    CAP.stats
  end
  
  def geturls
    CAP.current
  end
  
  def feed
    feed = getfeed
    response['Content-Type'] = 'text/xml'
    respond feed
  end
  
  def getfeed
    feed = Array.new
    feed << kmlheader("Atomearth Feed Live")
    
    CAP.current.each do |data|
      unless data[:intsrcip]
        feed << kmlplacemark(GEO.look_up(data[:srcip]), data)
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
        <title>GeoAtom Earth</title>
      	<script type="text/javascript" src="/js/mootools.js"></script>
      	<script type="text/javascript" src="/js/atomearth.js"></script>
        <link rel="stylesheet" href="/css/atomearth.css" type="text/css"/>
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
      			<input value="#{CAP.state}" type="hidden" id="statestatus"></input>
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
          <starttime>#{Time.now()}</starttime>
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
      <stoptime>#{Time.now()}</stoptime>
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