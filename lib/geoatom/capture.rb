class Capture

  def initialize
    @urls = Livebuffer.new(150)
    @count = Query.new
    @alive = false
  end

  def state
    if @capthread
      return @capthread.alive?
    else 
      return false
    end
  end

  def current
    @urls.to_a
  end

  def stats
    return {"atomearth" => {"stats" => @count.get, "capturing" => @alive}}.to_json
  end

  def stop
    Thread.kill(@capthread)
  end

  def start
    puts "starting"
      rd, wr = IO.pipe

      fork do
        rd.close

        httpdump = Pcaplet.new GeoAtom::CONF.capdev
        
        filter = Pcap::Filter.new 'tcp and dst port 80', httpdump.capture
        httpdump.add_filter filter

        httpdump.each_packet do |pkt|
          data = pkt.tcp_data
          next unless data
          request_line, data = data.split("\r\n", 2)
          next unless data
          next unless request_line =~ /^GET\s+(\S+)/
          path = $1
          next unless path =~ /.htm|.jsp|.asp|.cfm|.php|\/$/
          headers = data.split("\r\n\r\n", 2).first.split("\r\n")
          headers = headers.map { |line| line.split(': ', 2) }.flatten
          next unless headers.length % 2 == 0
          headers = Hash[*headers]

          host = headers['Host'] || pkt.dst.to_s
          host << ":#{pkt.dst_port}" if pkt.dport != 80

          wr.puts [is_intnet(pkt.src.to_num_s), pkt.src.to_s, pkt.src.to_num_s, host, pkt.dst.to_num_s, path].inspect
        end      
        wr.close     
      end

      wr.close

      @capthread = Thread.start do
        @alive = true
        until rd.eof? do
          line = rd.gets
          break if line.nil?
          @urls << eval(line)
          @count.add
        end
      end
      
      @updatethread = Thread.start do
        while @capthread.alive? do
          @count.update
          sleep 1
        end
        @count.update
        @alive = false
      end
    end
end
