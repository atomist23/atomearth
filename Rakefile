require "rake/rdoctask"
require "rake/gempackagetask"
require "rake/testtask"
require "rake/clean"
require "rubygems"

# Some definitions that you'll need to edit in case you reuse this
# Rakefile for your own project.


project = {
  :name => "atomearth",
  :bin_files => %w(atomearth),
  :version => "0.0.2",
  :description => "A pcap to Google Earth feed generator",
  :author => "Thomas Gallaway",
  :rubyforge_user => "atomist",
  :dependencies => {
    'json' => '>= 0.0.0',
    'ftools' => '>= 0.0.0',
    'geoip_city' => '>= 0.0.0',
    'ipaddr' => '>= 0.0.0',
    'yaml' => '>= 0.0.0',
    'ramaze' => '>= 0.0.0',
    'pcaplet' => '>= 0.0.0'},
  :email => "atomist@gmail.com",
  :requirements => 'pcaplet for packet capture',
  :ruby_version_required => '>= 1.8.6'  
}

BASEDIR = File.expand_path(File.dirname(__FILE__))


# Specifies the default task to execute. This is often the "test" task
# and we'll change things around as soon as we have some tests.

task  :default => [:rdoc]

# The directory to generate +rdoc+ in.
RDOC_DIR="doc/html"

# This global variable contains files that will be erased by the `clean` task.
# The `clean` task itself is automatically generated by requiring `rake/clean`.

CLEAN << RDOC_DIR << "pkg"


# This is the task that generates the +rdoc+ documentation from the
# source files. Instantiating Rake::RDocTask automatically generates a
# task called `rdoc`.

Rake::RDocTask.new do |rd|
	# Options for documenation generation are specified inside of
	# this block. For example the following line specifies that the
	# content of the README file should be the main page of the
	# documenation.
	rd.main = "README" 
	
	# The following line specifies all the files to extract
	# documenation from.
	rd.rdoc_files.include( "README", "AUTHORS", "LICENSE", "TODO", "CHANGELOG", "bin/**/*", "lib/**/*.rb", "dist/*", "doc/*.rdoc", "log/**/*", "spec/*.rb" )
	# This one specifies the output directory ...
	rd.rdoc_dir 	= "doc/html"

	# Or the HTML title of the generated documentation set.
	rd.title 	= "#{project[:name]}: #{project[:description]}"

	# These are options specifiying how source code inlined in the
	# documentation should be formatted.
	
	rd.options 	= ["--line-numbers", "--inline-source"]

	# Check:
	# `rdoc --help` for more rdoc options
	# the {rdoc documenation home}[http://www.ruby-doc.org/stdlib/libdoc/rdoc/rdoc/index.html]
	# or the documentation for the +Rake::RDocTask+ task[http://rake.rubyforge.org/classes/Rake/RDocTask.html]
end

# The GemPackageTask facilitates getting all your files collected
# together into gem archives. You can also use it to generate tarball
# and zip archives.

# First you'll need to assemble a gemspec
PKG_FILES 	= FileList['dist/*', 'lib/**/*.rb', 'bin/**/*', 'doc/*', '[A-Z]*'].to_a

gems = ['ftools', 'json', 'geoip_city', 'ipaddr', 'logger', 'yaml', 'json', 'ramaze']

spec = Gem::Specification.new do |s|
  s.name = project[:name]
  s.rubyforge_project = project[:name]
  s.version = project[:version]
  s.platform = Gem::Platform::RUBY
  s.summary = project[:description]
  s.description = project[:description]
  s.author = project[:author]
  s.email = project[:email]
  s.executables = project[:bin_files]
  s.bindir = "bin"
  s.require_path = "lib"
  #project[:dependencies].each{|dep|
  #  s.add_dependency(dep[0], dep[1])
  #}
  s.requirements << project[:requirements]
  s.required_ruby_version = project[:ruby_version_required]
  s.files = (%w[Rakefile README LICENSE AUTHORS] + Dir["{spec,lib,dist,bin,doc}/**/*"]).uniq
end

# Adding a new GemPackageTask adds a task named `package`, which generates
# packages as gems, tarball and zip archives.
Rake::GemPackageTask.new(spec) do |pkg|
	pkg.need_zip = true
	pkg.need_tar_gz = true
end


# This task is used to demonstrate how to upload files to Rubyforge.
# Calling `upload_page` creates a current version of the +rdoc+
# documentation and uploads it to the Rubyforge homepage of the project,
# assuming it's hosted there and naming conventions haven't changed.
#
# This task uses `sh` to call the `scp` binary, which is plattform
# dependant and may not be installed on your computer if you're using
# Windows. I'm currently not aware of any pure ruby way to do scp
# transfers.

RubyForgeProject=project[:name]

#desc "Upload the web pages to the web."
#task :upload_pages => ["rdoc"] do
#  if RubyForgeProject then
#    path = "/var/www/gforge-projects/#{RubyForgeProject}"
#    sh "scp -r doc/html/* #{RUBYFORGE_USER}@rubyforge.org:#{path}"
#    sh "scp doc/images/*.png #{RUBYFORGE_USER}@rubyforge.org:#{path}/images"
#  end
#end

# This task will run the unit tests provided in files called
# `test/test*.rb`. The task itself can be run with a call to `rake test`

Rake::TestTask.new do |t| 
	t.libs << "test" 
	t.libs << "lib" 
	t.test_files = FileList['test/*.rb'] 
	t.verbose = true 
end
