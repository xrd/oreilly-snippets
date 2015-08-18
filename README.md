# Oreilly::Snippets

Write O'Reilly-style code snippets inside your Asciidoc or markdown files.

## Installation

Add this line to your application's Gemfile:

    gem 'oreilly-snippets'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install oreilly-snippets

## Usage

### Library usage

Send a string with proper snippet code into the process method:

`Oreilly::Snippets.process( asciidoc_string )`

### Snippets Usage

Check out [Code Snippets](http://chimera.labs.oreilly.com/books/1230000000065/ch04.html#code_explanation)
from O'Reilly.

A snippet looks like this inside your markup.

```
[filename="coffeetech.js", language="js" identifier="IDENTIFIER"]
snippet~~~~
Put any descriptive text you want here. It will be replaced with the
specified code snippet when you build ebook outputs
snippet~~~~
```

Then, inside your `coffeetech.js` file you have something like this:

```
// BEGIN IDENTIFIER
var mod = angular.module( 'coffeetech', [] );

mod.factory( 'Github', function() {
    return new Github({});
});
// END IDENTIFIER

mod.factory( 'Geo', [ '$window', function( $window ) {
    return $window.navigator.geolocation;
} ] );

```

Putting that snippet into your markdown makes the markdown eventually
end up like this:

```
var mod = angular.module( 'coffeetech', [] );

mod.factory( 'Github', function() {
    return new Github({});
});
```

### Special additions to snippets

#### Retrieve content from the local git repository

You can also use syntax like this to pull from a specific commit in
your git repository:

```
[filename="../../github.js.test", language="js", sha="8e05a916fe0b1a9d3e:coffeetech.js"]
```

This will look in the git repository in the `../../github.js.test`
directory, then grab the file at the specific SHA hash. This means you
can write code inside a repository, and add a snippet pointing to that
exact revision in the repository.

#### Line Numbers

Also, you can specify line numbers and use just certain lines within the file retrieved:

```
[filename="../../github.js.test", language="js", sha="8e05a916fe0b1a9d3e:coffeetech.js, lines="1..5"]
```

This is equivalent to a range in ruby like `[0..4]`. So, we use human indexes, which are converted to zero-based numbering.

#### Placeholders for future SHA hashes

If you want to use a placeholder to remind you to put the correct
content in later once you have made the  correct commit, use "xxx" as
the sha hash.

```
[filename="../../github.js.test", language="js", sha="xxx:coffeetech.js, lines="1..5"]
```

This will get replaced with `PLACEHOLDER TEXT, UPDATE WITH CORRECT SHA HASH`.

#### Flattening Identation

You can specify `flatten=true` and oreilly-snippets will flatten out
indentation. For example, if you are including a snippet of python
content, you might not want to keep the indentation level as it is in
the file, but display the content "flattened" to the smallest
indentation level.

For example, imagine this content:

```
def barfoo():
    print "barfoo"
    if someVar == "someVar"
        if anotherVar == "anotherVar"       
            if thirdVar == "thirdVar" 
                print( "all of them" )
```

Then, imagine if you take the snippet from lines 4-6. You probably
don't want to display the snippet like this:

```
        if anotherVar == "anotherVar"       
            if thirdVar == "thirdVar" 
                print( "all of them" )
```

You probably want it like this:

```
if anotherVar == "anotherVar"       
    if thirdVar == "thirdVar" 
        print( "all of them" )
```

If you want the default to be to flatten (avoiding setting it each
snippet declaration), you can set that using the config method: `Oreilly::Snippets.config( flatten: true )` 

At the moment, flattening does not work perfectly for Java files. You can ignore java with `Oreilly::Snippets.config( flatten: true, skip_flattening: { java: true } )` 
#### Incompatibilities with Atlas from O'Reilly

NB: This format of snippets is not currently compatible with Atlas
from O'Reilly. However, you can always process the snippet and write
out a normal Asciidoc file, a file which will be compatible with
Atlas. See below for an example using Guard.

### Using with Guard and live-reload

One nice workflow is to edit files in your editor, then have guard
running to process those files, and open them in the browser so that
when you make changes the live-reload plugin will automatically reload
the processed HTML. 

The file structure I use for this:

* Store my pre-processed files in the /pre directory. These are the
  files which have the snippets. I need to have a special directory
  because this means Atlas will ignore them, and guard will process
  the files into the Asciidoc files stored in the root of the directory, 
  the files which Atlas will process.
* In the directory root I have a bunch of .asciidoc files which are
  the post-processed files, the files which have the snippets resolved
  into real code.
* Guard watches both directories (the root and the /pre directory). 
  When I make a change to the files in
  /pre, Guard regenerates the asciidoc files at the top level. When
  Guard sees one of those files has been changed, it processes them
  through Asciidoctor and then builds the HTML. You could combine these 
  into a single watch if you want.
* I serve the HTML file using a combination of pow (pow.cx) and
  config.ru. 
* Use the live-reload plugin for Chrome:
  https://chrome.google.com/webstore/detail/livereload/jnihajbhpnppcggbcgedagnkighmdlei

It looks like this:

```
# Files which have been processed by oreilly-snippets and 
# have regulard [source,javascript] style code blocks
chapter1.asciidoc 
chapter2.asciidoc
# Files with the exact same name which have the oreilly-snippets
# code includes. These are the files I edit.
/pre/chapter1.asciidoc
/pre/chapter2.asciidoc
# The rendered HTML files. I open these in my browser and the live-reload
# plugin reloads once I edit anything in the /pre directory.
chapter1.asciidoc.html
chapter2.asciidoc.html
```

Here is the `Guardfile`

```
require 'asciidoctor'
require 'oreilly/snippets'

# Add a bit of JS to each file before writing to HTML
init_script = '<script type="text/javascript" src="init.js"></script>';

guard 'shell' do
  watch( /^pre\/[^\/]*\.asciidoc$/) {|m|
    contents = File.read( m[0] )
    snippetized = Oreilly::Snippets.process( contents )
    snippet_out =  m[0].gsub( "pre/", "" )
    File.open( snippet_out, "w+" ) do |f|
      f.write snippetized
      puts "Wrote new snippet: #{snippet_out}"
    end
  }
end

guard 'shell' do 
  watch( /^[^\/]*\.asciidoc$/ ) { |m|
    puts "File: #{m.inspect}"
    asciidoc = File.read( m[0] )
    out = Asciidoctor.render( asciidoc,
                              :header_footer => true,
                              :safe => Asciidoctor::SafeMode::SAFE,
                              :attributes => {'linkcss!' => ''})

    File.open( m[0]+ ".html", "w+" ) do |f|
      out.gsub!( '</body>', "</body>\n#{init_script}\n" )
      f.write out
      puts "Wrote: #{m[0]+'.html'}"
    end
  }
end

guard 'livereload' do
  watch(%r{^.+\.(css|js|html)$})
end
```

My `config.ru`

```
app = proc do |env|
  Rack::Directory.new('.').call(env)
end

run app
```


## Running the tests

Install the `rspec` gem.

```
$ rspec 
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
2. Write tests (see the tests in the spec/ directory)
2. Commit your changes (`git commit -am 'Add some feature'`)
3. Push to the branch (`git push origin my-new-feature`)
4. Create new Pull Request
