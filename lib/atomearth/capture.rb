module AtomEarth
  
  # Capture class
  class Capture
    
    attr_accessor :urls, :count, :alive, :capfork

    def initialize
      require 'pcaplet'
      # Livebuffer for storing location urls
      @urls = Livebuffer.new(150)
      @count = Query.new
      # When it initializes, capture thread is not running
      @alive = false
    end
    
    def version
     return "#{NAME} #{VERSION[0]}.#{VERSION[1]}.#{VERSION[2]} by #{AUTHOR} <#{EMAIL}>"
    end

    def state
      # Return if we're capturing or not
      begin
        return @capthread.alive?
      rescue
        return false
      end
    end

    def stats
      # Return statistics in json format
      return {"atomearth" => {"stats" => @count.get, "capturing" => @alive}}.to_json
    end

    def stop
      # Stop capturing
      Thread.kill(@capthread)
      Process.kill("TERM", @capfork.to_i)
    end

    def is_intnet(ip)
      # Figure out if this is an internal blackhole ip
      p = IPAddr
      return false if CONFIG.intnet.each{ |i| return true if p.new(i).include?(p.new(ip)) }
    end

    def start
      # Start capturing
      rd, wr = IO.pipe

      # Lets fork
      @capfork = fork do
        Signal.trap("TERM") { exit }
        
        rd.close

        # Get capture device from config
        httpdump = Pcaplet.new CONFIG.device

        # Filter for capture
        filter = Pcap::Filter.new 'tcp and dst port 80', httpdump.capture
        httpdump.add_filter filter

        # This is the main capture loop analyzing the packets
        httpdump.each_packet do |pkt|
          data = pkt.tcp_data
          next unless data
          request_line, data = data.split("\r\n", 2)
          next unless data
          next unless request_line =~ /^GET\s+(\S+)/
          path = $1
          next unless path =~ /.htm|.jsp|.asp|.cfm|.php|\/$/
          headers = data.split("\r\n\r\n", 2)
          next unless headers.first
          headers = headers.first.split("\r\n")
          headers = headers.map { |line| line.split(': ', 2) }.flatten
          next unless headers.length % 2 == 0
          headers = Hash[*headers]

          host = headers['Host'] || pkt.dst.to_s
          host << ":#{pkt.dst_port}" if pkt.dport != 80

          # And here we are sending the data to the capture thread for insertion into the buffer
          wr.puts [is_intnet(pkt.src.to_num_s), pkt.src.to_s, pkt.src.to_num_s, host, pkt.dst.to_num_s, path].inspect
        end      
        wr.close     
      end

      wr.close

      @capthread = Thread.start do
        # Capture thread. This will receive data from the fork and insert it into the urls buffer
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
        Process.kill("TERM", @capfork.to_i)
        @count.update
        @alive = false
      end
    end
  end
end