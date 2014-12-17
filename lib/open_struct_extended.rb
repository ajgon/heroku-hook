require 'ostruct'

# OpenStruct class patch for 1.9.x to be compatible with 2.0 (array operator)
class OpenStructExtended < OpenStruct
  def [](key)
    send(key)
  end

  def []=(key, value)
    send("#{key}=", value)
  end
end
