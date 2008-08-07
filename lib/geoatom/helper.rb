def is_intnet(ip)
  p = IPAddr
  return false if GeoAtom::CONF.intnets.each{ |i| return true if p.new(i).include?(p.new(ip)) }
end

def getload
  return CPU.load_avg[0].to_s.split('.')[0]
end
  