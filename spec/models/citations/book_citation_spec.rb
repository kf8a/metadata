require 'rails_helper'

describe BookCitation do
  it { should be_book }

  it 'should format correctly' do
    book = BookCitation.new
    allow(book).to receive(:author_and_year) {'Robertson, G. P., D. C. Coleman, C. S. Bledsoe, and P. Sollins. 1999.'}
    allow(book).to receive(:title) { 'Standard Soil Methods for Long-Term Ecological Research' }
    allow(book).to receive(:publication) {''}
    allow(book).to receive(:publisher) {'Oxford University Press'}
    allow(book).to receive(:address) {''}
    allow(book).to receive(:city) {'New York, New York, USA'} 
    expect(book.formatted).to eq "Robertson, G. P., D. C. Coleman, C. S. Bledsoe, and P. Sollins. 1999. Standard Soil Methods for Long-Term Ecological Research. Oxford University Press, New York, New York, USA"

  end
end
