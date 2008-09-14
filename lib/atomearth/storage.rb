module AtomEarth
  class Livebuffer < Array
    # Livebuffer. Limit size via size
    def initialize(size)
      super()
      @size = size
    end
  
    def <<(obj)
      super
      shift if length > @size
    end
  end

  class Placemark
    attr_accessor :ip, :longitude, :latitude, :data

    def initialize
      @hits = 0
    end
  end

  class Placemarks
    def initialize
      @placemarks = Hash.new
    end
  
    def add(data)
      if @placemarks.has_key?(data.srcip)
        puts "Has"
      else
        @placemark = Placemark.new
        @placemark.ip = data.srcip
      end
    end
  end

  class Query
    # Generate the average for realtime gauges
    def initialize
      @requests = 0
      @last = 0
      @total = 0
      @average = 0
      @percent = 0
      @high = 1
    end
 
    def add
      @requests += 1
    end

    def update
      @total += @requests
      @high = @requests if @requests > @high
      @average = (@requests + @last) / 2
      @percent = (100 / @high) * @average
      @last = @requests
      @requests = 0
    end
  
    def get
      return {"total" => @total, "high" => @high, "last" => @last, "average" => @average, "percent" => @percent}
    end
  end
end