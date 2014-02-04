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

### Snippets Usage

Check out (Code Snippets)[http://chimera.labs.oreilly.com/books/1230000000065/ch04.html#code_explanation]
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

You can also use syntax like this to pull from a specific commit in
your git repository:

```
[filename="../../github.js.test", language="js", sha="8e05a916fe0b1a9d3e:coffeetech.js"]
```

This will look in the git repository in the `../../github.js.test`
directory, then grab the file at the specific SHA hash. This means you
can write code inside a repository, and add a snippet pointing to that
exact revision in the repository.

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
  the files into the Asciidoc files used by Atlas.
* In the directory root I have a bunch of .asciidoc files which are
  the post-processed files, the files which have the snippets resolved
  into real code.
* Guard watches both directories. When I make a change to the files in
  /pre, Guard regenerates the asciidoc files at the top level. When
  Guard sees one of those files has been changed, it processes them
  through Asciidoctor and then builds the HTML. 
* I serve the HTML file using a combination of pow (pow.cx) and
  config.ru. 
* Use the live-reload plugin for Chrome:
  https://chrome.google.com/webstore/detail/livereload/jnihajbhpnppcggbcgedagnkighmdlei

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
