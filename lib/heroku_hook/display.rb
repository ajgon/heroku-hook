module HerokuHook
  # Sends given strings to standard output
  class Display
    def self.out(str = '')
      print "\e[1G" + str
    end

    def self.outln(str = '')
      puts "\e[1G" + str
    end

    def self.raw_out(str = '')
      print str
    end

    def self.raw_outln(str = '')
      puts str
    end
  end
end
