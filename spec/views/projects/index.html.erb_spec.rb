require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/projects/index.html.erb" do
  include ProjectsHelper
  
  before(:each) do
    assigns[:projects] = [
      stub_model(Project,
        :title => 'N fertility gradient',
        :abstract => 'Nitrogen fertility gradient in corn'
      ),
      stub_model(Project,
        :title => 'Forest fertilization',
        :abstract => 'Forest N fertilization'
      )
    ]
  end

  it "should render list of projects" do
    render "/projects/index.html.erb"
    response.should have_tag("tr>td", 'Forest fertilization', 2)
    response.should have_tag("tr>td", 'Forest N fertilization', 2)
  end
end

