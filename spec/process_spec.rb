require 'spec_helper'
require 'fileutils'
require 'tempfile'

TEST_REPO = "oreilly-snippets-sample-content"
GITHUB_REPO = "https://github.com/xrd/#{TEST_REPO}.git"
ROOT = File.join "spec", TEST_REPO

WITH_DIRECTORY_AND_SHA = <<END
[filename="../oreilly-snippets", language="js", sha="2f35461ff68c92c2e554c953:spec/fixtures/factorial.js"]
snippet~~~~
Put any descriptive text you want here. It will be replaced with the
snippet~~~~
END

LONG_LINES = <<END
[filename="../spec/fixtures/really_long_lines.rb"]
snippet~~~~
Put any descriptive text you want here. It will be replaced with the
snippet~~~~
END


WITH_SHA = <<END
[filename="#{ROOT}", language="js", sha="c863f786f5959799d7c:test.js"]
snippet~~~~
Put any descriptive text you want here. It will be replaced with the
snippet~~~~
END

WITH_SHA_LINE_NUMBERS = <<END
[filename="#{ROOT}", language="js", sha="c863f786f5959799d7c:test.js" lines="1..3"]
snippet~~~~
Put any descriptive text you want here. It will be replaced with the
snippet~~~~
END

WITH_PLACEHOLDER_SHA = <<END
[filename="#{ROOT}", language="js", sha="xxx:test.js"]
snippet~~~~
Put any descriptive text you want here. It will be replaced with the
snippet~~~~
END

LOTS_OF_IDENTIFIERS = <<END

[filename="spec/fixtures/coffeetech.js", language="js"]
snippet~~~~
Put any descriptive text you want here. It will be replaced with the
specified code snippet when you build ebook outputs
snippet~~~~

END

STRIP_CALLOUTS_JS = <<"END"
[filename="spec/fixtures/normalize_callouts.js", callouts=""]
snippet~~~~
...
snippet~~~~
END

ADD_CALLOUTS_JS = <<"END"
[filename="spec/fixtures/normalize_callouts.js", callouts="1,2,3"]
snippet~~~~
...
snippet~~~~
END

NO_SPACED_CALLOUTS_JS = <<"END"
[filename="spec/fixtures/add-callouts-no-space.js", callouts="1"]
snippet~~~~
...
snippet~~~~
END

REALLY_LONG_CALLOUTS_JS = <<"END"
[filename="spec/fixtures/normalize_callouts_long.js", callouts="1,10,15"]
snippet~~~~
...
snippet~~~~
END

CALLOUTS_PREFIX_JS = <<"END"
[filename="spec/fixtures/normalize_callouts_long.js", callouts_prefix="#", callouts="1,10,15"]
snippet~~~~
...
snippet~~~~
END

CALLOUTS_WRAP_AND_PREFIX_JS = <<"END"
[filename="spec/fixtures/normalize_callouts_long.js", callouts_prefix="#", callouts_wrap="# {1} #", callouts="1,10,15"]
snippet~~~~
...
snippet~~~~
END

CALLOUTS_WRAP_XML = <<"END"
[filename="spec/fixtures/some.xml", callouts_wrap="<!-- {x} -->", callouts="1,2,3"]
snippet~~~~
...
snippet~~~~
END

INVALID_CALLOUTS_WRAP_XML = <<"END"
[filename="spec/fixtures/some.xml", callouts_wrap="<!-- no x! -->", callouts="1,2,3"]
snippet~~~~
...
snippet~~~~
END


NORMALIZE_CALLOUTS_JS = <<"END"
[filename="spec/fixtures/normalize_callouts.js", normcallouts="true"]
snippet~~~~
...
snippet~~~~
END

HONEYPOT_NORMALIZE_CALLOUTS = <<"END"
[filename="spec/fixtures/normalize_callouts.honey", normcallouts="true"]
snippet~~~~
...
snippet~~~~
END

NORMALIZE_CALLOUTS_RB = <<"END"
[filename="spec/fixtures/normalize_callouts.rb", normcallouts="true"]
snippet~~~~
...
snippet~~~~
END


