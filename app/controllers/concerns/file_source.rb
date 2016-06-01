# send file from s3 or the local file system
module FileSource
  extend ActiveSupport::Concern

  included do
    def file_from_s3(file)
      redirect_to(file.pdf.s3_object
                          .url_for(:read,
                                   secure: true,
                                   expires_in: 20.seconds)
                          .to_s)
    end

    def file_from_filesystem(file)
      path = file.pdf.path
      send_file path, type: 'application/pdf', disposition: 'inline'
    end
  end

end
