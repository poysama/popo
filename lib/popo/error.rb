module Popo
  module Error
    def self.say(message, subitem = false)
      puts "#{subitem ? "   ->" : "--"} #{message}"
      exit(-1)
    end
  end
end
