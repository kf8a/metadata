require 'spec_helper'

describe Citation do
  it { should_not be_book }

  it "should correctly convert from ris" do
    doc = <<HERE
TY  - JOUR
A1  - Baldwin,S.A.
A1  - Fugaccia,I.
A1  - Brown,D.R.
A1  - Brown,L.V.
A1  - Scheff,S.W.
T1  - Blood-brain barrier breach following
cortical contusion in the rat
JO  - J.Neurosurg.
Y1  - 1996
VL  - 85
SP  - 476
EP  - 481
RP  - Not In File
KW  - cortical contusion
KW  - blood-brain barrier
KW  - horseradish peroxidase
KW  - head trauma
KW  - hippocampus
KW  - rat
N2  - Adult Fisher 344 rats were subjected to a unilateral impact to the dorsal cortex above the hippocampus at 3.5 m/sec with a 2 mm cortical depression. This caused severe cortical damage and neuronal loss in hippocampus subfields CA1, CA3 and hilus. Breakdown of the blood-brain barrier (BBB) was assessed by injecting the protein horseradish peroxidase (HRP) 5 minutes prior to or at various times following injury (5 minutes, 1, 2, 6, 12 hours, 1, 2, 5, and 10 days). Animals were killed 1 hour after HRP injection and brain sections were reacted with diaminobenzidine to visualize extravascular accumulation of the protein. Maximum staining occurred in animals injected with HRP 5 minutes prior to or 5 minutes after cortical contusion. Staining at these time points was observed in the ipsilateral hippocampus. Some modest staining occurred in the dorsal contralateral cortex near the superior sagittal sinus. Cortical HRP stain gradually decreased at increasing time intervals postinjury. By 10 days, no HRP stain was observed in any area of the brain. In the ipsilateral hippocampus, HRP stain was absent by 3 hours postinjury and remained so at the 6- and 12- hour time points. Surprisingly, HRP stain was again observed in the ipsilateral hippocampus 1 and 2 days following cortical contusion, indicating a biphasic opening of the BBB following head trauma and a possible second wave of secondary brain damage days after the contusion injury. These data indicate regions not initially destroyed by cortical impact, but evidencing BBB breach, may be accessible to neurotrophic factors administered intravenously both immediately and days after brain trauma.
ER  -

HERE
    citation = Citation.from_ris(doc)[0]
    citation.should be_a ArticleCitation
    citation.author_block.should include('Baldwin, S A')
    citation.author_block.should include('Fugaccia, I')
    citation.author_block.should include('Brown, D R')
    citation.author_block.should include('Brown, L V')
    citation.author_block.should include('Scheff, S W')
    citation.title.should == "Blood-brain barrier breach following\ncortical contusion in the rat"
    citation.publication.should == 'J.Neurosurg.'
    citation.pub_date.should == Date.parse('Mon, 01 Jan 1996')
    citation.volume.should == '85'
    citation.start_page_number.should == 476
    citation.ending_page_number.should == 481
    citation.abstract.should == "Adult Fisher 344 rats were subjected to a unilateral impact to the dorsal cortex above the hippocampus at 3.5 m/sec with a 2 mm cortical depression. This caused severe cortical damage and neuronal loss in hippocampus subfields CA1, CA3 and hilus. Breakdown of the blood-brain barrier (BBB) was assessed by injecting the protein horseradish peroxidase (HRP) 5 minutes prior to or at various times following injury (5 minutes, 1, 2, 6, 12 hours, 1, 2, 5, and 10 days). Animals were killed 1 hour after HRP injection and brain sections were reacted with diaminobenzidine to visualize extravascular accumulation of the protein. Maximum staining occurred in animals injected with HRP 5 minutes prior to or 5 minutes after cortical contusion. Staining at these time points was observed in the ipsilateral hippocampus. Some modest staining occurred in the dorsal contralateral cortex near the superior sagittal sinus. Cortical HRP stain gradually decreased at increasing time intervals postinjury. By 10 days, no HRP stain was observed in any area of the brain. In the ipsilateral hippocampus, HRP stain was absent by 3 hours postinjury and remained so at the 6- and 12- hour time points. Surprisingly, HRP stain was again observed in the ipsilateral hippocampus 1 and 2 days following cortical contusion, indicating a biphasic opening of the BBB following head trauma and a possible second wave of secondary brain damage days after the contusion injury. These data indicate regions not initially destroyed by cortical impact, but evidencing BBB breach, may be accessible to neurotrophic factors administered intravenously both immediately and days after brain trauma."
  end

  it "should convert MGZN to ArticleCitation" do
    doc = <<HERE
