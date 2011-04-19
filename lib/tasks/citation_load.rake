require 'polyglot'
require 'treetop'

require File.join(File.dirname(__FILE__), '../ris')
require File.join(File.dirname(__FILE__), '../ris_nodes')

namespace :citation do
  desc 'load ris citation file'
  task :load, :file, :needs => :environment do |t, args|
    parser = RISParser.new

    parser.consume_all_input = false
    file = File.open(args[:file],"r:UTF-8")
    content = file.read
    a = parser.parse(content[1..-1])
    p parser.failure_reason
    path = Pathname.new(File.dirname(file))
    citations = a.content(path.realpath.to_s + '/' + File.basename(file, '.ris').to_s + '.Data/PDF/')

    p citations
    web = Website.find_by_name('lter')
    citations.flatten.each do |citation|
      citation.website = web
      p citation
      p citation.save
      p citation.errors
    end
  end
end
