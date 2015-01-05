module HerokuHook
  # Sends given strings to standard output
  class Displayer
    def self.out(str = '', stream = $stdout)
      stream.write "\e[1G" + str
      stream.flush
    end

    def self.outln(str = '', stream = $stdout)
      stream.puts "\e[1G" + str
      stream.flush
    end

    def self.raw_out(str = '', stream = $stdout)
      stream.write str
      stream.flush
    end

    def self.raw_outln(str = '', stream = $stdout)
      stream.puts str
      stream.flush
    end
  end
end
