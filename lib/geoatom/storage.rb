class Livebuffer < Array
  def initialize(size)
    super()
    #@log.info('Livebuffer') { "Initialized" }
    @size = size
  end
  
  def <<(obj)
    super
    shift if length > @size
    #@log.info('Livebuffer') { "Buffered #{obj}" } if GeoAtom::CONF.logverbose
  end
end

class Logbuffer < Array
    def initialize
      #@log = config.logfile
      #@log.info('Logbuffer') { "Initialized" }
      super()
    end
  
    def <<(obj)
      #@log.info('Logbuffer') { "Buffered #{obj}" } if GeoAtom::CONF.logverbose
      super
    end
end

class Query
  def initialize
    #@log = config.logfile
    #@log.info('Query') { "Initialized" }
    @requests = 0
    @timeslot = Time.now()
  end
 
  def add
    @requests += 1
    #@log.info('Query') { "Added 1 request" } if GeoAtom::CONF.logverbose
  end
  
  def avg
    duration = Time.now() - @timeslot
    requests = @requests
    @requests = 0
    @timeslot = Time.now()
    qps = requests / duration
    #@log.info('Query') { "Requests: #{@requests} and #{qps.to_i}/s" } if GeoAtom::CONF.logverbose
    return {'duration' => duration.to_i, 'requests' => requests, 'qps' => qps.to_i}
  end
end
    
class Stats < Array
    def initialize
      #@log = config.logfile
      #@log.info('Stats') { "Initialized" }
      super()
    end
  
    def <<(obj)
      #@log.info('Stats') { "Buffered #{obj}" } if GeoAtom::CONF.logverbose
      super
    end
end