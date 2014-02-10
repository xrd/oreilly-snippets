require "oreilly/snippets/version"

COMMENTS = {
  :js => "\/\/",
  :ruby => "#"
}

module Oreilly
  module Snippets

    def self.get_content_from_file( spec, identifier, language, sha=nil, numbers=nil )
      contents = nil
      line_numbers = nil
      error = false

      if sha
        if sha[0..2].eql? "xxx"
          contents = "PLACEHOLDER TEXT, UPDATE WITH CORRECT SHA HASH"
        else
          if numbers
            sae = numbers.split( ".." ).map { |d| Integer(d)-1 }
            line_numbers = [sae[0], sae[1]]
          end
          # Use the filename to change into the directory and use git-show
          cwd = Dir.pwd
          Dir.chdir spec if spec
          contents = `git show #{sha}`
          error = true unless contents
          Dir.chdir cwd if spec
        end
      else
        contents = File.read( spec )
      end

      # If line numbers are there, provide only that content
      contents = contents.split( /\n/ )[line_numbers[0]..line_numbers[1]].join( "\n" ) if line_numbers
      
      rv = nil
      if identifier
        comments = COMMENTS[language.to_sym]
        re = /#{comments} BEGIN #{identifier}\n(.*)\n#{comments} END #{identifier}\n/m
        m = contents.match( re )
        rv = m[1]
      else
        rv = contents
      end

      rv = "INVALID SNIPPET, WARNING" if error
      # rv = scrub_other_identifiers( contents, comments )
      rv
    end

    def self.scrub_other_identifiers( s, comments )
      puts s
      re = /#{comments} BEGIN \S+\n(.*)\n#{comments} END \S+\n/m
      s.gsub!( re, $1 )
      s
    end
    
    def self.process( input )
      snippets = parse( input )
      rv = input
      if snippets and snippets.length > 0 
        snippets.each do |s|
          content = get_content_from_file( s[:filename], s[:identifier], s[:language], s[:sha], s[:lines] )
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
        match = {}
        m[0].scan( /([^=\[,\s]*)="([^"]*)"/ ) do |kv|
          match[kv[0].to_sym] = kv[1]
        end
        match[:full] = full.strip
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
