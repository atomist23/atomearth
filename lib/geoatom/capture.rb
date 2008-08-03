class Capture

  attr_accessor :urls

  def initialize
    #@log.info('Capture') { "Initializing" }    
    @urls = Livebuffer.new(150)
    @running = false
    @count = Query.new
  end

  def state
    @running = @capthread.alive? if @capthread
    return @running
  end
  
  def current
    @urls.to_a
  end

  def stats
    @count.avg.to_json
  end

  def stop
    Thread.kill(@capthread)
  end

  def process(pkt)
    data = pkt.tcp_data
    if data {
    #@log.info('Datacap') { "Datapacket received" } if GeoAtom::CONF.logverbose
    request_line, data = data.split("\r\n", 2)
    next unless data
    next unless request_line =~ /^GET\s+(\S+)/ 
    path = $1
    headers = data.split("\r\n\r\n", 2).first.split("\r\n")
    headers = headers.map { |line| line.split(': ', 2) }.flatten
    next unless headers.length % 2 == 0
    #@log.info('Datacap') { "Valid header decoded" } if GeoAtom::CONF.logverbose
    headers = Hash[*headers]

    host = headers['Host'] || pkt.dst.to_s
    host << ":#{pkt.dst_port}" if pkt.dport != 80
    #@log.info('Datacap') { "#{host} request extracted" } if GeoAtom::CONF.logverbose

    srcpktip = pkt.src.to_num_s
    data = Hash.new
    data = {
      :intsrcip => is_intnet(srcpktip),
      :srchost => pkt.src.to_s, 
      :srcip => srcpktip, 
      :dsthost => host, 
      :dstip => pkt.dst.to_num_s, 
      :url => path }
      @urls << data
      @count.add
      #puts "Ring!"
      #@log.info('Datacap') { "Inserting #{data} into urls" } if GeoAtom::CONF.logverbose
    }
  end
  def start
      #@log.info('Datacap') { "Setting up capture" }
      httpdump = Pcaplet.new GeoAtom::CONF.capdev
      #@log.info('Datacap') { "Capture for #{GeoAtom::CONF.capdev} started" }

      filter = Pcap::Filter.new 'tcp and dst port 80', httpdump.capture
      #@log.info('Datacap') { "Filter loaded" }

      httpdump.add_filter filter      
      
      @capthread = fork {
        httpdump.each_packet {|pkt| process(pkt) }
      }
    end
  end