module CitationFormat
  def formatted(option = :default)
    if option == :natural
      format_as_natural
    else
      format_as_default
    end
  end

  def format_as_default
    if has_given_name? && has_middle_name?
      "#{sur_name}, #{given_name[0..0].upcase}. #{middle_name[0..0].upcase}.#{suffix_text}"
    elsif has_given_name?
      "#{sur_name}, #{given_name[0..0].upcase}.#{suffix_text}"
    else
      sur_name.to_s + suffix_text
    end
  end

  def format_as_natural
    if has_given_name? && has_middle_name?
      "#{given_name[0..0].upcase}. #{middle_name[0..0].upcase}. #{sur_name}#{suffix_text}"
    elsif given_name
      "#{given_name[0..0].upcase}. #{sur_name}#{suffix_text}"
    else
      sur_name.to_s + suffix_text
    end
  end

  def suffix_text
    has_suffix? ? suffix : ''
  end

  def name
    if sur_name.present?
      if middle_name.present? || given_name.present?
        sur_text = "#{sur_name},"
      else
        sur_text = sur_name
      end
    else
      sur_text = ''
    end

    given_text  = given_name.present?  ? " #{given_name}"  : ''
    middle_text = middle_name.present? ? " #{middle_name}" : ''
    suffix_text = suffix.present?      ? suffix            : '' #proper suffix should already be in ', Jr.' form

    sur_text + given_text + middle_text + suffix_text
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