FULL = <<END
[filename="spec/fixtures/factorial.js", language="js", identifier="FACTORIAL_FUNC"]
snippet~~~~
Put any descriptive text you want here. It will be replaced with the
specified code snippet when you build ebook outputs
snippet~~~~
END

FOR_FLATTENING = <<END
[filename="spec/fixtures/factorial.js", language="js", lines="6..9"]
snippet~~~~
Put any descriptive text you want here. It will be replaced with the
specified code snippet when you build ebook outputs
snippet~~~~
END

DONT_USE_JAVA_FOR_FLATTENING = <<END
[filename="spec/fixtures/factorial.java", language="java", lines="3..5"]
snippet~~~~
Put any descriptive text you want here. It will be replaced with the
specified code snippet when you build ebook outputs
snippet~~~~
END

NO_LANGUAGE_FOR_FLATTENING = <<END
[filename="spec/fixtures/factorial.java", lines="3..5"]
snippet~~~~
Put any descriptive text you want here. It will be replaced with the
specified code snippet when you build ebook outputs
snippet~~~~
END

TEMPLATE = <<END

ABC

#{FULL}

DEF

END

WRAPPED_BY_SOURCE = <<END

[source,javascript]
-----
[filename="spec/fixtures/coffeetech.js", language="js", identifier="MODULE_DEFINITION"]
snippet~~~~~
var mod = angular.module( 'coffeetech', [] )
mod.controller( 'GithubCtrl', function( $scope ) {
  var github = new Github({} );
  var repo = github.getRepo( "gollum", "gollum" );
  repo.show( function(err, repo) {
    $scope.repo = repo;
    $scope.$apply();
  });
})
snippet~~~~~
-----

END

FLATTEN_WITH_SPACES =<<END
[filename="spec/fixtures/with_spaces.rb", language="ruby", flatten="true", lines="1..3"]
snippet~~~~
Put any descriptive text you want here. It will be replaced with the
specified code snippet when you build ebook outputs
snippet~~~~
END

FLATTEN_NO_LINE_NUMBERS =<<END
[filename="spec/fixtures/with_tabs.rb", language="ruby", flatten="true"]
snippet~~~~
Put any descriptive text you want here. It will be replaced with the
specified code snippet when you build ebook outputs
snippet~~~~
END

# Look at this: http://stackoverflow.com/questions/3772864/how-do-i-remove-leading-whitespace-chars-from-ruby-heredoc

# class String
#   def unindent 
#     gsub(/^#{scan(/^\s*/).min_by{|l|l.length}}/, "")
#   end
# end

FLATTEN_WITH_TABS =<<END
[filename="spec/fixtures/with_tabs.rb", language="ruby", flatten="true", lines="1..3"]
snippet~~~~
Put any descriptive text you want here. It will be replaced with the
specified code snippet when you build ebook outputs
snippet~~~~
END

def download_test_repository
  root = File.join( "spec", TEST_REPO )
  unless File.exists? root
    `git clone #{GITHUB_REPO} #{root}`
  end
end

