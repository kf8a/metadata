# TODO: evaluate if we need this
# Templates that were designed to that users could change the look and feel of the site
class Template < ApplicationRecord
  belongs_to :website
end
