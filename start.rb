Thread.abort_on_exception = true
require 'rubygems'
require 'lib/geoatom'

CAP = GeoAtom.capsetup
GEO = GeoIPCity::Database.new(GeoAtom::CONF.geoipdb)

require 'ramaze'
acquire __DIR__/:controller/'*'

Ramaze.start :adapter => :thin, :port => 7000