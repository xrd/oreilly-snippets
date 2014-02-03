require "oreilly/snippets/version"

COMMENTS = {
  js: "//",
  ruby: "#"
}

module Oreilly
  module Snippets

    def self.get_content_from_file( filename, identifier, language )
      contents = File.read( filename )
      m = contents.match( /#{COMMENTS[language]} BEGIN #{identifier}\n(.*?)#{COMMENTS[language]} END #{identifier}/xm )
      m[0]
    end
    
    def self.process( input, filename, language=nil, identifier=nil )
      snippets = parse( input )
      rv = input
      if snippets and snippets.length > 0 
        snippets.each do |s|
          content = get_content_from_file( filename, s[:identifier], s[:language] )
          # rv.gsub( /
        end
      end
    end
    
    def self.parse( input, offset=nil )
      output = []
      input.scan( /\[([^=]*)(=")([^"]*)(",\s*)([^=]*)(=")([^"]*)(",\s*)([^=]*)(=")([^"]*)(")\](\s+snippet.*?\n)(.*)\13/mx ) do |m|
        # /\[([^=]*)(=")([^"]*)(",\s*)([^=]*)(=")([^"]*)(",\s*)([^=]*)(=")([^"]*)(")\](.*)\7/mx ) do |m|
        match = {}
        match[m[0].to_sym] = m[2]
        match[m[4].to_sym] = m[6]
        match[m[8].to_sym] = m[10]
        match[:snippet] = m[12].strip
        match[:throwaway] = m[13]
        match[:full] = ( "[" + m[0..11].join( "" ) + "]" ) + m[12..-1].join( "" ) + m[12]
        
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
