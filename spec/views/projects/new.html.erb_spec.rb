require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/projects/new.html.erb" do
  include ProjectsHelper
  
  before(:each) do
    assigns[:project] = stub_model(Project,
      :new_record? => true,
      :title => 'N fertility gradient',
      :abstract => 'Nitrogen fertility gradient in corn'
    )
  end

  it "should render new form" do
    render "/projects/new.html.erb"
    
    response.should have_tag("form[action=?][method=post]", projects_path) do
      with_tag("input#project_title[name=?]", "project[title]")
      with_tag("input#project_abstract[name=?]", "project[abstract]")
      with_tag("input#project_datasets[name=?]", "projects[datasets]")
    end
  end
end


