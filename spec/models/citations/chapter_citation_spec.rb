require 'rails_helper'

describe ChapterCitation do
  it { should_not be_book }
  its(:bibtex_type) { should == :chapter }
  its(:endnote_type) { should == "CHAP\n" }
  its(:endnote_publication_data) { should == "" }

  describe 'formatting' do
    before do 
      @chapter = ChapterCitation.new
      allow(@chapter).to receive(:author_and_year).and_return 'Jones 1981.'

      allow(@chapter).to receive(:title).and_return 'Chapter 10'
      allow(@chapter).to receive(:publication).and_return 'Lifetime Books'
    end

    it 'should be formatted correctly with volume and pages' do
      allow(@chapter).to receive(:volume).and_return '2'
      allow(@chapter).to receive(:start_page_number).and_return '1'
      allow(@chapter).to receive(:ending_page_number).and_return '10'
      allow(@chapter).to receive(:address_and_city).and_return "New York. New York"
      expect(@chapter.formatted).to eq "Jones 1981. Chapter 10. Vol 2, Pages 1-10 in Lifetime Books. New York. New York."
    end

    it 'should be formatted correctly without volume' do
      allow(@chapter).to receive(:start_page_number).and_return '1'
      allow(@chapter).to receive(:ending_page_number).and_return '10'
      allow(@chapter).to receive(:address_and_city).and_return "New York. New York"
      expect(@chapter.formatted).to eq "Jones 1981. Chapter 10. Pages 1-10 in Lifetime Books. New York. New York."
    end
  end

  # it 'should be formatted correctly with editors' do
  #   pending "write a better test"
  #   # chapter = ChapterCitation.new
  #   # chapter.stub(:author_and_year) {"Pryor, S. C., D. Scavia, C. Downer, M. Gaden, L. Iverson, R. Nordstrom, J. Patz, and G. P. Robertson. 2014."}
  #   # chapter.stub(:publication) {"Climate change impacts in the United States: The Third National Climate Assessment"}
  #   # chapter.stub(:doi) {"10.7930/J0J1012N"}
  #   # chapter.stub(:eds) {"J. M. Melillo, T. C. Richmond, and G. W. Yohe eds."} 
  #   # chapter.formatted.should == "Pryor, S. C., D. Scavia, C. Downer, M. Gaden, L. Iverson, R. Nordstrom, J. Patz, and G. P. Robertson. 2014. Chapter 18: Midwest. Pages 418-440 in J. M. Melillo, T. C. Richmond, and G. W. Yohe, eds. Climate change impacts in the United States: The Third National Climate Assessment. U.S. Global Change Research Program, doi:10.7930/J0J1012N"
  # end
end
