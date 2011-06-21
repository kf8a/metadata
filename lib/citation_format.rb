module CitationFormat
  def formatted(option = :default)
    if option == :natural
      format_as_natural
    else
      format_as_default
    end
  end

  def first_initial
    given_name[0..0].upcase
  end

  def middle_initial
    middle_name[0..0].upcase
  end

  def format_as_default
    given_name_part = has_given_name? ? ", #{first_initial}." : ""
    middle_name_part = has_middle_name? ? " #{middle_initial}." : ""
    sur_name.to_s + given_name_part + middle_name_part + suffix_text
  end

  def format_as_natural
    given_name_part = has_given_name? ? "#{first_initial}. " : ""
    middle_name_part = has_middle_name? ? "#{middle_initial}. " : ""
    given_name_part + middle_name_part + sur_name.to_s + suffix_text
  end

  def suffix_text
    has_suffix? ? suffix : ''
  end

  def name
    given  = " #{given_name}".presence
    middle = " #{middle_name}".presence
    given_and_middle = given || middle ? ", " + given.to_s + middle.to_s : ""

    sur_name.to_s + given_and_middle + suffix_text
  end

  def name=(name_string='')
    list_of_suffices = ['esq','esquire','jr','sr','2','i','ii','iii','iv','v','clu','chfc','cfp','md','phd']
    name_array = name_string.split(',')
    #Get suffices
    suffix_text = ''
    while name_array[-1].present? && list_of_suffices.include?(name_array[-1].downcase.delete('.').strip)
      suffix_text = ', ' + name_array.slice!(-1).strip + suffix_text
    end
    self.suffix = suffix_text
    if name_array.count == 1
      #Must be first middle last
      name_array = name_array[0].split.collect {|x| x.split('.') }.flatten
      self.given_name = name_array.slice!(0)
      self.sur_name = name_array.slice!(-1)
      self.middle_name = name_array.join(' ')
    else
      #Must be last, first middle
      self.sur_name = name_array.slice!(0)
      name_array = name_array[0].split.collect {|x| x.split('.') }.flatten
      self.given_name = name_array.slice!(0)
      self.middle_name = name_array.join(' ')
    end
  end

  private

  def has_given_name?
    given_name.present?
  end

  def has_middle_name?
    middle_name.present?
  end

  def has_suffix?
    respond_to?(:suffix) && suffix.present?
  end
end
