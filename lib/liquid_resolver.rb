#Searches for a liquid template and uses it if there is one.
class LiquidResolver < ::ActionView::FileSystemResolver

  def initialize(sub)
    @subdomain = sub
    super('app/views')
  end

  private

  def find_templates(name, prefix, partial, details)
    if liquid_template_exists?(name, prefix)
      super("liquid_#{name}", prefix, partial, details)
    else
      []
    end
  end

  def liquid_template_exists?(page, mycontroller)
    website = Website.find_by_name(@subdomain)
    website ||= Website.find(:first)
    plate = website.try(:layout, mycontroller, page)
    !plate.blank?
  end

end