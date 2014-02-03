require "oreilly/snippets/version"

COMMENTS = {
  :js => "\/\/",
  :ruby => "#"
}

module Oreilly
  module Snippets

    def self.get_content_from_file( filename, identifier, language )
      contents = File.read( filename )
      comments = COMMENTS[language.to_sym]
      re = /#{comments} BEGIN #{identifier}\n(.*)\n#{comments} END #{identifier}\n/m
      m = contents.match( re )
      m[1]
    end

    def self.process( input )
      snippets = parse( input )
      rv = input
      if snippets and snippets.length > 0 
        snippets.each do |s|
          content = get_content_from_file( s[:filename], s[:identifier], s[:language] )
          rv = rv.gsub( s[:full], content )
        end
      end
      rv
    end
    
    def self.parse( input )
      output = []
      input.scan( /(\[[^\]]*\])(\s+)(snippet[^\s]*)(.*?)\3/m ) do |m|
        # Add it all up, and include the snippet piece (second to last captured)
        full = m.join( "" ) + m[m.length-2]
        full.scan( /\[([^=]*)="([^"]*)",\s*([^=]*)="([^"]*)",\s*([^=]*)="([^"]*)"\]/m ) do |m2|
          match = {}
          3.times do |i|
            match[m2[i*2].to_sym] = m2[(i*2)+1]
          end

          match[:full] = full.strip
          output << match
        end
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
