if RUBY_VERSION > "1.9"
  require 'simplecov'  
  
  namespace :simplecov do
    desc 'Measures test coverage using simplecov'
    SimpleCov.start 'rails'
    
  end
end
