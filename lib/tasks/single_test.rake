unless Rails.env == 'production'
require 'single_test'

SingleTest.load_tasks
end
