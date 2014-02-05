require 'spec_helper'
require 'fileutils'
require 'tempfile'

TEST_REPO = "oreilly-snippets-sample-content"
GITHUB_REPO = "https://github.com/xrd/#{TEST_REPO}.git"
ROOT = File.join "spec", TEST_REPO

WITH_SHA = <<END
[filename="#{ROOT}", language="js", sha="c863f786f5959799d7c:test.js"]
snippet~~~~
Put any descriptive text you want here. It will be replaced with the
snippet~~~~
END

WITH_SHA_LINE_NUMBERS = <<END
[filename="#{ROOT}", language="js", sha="c863f786f5959799d7c:test.js:1..3"]
snippet~~~~
Put any descriptive text you want here. It will be replaced with the
snippet~~~~
END

ORIGINAL_CONTENTS = <<END
var mod = angular.module( 'coffeetech', [] )
mod.controller( 'ShopsCtrl', function( $scope ) {
  var github = new Github({} );
  var repo = github.getRepo( "xrd", "spa.coffeete.ch" ); 
  repo.contents( "gh-pages", "portland.json", function(err, data) { 
    $scope.shops = JSON.parse( data );
    $scope.$digest();
  }, false );
})
END

LOTS_OF_IDENTIFIERS = <<END

[filename="spec/fixtures/coffeetech.js", language="js"]
snippet~~~~
Put any descriptive text you want here. It will be replaced with the
specified code snippet when you build ebook outputs
snippet~~~~

END


FULL = <<END
[filename="spec/fixtures/factorial.js", language="js", identifier="FACTORIAL_FUNC"]
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
        output.strip.should == original.strip
      end

      it "should retrieve by SHA and give us only certain lines" do
        output = Oreilly::Snippets.process( WITH_SHA_LINE_NUMBERS )
        cwd = Dir.getwd
        Dir.chdir File.join( ROOT )
        original = `git show c863f786f5959799d7c11312a7ba1d603ff16339:test.js`
        Dir.chdir cwd
        lines = original.split /\n/
        original = lines[1..3].join "\n"
        output.strip.should == original.strip
      end
    end
    
  end
end
