# send file from s3 or the local file system
module FileSource
  extend ActiveSupport::Concern

  included do
    def pdf_from_s3(file)
      file_from_s3(file.pdf)
    end

    def pdf_from_filesystem(file)
      path = file.pdf.path
      send_file path, type: 'application/pdf', disposition: 'inline'
    end

    def file_from_s3(file)
      logger.info file
      redirect_to(file.s3_object
                          .presigned_url(:get,
                                         secure: true,
                                         expires_in: 60.seconds)
                          .to_s)
    end
  end
end
