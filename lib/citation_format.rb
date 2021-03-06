module CitationFormat
  SUFFICES = %w(esq esquire jr sr clu chfc cfp md phd).freeze

  def formatted(option = :default)
    if option == :natural
      format_as_natural
    else
      format_as_default
    end
  end

  def full_name
    given_name_part + middle_name_part + sur_name_part + suffix_text
  end

  def first_initial
    given_name[0..0].upcase
  end

  def middle_initial
    middle_name[0..0].upcase
  end

  def format_as_default
    given_name_part = given_name? ? ", #{first_initial}." : ''
    middle_name_part = middle_name? ? " #{middle_initial}." : ''
    sur_name.to_s + given_name_part + middle_name_part + suffix_text
  end

  def format_as_natural
    given_name_part = given_name? ? "#{first_initial}. " : ''
    middle_name_part = middle_name? ? "#{middle_initial}. " : ''
    given_name_part + middle_name_part + sur_name.to_s + suffix_text
  end

  def suffix_text
    suffix? ? suffix : ''
  end

  def name
    given  = " #{given_name}".presence
    middle = " #{middle_name}".presence
    given_and_middle = given || middle ? ',' + given.to_s + middle.to_s : ''

    sur_name.to_s + given_and_middle + suffix_text
  end

  def extract_suffix(name_array)
    suffix_text = ''
    while name_array[-1].present? && SUFFICES.include?(name_array[-1].downcase.delete('.').strip)
      suffix_text = ', ' + name_array.slice!(-1).strip + suffix_text
    end
    self.suffix = suffix_text

    name_array
  end

  def name=(name_string = '')
    if name_string.match(/^_/)
      self.sur_name = name_string[1..-1]
    else
      name_array = name_string.split(',')
      name_array = extract_suffix(name_array)
      if name_array.count == 1
        treat_as_first_middle_last(name_array)
      else
        treat_as_last_first_middle(name_array)
      end
    end
  end

  def treat_as_first_middle_last(name_array)
    name_array = name_array[0].split.collect { |part| part.split('.') }.flatten
    self.given_name = name_array.slice!(0)
    self.sur_name = name_array.slice!(-1)
    self.middle_name = name_array.join(' ')
  end

  def treat_as_last_first_middle(name_array)
    self.sur_name = name_array.slice!(0)
    name_array = name_array[0].split.collect { |part| part.split('.') }.flatten
    self.given_name = name_array.slice!(0)
    self.middle_name = name_array.join(' ')
  end

  private

  def given_name_part
    given_name? ? given_name + ' ' : ''
  end

  def middle_name_part
    middle_name? ? middle_name + ' ' : ''
  end

  def sur_name_part
    sur_name? ? sur_name : ''
  end

  def given_name?
    given_name.present?
  end

  def middle_name?
    middle_name.present?
  end

  def sur_name?
    sur_name.present?
  end

  def suffix?
    respond_to?(:suffix) && suffix.present?
  end
end