TY  - MGZN
KW  - rat
ER  -

HERE
    citation = Citation.from_ris(doc)[0]
    citation.should be_a ArticleCitation
  end

  it "should convert :type => :thesis to ThesisCitation" do
    doc = <<HERE
TY  - THES
KW  - rat
ER  -

HERE
    citation = Citation.from_ris(doc)[0]
    citation.should be_a ThesisCitation
  end

  it "should convert :type => :book to BookCitation" do
    doc = <<HERE
TY  - BOOK
KW  - rat
ER  -

HERE
    citation = Citation.from_ris(doc)[0]
    citation.should be_a BookCitation
  end

  it "should convert :type => :chap to ChapterCitation" do
    doc = <<HERE
TY  - CHAP
KW  - rat
ER  -

HERE
    citation = Citation.from_ris(doc)[0]
    citation.should be_a ChapterCitation
  end

  it "should convert :type => :conf to ConferenceCitation" do
    doc = <<HERE
TY  - CONF
KW  - rat
ER  -

HERE
    citation = Citation.from_ris(doc)[0]
    citation.should be_a ConferenceCitation
  end

  it "should convert :type => :rprt to ReportCitation" do
    doc = <<HERE
TY  - RPRT
KW  - rat
ER  -

HERE
    citation = Citation.from_ris(doc)[0]
    citation.should be_a ReportCitation
  end

  it "should convert :type => :gen to Citation" do
    doc = <<HERE
TY  - GEN
KW  - rat
ER  -

HERE
    citation = Citation.from_ris(doc)[0]
    citation.should be_a Citation
  end

    it 'should parse multiple ris stanzas' do
    doc = <<HERE
TY  - JOUR
AU  - Zenone, T.
AU  - Chen, J.
AU  - Deal, M.W.
AU  - Wilske, B.
AU  - Jasrotia, P.
AU  - Xu, J.
AU  - Bhardwaj, A.K.
AU  - Hamilton, S. K.
AU  - Robertson, G. P.
KW  - GLBRC T4; LTER pub
L1  - internal-pdf://Zenone et al 2011 GCBB-0122663789/Zenone et al 2011 GCBB.pdf
PY  - 2011
SP  - DOI: 10.1111/j.1757-1707.2011.01098.x
ST  - CO2 fluxes of transitional bioenergy crops: effect of land conversion during the first year of cultivation
T2  - Global Change Biology-Bioenergy
TI  - CO2 fluxes of transitional bioenergy crops: effect of land conversion during the first year of cultivation
ID  - 930
ER  -


TY  - JOUR
AU  - Syswerda, S.P.
AU  - Corbin, A.T.
AU  - Mokma, D.L.
AU  - Kravchenko, A. N.
AU  - Robertson, G.P.
DO  - 10.2136/sssaj2009.0414
KW  - LTER pub
L1  - internal-pdf://Syswerda etal. 2011-2756515844/Syswerda etal. 2011.pdf
PY  - 2011
SP  - 92-101
ST  - Agricultural management and soil carbon storage in surface vs. deep layers
T2  - Soil Science Society of America Journal
TI  - Agricultural management and soil carbon storage in surface vs. deep layers
VL  - 75
ID  - 907
ER  -

HERE
    citations = Citation.from_ris(doc)
    citations.count.should == 2
    first_citation = citations[0]
    first_citation.should be_a ArticleCitation
    first_citation.author_block.should == "Zenone, T\nChen, J\nDeal, M W\nWilske, B\nJasrotia, P\nXu, J\nBhardwaj, A K\nHamilton, S K\nRobertson, G P"
    first_citation.pub_year.should == 2011
    first_citation.start_page_number.should == nil
    first_citation.series_title.should == "CO2 fluxes of transitional bioenergy crops: effect of land conversion during the first year of cultivation"
    first_citation.secondary_title.should == "Global Change Biology-Bioenergy"
    first_citation.title.should == "CO2 fluxes of transitional bioenergy crops: effect of land conversion during the first year of cultivation"

    second_citation = citations[1]
    second_citation.should be_a ArticleCitation
    second_citation.author_block.should == "Syswerda, S P\nCorbin, A T\nMokma, D L\nKravchenko, A N\nRobertson, G P"
    second_citation.doi.should == "10.2136/sssaj2009.0414"
    second_citation.pub_year.should == 2011
    second_citation.series_title.should == "Agricultural management and soil carbon storage in surface vs. deep layers"
    second_citation.secondary_title.should == "Soil Science Society of America Journal"
    second_citation.title.should == "Agricultural management and soil carbon storage in surface vs. deep layers"
    second_citation.volume.should == "75"
  end
end
