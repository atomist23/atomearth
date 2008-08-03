module GA
  class Tom
    def setup
      gems = ['yaml', 'json', 'geoip_city', 'pcaplet', 'ipaddr', 'logger']
  
      gems.each do |gem|
        require gem
      end
  
      Dir.glob("lib/geoatom/*").each do |me|
        require me
      end
    
      config = Conf.new
      
      @log = config.logfile
      @log.info('Config') { "Loaded..." }
      
      @log.info('Capture') { "Initializing..." }
      Capture.new(config)
    end
    #@hostlogger = Stats.new
  end
end


