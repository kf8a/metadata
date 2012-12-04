class EndnoteParser < Parslet::Parser

  rule(:space)      { match('\s') }
  rule(:space?)     { space.maybe }
  rule(:eof)        { any.absnt? }
  rule(:cr)         { match('\r') }
  rule(:lf)         { match('\n') }
  rule(:line)       { lf | cr >> lf }

  rule(:start_tag)  { str('TY - ') >> match('[A-Z]').repeat.as(:type) >> line }
  rule(:end_tag)    { str('ER - ') >> line }

  rule(:tag)        { match('[A-Z]').repeat(2) >> space >> 
                      str('-') >> space >> any.repeat }

  rule(:root)       { start_tag >> end_tag }
end
