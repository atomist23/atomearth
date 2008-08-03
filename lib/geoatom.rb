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
    if @cap == nil
      puts "Setting up GeoAtom"
      Capture.new
    end
  end
end

