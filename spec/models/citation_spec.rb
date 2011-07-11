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
  end
end
