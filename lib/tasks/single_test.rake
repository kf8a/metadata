unless RAILS_ENV == 'production'
require 'single_test'

SingleTest.load_tasks
end
