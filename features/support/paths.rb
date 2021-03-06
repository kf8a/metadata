module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name

    when /the home\s?page/
      '/'

    when /the sign up page/i
      sign_up_path
    when /the sign in page/i
      sign_in_path
    when /the password reset request page/i
      new_password_path

    when /the datatable page/
      datatable_path(Datatable.order('created_at').last)

    when /the datatable edit page/
      edit_datatable_path(Datatable.order('created_at').last)

    when /the datatable download page/
      datatable_path(Datatable.order('created_at').last, :format => 'csv')

    when /the datatable download page for "(.*)"/
      datatable_path(Datatable.find_by_name($1), :format => 'csv')

    when /the datatable show page for "(.*)"/
      datatable_path(Datatable.find_by_name($1))

    when /the quality control page for "(.*)"/
      qc_datatable_path(Datatable.find_by_name($1))

    when /LTER datatables/
      datatables_path

    when /GLBRC datatables/
      datatables_path

    when /the edit protocol page/
      edit_protocol_path(Protocol.order('created_at').last)

    when /the citation page/
      citation_path(Citation.order('created_at').last)

    when /the collection page/
      collection_path(Collection.order('created_at').last)

    when /the template page/
      template_path(Template.order('created_at').last)

    # the following are examples using path_to_pickle

    when /^#{capture_model}(?:'s)? page$/                           # eg. the forum's page
      path_to_pickle $1

    when /^#{capture_model}(?:'s)? #{capture_model}(?:'s)? page$/   # eg. the forum's post's page
      path_to_pickle $1, $2

    when /^#{capture_model}(?:'s)? #{capture_model}'s (.+?) page$/  # eg. the forum's post's comments page
      path_to_pickle $1, $2, :extra => $3                           #  or the forum's post's edit page

    when /the #{capture_model}(?:'s)? (.+?) page/ 
        polymorphic_path [$2.to_sym, model!($1)] 

    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))

    else
      begin
        page_name =~ /the (.*) page/
        path_components = $1.split(/\s+/)
        self.send(path_components.push('path').join('_').to_sym)
      rescue Object => e
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
          "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
end

World(NavigationHelpers)
