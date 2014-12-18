require 'socket'

module HerokuHook
  # Class used to manage ports for deployments
  class PortHandler
    def self.free_port
      socket = Socket.new(:INET, :STREAM, 0)
      socket.bind(Addrinfo.tcp('0.0.0.0', 0))
      port = socket.local_address.ip_port
      socket.close
      port
    end

    def initialize(config)
      @ports_path = config.ports_directory
      @secure_following_ports = config.secure_following_ports.to_i
    end

    def raw_free_port
      self.class.free_port
    end

    def raw_taken_ports
      Dir.glob(File.join(@ports_path, '*.port')).map { |file| File.read(file).strip.to_i }.sort
    end

    def taken_ports
      raw_taken_ports.map { |taken_port| with_secured_ports(taken_port) }.flatten.uniq.sort
    end

    def pull
      port = raw_free_port until free?(port)
      port
    end

    def store(name, port = nil)
      fail ArgumentError, 'This port is alredy used' unless !port || free?(port)
      port = pull unless port
      File.open(File.join(@ports_path, "#{name}.port"), 'w') { |file| file.write(port.to_s) }
    end

    private

    def with_secured_ports(port)
      (0..@secure_following_ports).map { |ranger| ranger * 100 + port }
    end

    def free?(port)
      (1025..64_000).include?(port) && !taken_ports.include?(port)
    end
  end
end
