# from http://blog.twoalex.com/2010/02/18/using-capistrano-and-jammit-on-dreamhost/
require 'action_controller' # gotcha
require 'jammit'

desc "Uses Jammit to rebuild packages, ensuring they get built even if the backend does not get hit first"
task :package_dreamhost_assets do
  j = Jammit::Packager.new
  outputdir = File.join(Jammit::PUBLIC_ROOT, Jammit.package_path)
  packages = j.instance_variable_get(:@packages) # risk 1

  packages.each_key do |genera|
    puts "Packaging #{packages[genera].keys.length} #{genera.to_s} packages."
    packages[genera].each_key do |group| # note
      puts "Working on #{group.to_s}..."
      content = (genera == :js ? j.pack_javascripts(group) : j.pack_stylesheets(group))
      puts "content length: #{content.length}"
      j.cache(group, genera.to_s ,content, outputdir)
      puts "\tdone with #{genera.to_s}"
    end
    puts "Done with #{genera.to_s}"
  end
end
