require 'polyglot'
require 'treetop'

if RUBY_VERSION > '1.9.2'
  require_relative '../ris'
  require_relative '../ris_nodes'
else
  require 'lib/ris'
  require 'lib/ris_nodes'
end

namespace :citation do
  desc 'load ris citation file'
  task :load, :file, :needs => :environment do |t, args|
    parser = RISParser.new

    parser.consume_all_input = false
    file = File.open(args[:file],"r:UTF-8")
    content = file.read
    a = parser.parse(content)
    p parser.failure_reason
    path = Pathname.new(File.dirname(file))
    citations = a.content(path.realpath.to_s + '/' + File.basename(file, '.ris').to_s + '.Data/PDF')

    web = Website.find_by_name('glbrc')
    citations.flatten.each do |citation|
      citation.website = web
      p citation
      citation.save
    end
  end
end