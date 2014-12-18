require 'socket'

module HerokuHook
  # Class reponsible for various network handling operations
  class Networker
    def self.free_port
      socket = Socket.new(:INET, :STREAM, 0)
      socket.bind(Addrinfo.tcp('0.0.0.0', 0))
      port = socket.local_address.ip_port
      socket.close
      port
    end

    def self.restricted_free_port
      port = free_port until (1025..64_000).include?(port)
      port
    end
  end
end
