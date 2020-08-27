xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"
xml.Workbook({
  'xmlns'      => 'urn:schemas-microsoft-com:office:spreadsheet',
  'xmlns:o'    => 'urn:schemas-microsoft-com:office:office',
  'xmlns:x'    => 'urn:schemas-microsoft-com:office:excel',
  'xmlns:html' => 'http://www.w3.org/TR/REC-html40',
  'xmlns:ss'   => 'urn:schemas-microsoft-com:office:spreadsheet'
}) do

  xml.Worksheet 'ss:Name' => 'Context' do
    xml.Table do
      xml.Cell { xml.Data @datatable.data_access_statement, 'ss:Type' => 'String' }
    end
  end
  # xml.Worksheet 'ss:Name' => 'Data' do
  #   xml.Table do
  #     # Header
  #     xml.Row do
  #       @datatable.variates.each do |variate|
  #         xml.Cell { xml.Data variate, 'ss:Type' => 'String' }
  #       end
  #     end

  #     # Rows
  #     @datatable.data.each do |row|
  #       @datatable.variates.each do |variate|
  #         xml.Cell { xml.Data row, 'ss:Type' => 'Number' }
  #       end
  #     end
  #   end
  # end
end
