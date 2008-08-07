class Livebuffer < Array
  def initialize(size)
    super()
    @size = size
  end
  
  def <<(obj)
    super
    shift if length > @size
  end
end

class Query
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
    #puts "total #{@total} requests #{@requests} high #{@high} average #{@average} last #{@last} percent #{@percent}"
    @last = @requests
    @requests = 0
  end
  
  def get
    return {"total" => @total, "high" => @high, "last" => @last, "average" => @average, "percent" => @percent}
  end
end