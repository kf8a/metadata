# frozen_string_literal: true

# streaming for csv data
module StreamFile
  extend ActiveSupport::Concern
  def stream_file(filename, extension)
    response.headers["Content-Type"] = "application/octet-stream"
    response.headers["Content-Disposition"] = "attachment; filename=#{filename}-#{Time.now.to_i}.#{extension}"
    yield response.stream
  ensure
    response.stream.close
  end
end