describe Oreilly::Snippets do
  before( :all ) do
    download_test_repository()
  end
  
  describe "#parse" do

    it "should parse wrapped items" do
      outputs = Oreilly::Snippets.parse( WRAPPED_BY_SOURCE )
      output = outputs[0]
      output[:filename].should == "spec/fixtures/coffeetech.js"
      output[:language].should == "js"
      output[:identifier].should == "MODULE_DEFINITION"
    end
    
    it "should parse the file and extract the correct things" do
      outputs = Oreilly::Snippets.parse( TEMPLATE )
      output = outputs[0]
      output[:filename].should == "spec/fixtures/factorial.js"
      output[:language].should == "js"
      output[:identifier].should == "FACTORIAL_FUNC"
      output[:full].strip.should == FULL.strip
    end

    it "should get the SHA when specified" do
      outputs = Oreilly::Snippets.parse( WITH_SHA )
      output = outputs[0]
      output[:sha].should == "c863f786f5959799d7c:test.js"
    end

  end

  # describe "#scrub_other_identifiers" do
  #   it "should scrub everything that looks like an identifier" do
  #     out = Oreilly::Snippets.scrub_other_identifiers( File.read( "spec/fixtures/coffeetech.js" ), "//" )
  #     out.should_not match( /FOOBAR/ )
  #   end
  # end

  describe "#process" do

    it "should process a complex file" do
      output = Oreilly::Snippets.process( WRAPPED_BY_SOURCE )
      output.should_not match( /MODULE_DEFINITION/ )
      output.should_not match( /\/\/$/ )
    end
    
    it "should process a simple file" do
      output = Oreilly::Snippets.process( TEMPLATE )
      output.should match( /ABC/ )
      output.should match( /DEF/ )
      output.should match( /function factorial\(number\)/ )
      output.should_not match( /BEGIN FACTORIAL_FUNC/ )
      output.should_not match( /END FACTORIAL_FUNC/ ) 
    end

    describe "#callouts" do
      it "should strip callouts completely" do
        output = Oreilly::Snippets.process( STRIP_CALLOUTS_JS )
        output.should_not match( /<\d+>/ )        
      end

      it "should add callouts" do
        output = Oreilly::Snippets.process( ADD_CALLOUTS_JS )
        lines = output.split /\n/ 
        lines[0].should match( /<1>/ )        
        lines[1].should match( /<2>/ )        
        lines[2].should match( /<3>/ )        
      end

      it "should add callouts into a long file" do
        output = Oreilly::Snippets.process( REALLY_LONG_CALLOUTS_JS )
        lines = output.split /\n/ 
        lines[0].should match( /<1>/ )        
        lines[9].should match( /<2>/ )        
        lines[14].should match( /<3>/ )        
      end

      it "should add a prefix character to a callout to makes sure the code is runnable" do
        output = Oreilly::Snippets.process( CALLOUTS_PREFIX_JS )
        lines = output.split /\n/ 
        lines[0].should match( /# <1>/ )        
        lines[9].should match( /# <2>/ )        
        lines[14].should match( /# <3>/ )        
      end

      it "should add a prefix character to a callout to makes sure the code is runnable" do
        output = Oreilly::Snippets.process( CALLOUTS_PREFIX_JS )
        lines = output.split /\n/ 
        lines[0].should match( /# <1>/ )        
        lines[9].should match( /# <2>/ )        
        lines[14].should match( /# <3>/ )        
      end

      it "should properly wrap callouts" do
        output = Oreilly::Snippets.process( CALLOUTS_WRAP_XML )
        lines = output.split /\n/ 
        lines[0].should match( /<!-- <1> -->/ )        
        lines[1].should match( /<!-- <2> -->/ )        
        lines[2].should match( /<!-- <3> -->/ )        
      end

      it "should raise an error when prefix and wrap are used together for callouts" do
        lambda {
          output = Oreilly::Snippets.process( CALLOUTS_WRAP_AND_PREFIX_JS )
        }.should raise_error
      end

      it "should raise an error when wrap is misued" do
        lambda {
          output = Oreilly::Snippets.process( INVALID_CALLOUTS_WRAP_JS )
        }.should raise_error
      end

      it "should raise an error when wrap is misued" do
        lambda {
          output = Oreilly::Snippets.process( CALLOUTS_WRAP_AND_PREFIX_JS )
        }.should raise_error
      end


      it "should add callouts using a default comment" do
        output = Oreilly::Snippets.process( REALLY_LONG_CALLOUTS_JS )
        lines = output.split /\n/ 
        lines[0].should match( /\/\/ <1>/ )        
      end

      it "should add callouts without a space character in between comment and callout" do
        output = Oreilly::Snippets.process( NO_SPACED_CALLOUTS_JS )
        lines = output.split /\n/ 
        lines[0].should match( /\/\/ <1>/ )        
        lines[1].should_not match( /\/\/<10>/ )        
      end
    end

    describe "#normcallouts" do
      it "should normalize callouts" do
        output = Oreilly::Snippets.process( NORMALIZE_CALLOUTS_JS )
        output.should match( /<1>/ )        
        output.should_not match( /<12>/ )
      end

      it "should normalize callouts with alternative comments" do
        output = Oreilly::Snippets.process( NORMALIZE_CALLOUTS_RB )
        output.should match( /<1>/ )        
        output.should_not match( /<3>/ )
      end

      it "should not mistakenly normalize callouts" do
        output = Oreilly::Snippets.process( HONEYPOT_NORMALIZE_CALLOUTS )
        output.should match( /<2>/ )
      end
    end

    describe "#warnlonglines" do
      it "should warn you if there is a really long line of code" do
        ENV['OREILLY_SNIPPETS_DEBUG_LONG_LINES'] = "1"
        lambda {
          Oreilly::Snippets.process( LONG_LINES )
        }.should raise_error
      end
    end

    describe "#flatten" do
      before( :each ) do
        @with_spaces = File.read( "spec/fixtures/with_spaces.rb" )
        @with_tabs = File.read( "spec/fixtures/with_tabs.rb" )
        @spaces_flattened = @with_spaces.split( "\n" )[0..3].join( "\n" ).gsub( /^    /, "" )
        @tabs_flattened =  @with_tabs.split( "\n" )[0..3].join( "\n" ).gsub( /^\t\t/, "" )
      end

      it "should not flatten when indentation level is zero" do
        output = Oreilly::Snippets.process( FLATTEN_NO_LINE_NUMBERS )
        # remove one newline, consequence of embedding inside a template, it adds a newline
        output = output[0...-1]
        output.should == @with_tabs
      end
      
      it "should support flattening as a configuration option" do
        Oreilly::Snippets.config( flatten: true )
        output = Oreilly::Snippets.process( FOR_FLATTENING )
        lines = output.split "\n"
        lines[0][0].should_not match /\s/ # First line has no whitespace starting
        lines[-1][0].should match /\s/ # Last line is not indented
      end

      it "should not flatten if java is used and properly configured" do
        string = <<END
    public static void main( String[] args ) {
      // Do something
    }
END
        Oreilly::Snippets.config( flatten: true, skip_flattening: { java: true } )
        output = Oreilly::Snippets.process( DONT_USE_JAVA_FOR_FLATTENING )
        string.should eq( output )
      end

      it "should not crash when flattening if no language is specified" do
        Oreilly::Snippets.config( flatten: true, skip_flattening: { java: true } )
        lambda {
          Oreilly::Snippets.process( NO_LANGUAGE_FOR_FLATTENING )
        }.should_not raise_error()
      end

      it "should support flattening with tabs" do
        output = Oreilly::Snippets.process( FLATTEN_WITH_TABS )
        output.should == @tabs_flattened
      end
      
      it "should support flattening with spaces" do
        output = Oreilly::Snippets.process( FLATTEN_WITH_SPACES )
        output.should == @spaces_flattened
      end
    end

    # NYI
    # it "should remove all identifiers when processing" do
    #   output = Oreilly::Snippets.process( LOTS_OF_IDENTIFIERS )
    #   output.should_not match( /BEGIN/ )
    # end
    
    describe "#git" do
      it "should retrieve by SHA if specified" do
        output = Oreilly::Snippets.process( WITH_SHA )
        # strip the whitespace, makes comparison easier..
        cwd = Dir.getwd
        Dir.chdir File.join( ROOT )
        original = `git show c863f786f5959799d7c11312a7ba1d603ff16339:test.js`
        Dir.chdir cwd
        output.rstrip.should == original.rstrip
      end

      it "should retrieve by SHA and give us only certain lines" do
        output = Oreilly::Snippets.process( WITH_SHA_LINE_NUMBERS )
        original = nil
        Dir.chdir File.join( ROOT ) do 
          original = `git show c863f786f5959799d7c11312a7ba1d603ff16339:test.js`
        end
        lines = original.split /\n/
        original = lines[0..2].join( "\n" ) + "\n"
        output.should == original
      end

      it "should parse directory specifications" do
        output = Oreilly::Snippets.process( WITH_DIRECTORY_AND_SHA )
        original = nil
        path = ENV['REPO_NAME'] || "../oreilly-snippets"
        Dir.chdir path do 
          original = `git show 2f35461ff68c92c2e554c953:spec/fixtures/factorial.js`
        end
        output.should == ( original + "\n" )
      end

      it "should indicate placeholder if using xxx as the sha" do
        output = Oreilly::Snippets.process( WITH_PLACEHOLDER_SHA )
        output.should match( /PLACEHOLDER/ )
      end
    end
  end
end
