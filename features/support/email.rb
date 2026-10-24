# frozen_string_literal: true

module EmailHelpers
  # Maps a name to an email address. Used by email_steps

  def email_for(to)
    case to

    # add your own name => email address mappings here

    when /^#{capture_model}$/
      model(::Regexp.last_match(1)).email

    when /^"(.*)"$/
      ::Regexp.last_match(1)

    else
      to
    end
  end
end

World(EmailHelpers)
