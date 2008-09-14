module AtomEarth  
  NAME    = "AtomEarth"
  AUTHOR  = "Thomas Gallaway"
  EMAIL   = "atomist@gmail.com"
  VERSION = [0,0,2] unless defined?(AtomEarth::VERSION)

  class << self
            
    def loadconfig
      return OpenStruct.new(YAML.load_file("/etc/atomearth/config.yaml"))
    end
    
    def checkconfig      
      confpath = "/etc/atomearth"
      conffile = "/config.yaml"
      
      unless File.directory? confpath
        puts "Creating directory #{confpath}"
        Dir.mkdir(confpath)
        File.copy(File.dirname(__FILE__) + '/../dist/config.yaml', confpath + conffile)
        puts "Please edit /etc/atomearth/config.yaml"
        exit
      end

      unless File.exist? confpath + conffile
        File.copy(File.dirname(__FILE__) + '/../dist/config.yaml', confpath + conffile)
        puts "Please edit /etc/atomearth/config.yaml"
        exit
      end
    end

    def version
      return "#{NAME} #{VERSION[0]}.#{VERSION[1]}.#{VERSION[2]} by #{AUTHOR} <#{EMAIL}>"
    end

    def checkpid
      if File.file?(CONFIG.pid)
        pid = IO.read(CONFIG.pid).to_i
        begin
          pgid = Process.getpgid(pid)
          puts "#{NAME} is already running.... pid #{pid}"
          exit
        rescue
          puts "Deleting old pidfile for pid #{pid}"
          FileUtils.rm(CONFIG.pid)
        end
      end
    end

    def run!(cmd)
      case cmd
      when "run":
        checkpid
        require File.join(File.dirname(__FILE__), '..', 'lib', 'earthcontroller')
        Ramaze.start :adapter => CONFIG.adapter, :port => CONFIG.port
        exit
      when "start":
        checkpid
        daemon = self
        fork do
          Process.setsid
          exit if fork
          File.open(CONFIG.pid, "w") {|f| f.puts Process.pid}
          STDIN.reopen "/dev/null"
          STDOUT.reopen CONFIG.log ? CONFIG.log : "/dev/null", "a"
          STDERR.reopen STDOUT
          trap("TERM") {exit}
          
          require File.join(File.dirname(__FILE__), '..', 'lib', 'earthcontroller')
          Ramaze.start :adapter => CONFIG.adapter, :port => CONFIG.port
        end

        begin
          sleep 2
          pid = IO.read(CONFIG.pid)
        rescue
          sleep 2
          pid = IO.read(CONFIG.pid) if File.file?(CONFIG.pid)
        end
        puts "#{NAME} started with pid #{pid}" if pid
        puts CONFIG.log ? "Logging to #{CONFIG.log}" : "No logging enabled"
      when "stop": 
        if !File.file?(CONFIG.pid)
          puts "#{NAME} not running!"
          exit
        end

        pid = IO.read(CONFIG.pid).to_i
        Process.kill("TERM", pid)
        FileUtils.rm(CONFIG.pid)
        puts "Stopped AtomEarth with pid #{pid}"
        exit
      when "status":
        if File.file?(CONFIG.pid)
          pid = IO.read(CONFIG.pid).to_i
          begin
            pgid = Process.getpgid(pid)
            puts "#{NAME} running with pid #{pid}"
            exit
          rescue
            puts "#{NAME} not running!"
            exit
          end
        end
      when "version":
        puts AtomEarth.version
      end
    end
  end
end

begin
  require 'rubygems'
rescue
  puts "Please install rubygems"
  exit
end

gems = ['ftools', 'json', 'geoip_city', 'ipaddr', 'logger', 'yaml', 'json', 'ramaze']

gems.each do |gem|
  begin
    require gem
  rescue LoadError
    puts "Missing gem #{gem}"
    exit
  end
end

AtomEarth.checkconfig
CONFIG = AtomEarth.loadconfig

Dir.glob(File.dirname(__FILE__) + "/atomearth/*").each do |me|
  require me
end
