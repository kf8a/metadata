require File.expand_path(File.dirname(__FILE__) + '/../rails_helper')

describe Datatable do
  before(:each) do
    @datatable = FactoryBot.create(:datatable)
  end
end
