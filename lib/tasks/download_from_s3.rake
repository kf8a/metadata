# frozen_string_literal: true

require 'fileutils'
require 'open-uri'

namespace :s3 do
  desc 'download assets from s3'
  task download_assets_from_s3: :environment do
    DatasetFile.where('id > 0').where.not(data_file_name: nil).order(:id).find_each do |dataset_file|
      image = dataset_file.data_file_name
      url = dataset_file.data.s3_object.presigned_url(:get, secure: true, expires_in: 600).to_s

      p [dataset_file.id, url]
      filename = "./docs/dataset_files/data/#{dataset_file.id}/original/#{image}"
      FileUtils.mkdir_p "./docs/dataset_files/data/#{dataset_file.id}/original/"
      open(url) do |amazon|
        File.open(filename, 'wb') do |file|
          file.write(amazon.read)
        end
      end
      # File.write(filename, open(url))
    end
    # Citation.where('id > 0').where.not(pdf_file_name: nil).order(:id).find_each do |citation|
    #   image = citation.pdf_file_name
    #   url = citation.pdf.s3_object.presigned_url(:get, secure: true, expires_in: 600).to_s
    #
    #   p [citation.id, url]
    #   filename = "./docs/citations/pdfs/#{citation.id}/original/#{image}"
    #   FileUtils.mkdir_p "./docs/citations/pdfs/#{citation.id}/orginal/"
    #   open(url) do |amazon|
    #     File.open(filename, 'wb') do |file|
    #       file.write(amazon.read)
    #     end
    #   end
    # end
    # DatasetFile.where('id > 0').where.not(data_file_name: nil).order(:id).find_each do |dataset|
    #   image = dataset.data_file_name
    #   url = dataset.data.s3_object.presigned_url(:get, secure: true, expires_in: 600).to_s
    #
    #   p [dataset.id, url]
    #   filename = "./docs/dataset_files/#{image}"
    #   FileUtils.mkdir_p "./docs/dataset_files/pdfs/"
    #   open(url) do |amazon|
    #     File.open(filename, 'wb') do |file|
    #       file.write(amazon.read)
    #     end
    #   end
    # # end
  end
end
