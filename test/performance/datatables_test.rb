require File.dirname(__FILE__) + '/../test_helper'
require 'performance_test_help'

class DatatablesTest < ActionController::PerformanceTest
  # Replace this with your real tests.
  def test_datatables
    get '/datatables'
  end
end
