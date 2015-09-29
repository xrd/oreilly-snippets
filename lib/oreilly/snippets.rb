require "oreilly/snippets/version"

COMMENTS = {
  :js => "\/\/",
  :ruby => "#",
  :python => "#"
}

module Oreilly
  module Snippets

    @@_config = {}

    def self.config( opts )
      @@_config.merge!( opts )
    end

    def self.get_content_from_file( s )

      spec = s[:filename]
      identifier =  s[:identifier]
      language = s[:language]
      sha = s[:sha]
      numbers = s[:lines]
      flatten = s[:flatten]
      normcallouts = s[:normcallouts] 
      callouts_prefix = s[:callouts_prefix]
      callouts = s[:callouts]

      contents = nil
      line_numbers = nil
      error = false

      if numbers
        sae = numbers.split( ".." ).map { |d| Integer(d)-1 }
        line_numbers = [sae[0], sae[1]]
      end
      
      if sha
        if sha[0..2].eql? "xxx"
          contents = "PLACEHOLDER TEXT, UPDATE WITH CORRECT SHA HASH"
        else
          # Use the filename to change into the directory and use git-show
          spec = "." unless spec
          Dir.chdir spec do
            contents = `git show #{sha}`
            error = true unless contents
          end
        end
      else
        contents = File.read( spec )
      end

      # If line numbers are there, provide only that content
      if line_numbers
        contents = contents.split( /\n/ )[line_numbers[0]..line_numbers[1]].join( "\n" )
      end
      
      rv = nil
      if identifier
        comments = COMMENTS[language.to_sym]
        re = /#{comments} BEGIN #{identifier}\n(.*)\n#{comments} END #{identifier}\n/m
        m = contents.match( re )
        rv = m[1]
      else
        rv = contents
      end

      # puts "Should we skip flattening? #{language}"
      unless skip_flattening( language )
        if flatten or @@_config[:flatten]
          rv = flatten_it( rv )
        end
      end

      if callouts
        rv = process_callouts( rv, callouts, callouts_prefix )
      elsif normcallouts
        rv = normalize_callouts( rv )
      end

      rv = "INVALID SNIPPET, WARNING" if error
      # rv = scrub_other_identifiers( contents, comments )
      rv
    end

    def self.process_callouts( input, callouts, comment_character = nil )
      rv = nil
      # Strip them out and figure out the comment character
      rv = input.gsub( /([#\/]\/?) ?<\d+>/ ) { |c| comment_character ||= $1; '' }

      unless comment_character
        # OK, we need to scan for it and hope to figure it out
        if rv =~ /\/\/[\/]+$/
          comment_character = '/'
        elsif rv =~ /#[^#]+$/
          comment_character = '#'
        end
      end

      unless comment_character
        comment_character = '//'
      end

      unless callouts.eql? ""
        list = callouts.split /,/
        lines = rv.split /\n/
        list.each_with_index do |c,i|
          index = c.to_i - 1
          lines[index] += "#{comment_character} <#{i+1}>" if lines.length > index and index >= 0
        end
        rv = lines.join "\n"
      end

      if ENV['OREILLY_SNIPPETS_DEBUG_LONG_LINES']
        rv.split( /\n/ ).each_with_index do |l,i|
          if l.length > 70
            raise "Line #{i+1} is too long: #{l.length} characters long"
          end
        end
      end

      rv
    end

    def self.normalize_callouts( rv )
      # Find something that looks like comment character + whitespace + < + number + >
      index = 0
      rv.gsub!( /([\/#]) <\d*>/ ) { |c| index += 1; "#{$1} <#{index}>" }
      rv
    end

    def self.skip_flattening( language )
      rv = ( !!@@_config[:skip_flattening] and language and !!@@_config[:skip_flattening][language.to_sym] ) 
      # rv = ( !!@@_config[:skip_flattening] and !!@@_config[:skip_flattening][language.to_sym] ) 
      # puts "Skipping flattening for #{language} / #{@@_config[:skip_flattening][language.to_sym]} / #{rv} / (#{@@_config[:skip_flattening].inspect})" if rv
      rv
    end

    def self.flatten_it( content ) 
      # find the smallest indent level, and then strip that off the beginning of all lines
      smallest = nil
      lines = content.split "\n"
      lines.each do |l|
        if l =~ /^(\s*)\S/
          if smallest
            if $1.length < smallest.length
              smallest = $1
            end
          else
            smallest = $1
          end
        end
      end

      content.gsub!( /^#{smallest}/, '' ) if smallest
      content
    end


    def self.scrub_other_identifiers( s, comments )
      # puts s
      re = /#{comments} BEGIN \S+\n(.*)\n#{comments} END \S+\n/m
      s.gsub!( re, $1 )
      s
    end
    
    def self.process( input )
      snippets = parse( input )
      rv = input
      if snippets and snippets.length > 0 
        snippets.each do |s|
          content = get_content_from_file( s ) #  s[:filename], s[:identifier], s[:language], s[:sha], s[:lines], s[:flatten], s[:normcallouts] )
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
        match[:full] = full
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
