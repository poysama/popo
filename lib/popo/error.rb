module Popo
  module Error
    def self.say(message, subitem = false)
      puts "#{subitem ? "   ->" : "Error:"} #{message}".red
      exit(-1)
    end
  end
end
