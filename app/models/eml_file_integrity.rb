# frozen_string_literal: true
require 'faraday/follow_redirects'

class EmlFileIntegrity
    def self.generate(eml_string)
        conn = Faraday.new do |faraday|
            faraday.response :follow_redirects
        end
        eml = Nokogiri::XML(eml_string)
        urls = eml.xpath("//online/url")

        urls.each do |url|
            response = conn.get(url.text)
            checksum = compute_checksum(response)
            size = compute_size(response)
            physical_element = url.parent.parent.parent

            # Remove existing size and checksum elements if they exist
            physical_element.xpath(".//size").each(&:remove)
            physical_element.xpath(".//checksum").each(&:remove)

            # Insert the size and checksum into the physical element after the objectName element
            object_name = physical_element.at("objectName")
            if object_name && size
                object_name.add_next_sibling("<size>#{size}</size>")
            end
            size_element = physical_element.at("size")
            if size_element && checksum
                size_element.add_next_sibling("<authentication method='SHA-1'>#{checksum}</authentication>")
            elsif object_name && checksum
                object_name.add_next_sibling("<authentication method='SHA-1'>#{checksum}</authentication>")
            end
        end

        puts eml.to_xml(save_with: Nokogiri::XML::Node::SaveOptions::AS_XML)
    end

    def self.compute_checksum(response)
        return nil if response.status != 200
        Digest::SHA1.hexdigest(response.body)
    end

    def self.compute_size(response)
        return nil if response.status != 200
        response.body.size
    end
end