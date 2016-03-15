#Searches for a subdomain specific template and uses it if possible.
class SubdomainResolver < ::ActionView::FileSystemResolver

  def initialize(sub)
    @subdomain = sub
    super('app/views')
  end

  private

  def find_templates(name, prefix, partial, details, outside_app_allowed = false)
    new_name = @subdomain + "_" + name
    super(new_name, prefix, partial, details, outside_app_allowed)
  end
end
