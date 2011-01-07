class Author < ActiveRecord::Base
  belongs_to :citation
  
  validates_presence_of :seniority

  def formatted(option = :default)
    if option == :natural
      format_as_natural
    else 
      format_as_default
    end
  end
  
  def format_as_default
    if has_given_name? and  has_middle_name?
      "#{sur_name.capitalize}, #{given_name[0].upcase}. #{middle_name[0].upcase}."
    elsif has_given_name?
      "#{sur_name.capitalize}, #{given_name[0].upcase}."
    else
      sur_name.capitalize
    end
  end

  def format_as_natural
    if has_given_name? and has_middle_name?
      "#{given_name[0].upcase}. #{middle_name[0].upcase}. #{sur_name.capitalize}"
    elsif given_name
      "#{given_name[0].upcase}. #{sur_name.capitalize}"
    else
      sur_name.capitalize
    end
  end

  private
  
  def has_given_name?
    !(given_name.nil? || given_name.try(:empty?))
  end

  def has_middle_name?
    !(middle_name.nil? || middle_name.try(:empty?))
  end
end
