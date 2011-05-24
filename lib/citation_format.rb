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
    has_suffix? ? ", #{suffix}" : ''
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
