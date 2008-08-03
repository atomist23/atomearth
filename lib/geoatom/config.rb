class Conf
    def initialize
        @config = open(Dir.pwd+'/config/geoatom.yaml') { |f| YAML.load f }
    end
    def loaded
      true
    end
    def hostlat
        @config['hostdest']['latitude']
    end
    def hostlong
        @config['hostdest']['longitude']
    end
    def hostname
        @config['hostdest']['name']
    end
    def kmlsize
        @config['kml']['size']
    end
    def kmlgzip
        @config['kml']['gzip']
    end
    def kmllogfile
        @config['kml']['log']
    end
    def capdev
        case @config['capture']['type']
        when 'file'
          "-r #{@config['capture']['device']}"
        when 'interface'
          "-i #{@config['capture']['device']}"
        end
    end
    def logverbose
      @config['log']['verbose']
    end
    def logfile
      Logger.new(@config['log']['file']) if @config['log']['enable']
    end
    def intnets
      ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
    end
end

