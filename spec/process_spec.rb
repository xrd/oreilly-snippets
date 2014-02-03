require 'spec_helper'

FULL = <<END
[filename="fixtures/factorial.js", language="js", identifier="FACTORIAL_FUNC"]
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

describe "#parse" do
  it "should parse the file and extract the correct things" do
    outputs = Oreilly::Snippets.parse( TEMPLATE )
    output = outputs[0]
    puts output.inspect
    output[:filename].should == "fixtures/factorial.js"
    output[:language].should == "js"
    output[:identifier].should == "FACTORIAL_FUNC"
    output[:throwaway].should match( /^Put any descriptive/ )
    output[:snippet].should == "snippet~~~~"
    output[:full].should == FULL
  end
end

describe "#process" do

  it "should process a simple file" do
    output = Oreilly::Snippets.process( TEMPLATE, "fixtures/", "asdas" )
    output.should match( /ABC/ )
    output.should match( /DEF/ )
    output.should match( /function factorial\(number\)/ )
    output.should_not match( /BEGIN FACTORIAL FUNC/ )
    output.should_not match( /END FACTORIAL FUNC/ ) 
  end

end
