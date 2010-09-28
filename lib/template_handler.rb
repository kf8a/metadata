#Takes care of choosing templates
class TemplateHandler
  def initialize(page, mycontroller, domain)
    @page = page
    @mycontroller = mycontroller
    @domain = domain
  end

  def correct_template
    self.render_liquid or self.render_domain_specific or self.render_default
  end

  #renders pages like "uploads/liquid_index"
  def render_liquid
    if self.liquid_file_exists? && self.liquid_template_exists?
      "#{@mycontroller}/liquid_#{@page}"
    end
  end

  #renders pages like "uploads/glbrc_index"
  def render_domain_specific
    "#{@mycontroller}/#{@domain}_#{@page}" if self.domain_specific_file_exists?
  end

  #renders pages like "uploads/index"
  def render_default
    "#{@mycontroller}/#{@page}"
  end

  def liquid_file_exists?
    base_name = "app/views/" + @mycontroller + "/liquid_" + @page
    erb_name  = base_name + ".html.erb"
    rhtml_name = base_name + ".rhtml"
    File.file?(erb_name) || File.file?(rhtml_name)
  end

  def liquid_template_exists?
    website = Website.find_by_name(@domain)
    website ||= Website.find(:first)
    plate = website.try(:layout, @mycontroller, @page)
    !plate.blank?
  end

  def domain_specific_file_exists?
    base_name = "app/views/"+ @mycontroller + "/"  + @domain + "_" + @page
    erb_name = base_name + ".html.erb"
    rhtml_name = base_name + ".rhtml"
    File.file?(erb_name) || File.file?(rhtml_name)
  end
end
