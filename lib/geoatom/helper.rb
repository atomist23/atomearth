def is_intnet(ip)
  p = IPAddr
  return false if GeoAtom::CONF.intnets.each{ |i| return true if p.new(i).include?(p.new(ip)) }
end
