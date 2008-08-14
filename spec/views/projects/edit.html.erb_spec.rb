require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/projects/edit.html.erb" do
  include ProjectsHelper
  
  before(:each) do
    assigns[:project] = @project = stub_model(Project,
      :new_record? => false,
      :string => 'N fertility gradient',
      :text => 'Nitrogen fertility gradient in corn'
    )
  end

  it "should render edit form" do
    render "/projects/edit.html.erb"
    
    response.should have_tag("form[action=#{project_path(@project)}][method=post]") do
      with_tag('input#project_title[name=?]', "project[title]")
      with_tag('input#project_abstract[name=?]', "project[abstract]")
    end
  end
end


