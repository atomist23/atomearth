module GeoAtom
  
  gems = ['yaml', 'json', 'geoip_city', 'pcaplet', 'ipaddr', 'logger']

  gems.each do |gem|
    require gem
  end
    
  Dir.glob("lib/geoatom/*").each do |me|
    require me
  end
  
  CONF = Conf.new

  def self.capsetup
    puts "Setting up GeoAtom"
    Capture.new()
  end
end

