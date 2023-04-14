require "prawn"

Prawn.debug = true
Prawn::Document.generate('tmp/implicit.pdf') do
  stroke_axis step_length: 20
  text 'Hello World'
end
system "open tmp/implicit.pdf"
