require 'spec_helper'

describe BookCitation do
  it { should be_book }

  it 'should format correctly' do
    book = BookCitation.new
    book.stub(:author_and_year) {'Robertson, G. P., D. C. Coleman, C. S. Bledsoe, and P. Sollins. 1999.'}
    book.stub(:title) { 'Standard Soil Methods for Long-Term Ecological Research' }
    book.stub(:publication) {''}
    book.stub(:publisher) {'Oxford University Press'}
    book.stub(:address) {''}
    book.stub(:city) {'New York, New York, USA'} 
    book.formatted.should == "Robertson, G. P., D. C. Coleman, C. S. Bledsoe, and P. Sollins. 1999. Standard Soil Methods for Long-Term Ecological Research. Oxford University Press, New York, New York, USA"

  end
end
