require 'spec_helper'

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
end

describe "#process" do

  it "should process a complex file" do
    output = Oreilly::Snippets.process( WRAPPED_BY_SOURCE )
    output.should_not match( /MODULE_DEFINITION/ )
  end
  
  it "should process a simple file" do
    output = Oreilly::Snippets.process( TEMPLATE )
    output.should match( /ABC/ )
    output.should match( /DEF/ )
    output.should match( /function factorial\(number\)/ )
    output.should_not match( /BEGIN FACTORIAL_FUNC/ )
    output.should_not match( /END FACTORIAL_FUNC/ ) 
  end

end
