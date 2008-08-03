require 'rubygems'
require 'lib/geoatom'
CAP = GeoAtom.capsetup
GEO = GeoIPCity::Database.new('data/GeoLiteCity.dat')

require 'ramaze'
acquire __DIR__/:controller/'*'

Ramaze.start :adapter => :thin, :port => 7000