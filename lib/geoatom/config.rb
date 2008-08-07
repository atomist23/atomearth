class Conf
    def initialize
        @config = open(Dir.pwd+'/config/atomearth.yaml') { |f| YAML.load f }
    end
    def loaded
      true
    end
    def geoipdb
        @config['setup']['geoipdb']
    end
    def hostlat
        @config['capturelocation']['latitude']
    end
    def hostlong
        @config['capturelocation']['longitude']
    end
    def hostname
        @config['capturelocation']['name']
    end
    def intnets
      @config['capturelocation']['networks']
    end
    def kmlsize
        @config['kml']['size']
    end
    def kmlgzip
        @config['kml']['gzip']
    end
    def capdev
        case @config['capture']['type']
        when 'file'
          "-r #{@config['capture']['device']}"
        when 'interface'
          "-i #{@config['capture']['device']}"
        end
    end
end

