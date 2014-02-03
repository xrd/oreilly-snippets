require "oreilly/snippets/version"

module Oreilly
  module Snippets
    def self.process( input, filename, language=nil, identifier=nil )
      input
    end
    
    def self.parse( input, offset=nil )
      output = []
      input.scan( /\[([^=]*)="([^"]*)",\s*([^=]*)="([^"]*)",\s*([^=]*)="([^"]*)"\]\n(.*)\n(.*)\n\7/mx ) do |m|
        match = {}
        3.times do |i|
          match[m[i*2].to_sym] = m[(i*2)+1]
        end
        
        match[:snippet] = m[6]
        match[:throwaway] = m[7]
        
        output << match
      end
      output
    end
  end
end
# To include this snippet in an AsciiDoc file, add the following block:

#   [filename="factorial.js", language="js", identifier="FACTORIAL_FUNC"]
# snippet~~~~
#   Put any descriptive text you want here. It will be replaced with the
# specified code snippet when you build ebook outputs
# snippet~~~~
#   When the ebook is generated, the following output will be present in place of the snippet block:

#   function factorial(number) {
#                if (number == 0) {
#                    return 1
#                  } else {
#                    return factorial(number - 1) * number
#                  }
#   }
