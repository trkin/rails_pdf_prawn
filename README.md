# Rails PDF Prawn

To generate PDF using ruby code we use Prawn https://github.com/prawnpdf/prawn

## Install

There are no external dependencies, so you just need to have a ruby and install
with

```
gem install prawn
```

Inside rails you can add go Gemfile and run with rails console
```
bundle add prawn
rails c
```

for example create file with implicit block
https://github.com/prawnpdf/prawn/blob/master/manual/basic_concepts/creation.rb#L30
```
Prawn::Document.generate('implicit.pdf') do
  stroke_axis
  text 'Hello World'
end
system "open implicit.pdf"
```

or you can put that in a file and just call
```
ruby lib/example.rb
```

or run listen
```
bundle exec ruby lib/listen.rb
```

## Usage

You can read docs at http://prawnpdf.org/manual.pdf but it is generated from the
source like https://github.com/prawnpdf/prawn/blob/master/manual/basic_concepts/origin.rb

* `text "my_text"` add text at cursor position, cursor will decrease after this
  by 13.87.
  You can use `"New\nline"` to go to second line
* `stroke_axis` add axis, bottom left is (0,0), `stroke_axis step_length: 20`
* `bounding_box [x, y], widht: 100, height: 200 do` where x is horizontal 0-540
  and y is verical 720-0, we need to set top-left corner, so it could be
  `bounding_box [0, cursor], width: 100 do` (width is required, box will
  stretch if height it not provided). You can print
  current bounds with `text [bounds.top, bounds.bottom, bounds.left,
  bounds.right].join(" ")` returns `720.0 0 0 540.0`. There is
  `bounds.absolute_left # 36` so default page margin is 36 in all directions
  (you can draw on absolute coordinates using `canvas { text bounds.right.to_s
  }` this will print 540 + 2 * 36 = 612, default height is 720 + 72 = 792)
  Inside `bounding_box` the `bounds.top` returns relative to it eg `height`, ie
  bottom and left are always 0. `bounts.top` can be used to nest another text
  box with padding `gap = 20; bounding_box([gap, bounds.top - gap], width:
  bounds.right - 2 * gap, height: bounds.top - 2 * gap) do`. Shorthand for
  horizontal padding is `indent 40` (this will create bounding_box at [40,
  cursor]). Shorthand `top_left` like `draw_text "Hi", at: bounds.top_left`
  To see border use `transparent(0.5) { dash(1);stroke_bounds;undash }`
* `cursor` returns position from the bottom and it goes down with each `text`.
  You can move with `move_down 100`, `move_cursor_to 50`
* `stroke_horizontal_rule` add a line, cursor is moved by one. You can specify
  position `horizontal_line left1, left2, at: y` and `vertical_line`
* `pad(20) { text "Hi" }` add padding, `pad_top` just top, `float do` do not
  move cursor
* `start_new_page`
* one point is less than one mm, and you can use extension to call `1.mm`
  https://github.com/prawnpdf/prawn/blob/master/manual/basic_concepts/measurement.rb
* `line [x, y], [bottom, right]`, `rectangle [x, y], width, height`,
  `circle [x, y], radius`, `ellipse [x, y], r1, r2` and you can call
  `fill` or `stroke`, applies to previous element or you can use block syntax,
  or `stroke_line` or `fill_rectangle`
  https://github.com/prawnpdf/prawn/blob/master/manual/graphics/fill_and_stroke.rb
  For text there are `fill_color`, `stroke_color`. Also you can disable fill on
  text with `text "my text", mode: :stroke` or enable both `text_rendering_mode
  :fill_stroke do`
* `move_to 0, 0`, `line_to 100, 100`, `curve_to [x, y], bounds: [[],[]]`
  https://github.com/prawnpdf/prawn/blob/master/manual/graphics/lines_and_curves.rb
* `self.line_width = 10`, `self.cap_style = "butt"`
* `blend_mode "Normal " do` https://github.com/prawnpdf/prawn/blob/master/manual/graphics/blend_mode.rb
* `rotate 90 , origin: [250, 200] do`
* `translate x, y do` move the cursor and axis so they can start from 0,0
* `draw_text "my text", at: [x, y]` will be absolute positioned and no wrap
* `text_box "my text", at: [x, y], width: 80, size: 8, align: :center` wrap and
  truncate if can not fit the box, `overflow: :shrink_to_fit` (font size shrunk
  to fit) or `:expand` (box increases). With `:shrink_to_fit` you can use
  `min_font_size: 10` so font will be decreased untill 10 is reached.
  https://github.com/prawnpdf/prawn/blob/master/manual/text/text_box_overflow.rb
* `excess_text = text_box "my test", width: 10, height: 10, overflow: :truncate`
  you can use return value as text that did not fit the box
* `column_box [0, cursor], columns: 2, width: bounds.width do`
* `font('Courier', size: 10, style: :bold) do` Default is `font('Helvetica',
  size: 12)`
* `defult_leading 5` space between lines. Another way is `text "my text",
  leading: 10`.
* `text_box "With kerning", kerning: true` adjust spacing between chars
* `text "my text", character_spacing: 2` increase space
* since prawn strip strings, we need to use `text "#{Prawn::Text::NBSP * 10}"`
  or `text "indent", indent_paragraphs: 60`
* html tags are supported `text "my <b>bold</b>, <i>italic</i>,
  <u>underline</u>, <strikethrough>strikethrough</strikethrough>,
  <sub>subscript</sub>, <sup>superscript</sup>`, also `<font size="123"
  name="Courier" character_spacing="2">`, `<color rgb="ff00ff"><color>` and
  `<link href="https://asd.com"></link>`. Instead of tags you can use formated
  `formatted_text_box [ { text: "my text", font: "Courier" }, { text: "Next
  text", styles: [:italic] } ]`. If you want to apply styles to formated text
  you can use `callback:`
  https://github.com/prawnpdf/prawn/blob/master/manual/text/formatted_callbacks.rb
* grid is defined with `define_grid(columns: 5, rows: 8, gutter: 10)`. You can
  show all `grid.show_all` or work with specific boxes `grid([5,0],
  [7,1]).bounding_box do`. Index is (vertical (from top), horizontal) pair
* `image "#{Prawn::DATADIR}/images/pigs.jpg", position: :right`. Using `at:
  [x,y]` will not move the cursor so the text probably overlaps.
  text and image can accept `valign: :center` (top, bottom). You can use `scale:
  2`, `width: 100, height: 200` to stretch image, `fit: [200, 300]` to fit.
* define margins `Prawn::Document.generate file_name, margin: 100, page_size:
  "A3", page_layout: :landscape, background: my_img` and meta info `info = {
  Title: "My title", Author: "John", Subject: "My Sub", Creator: "My Comp",
  Producer: "Prawn", CreationDate: Time.now }`.
* table of content index outline tree is defined with `outline.define do` and
  `section "title", destination: 1 do` (section accept block to create nested
  index) or `page title: "title", destination: 2`. You can define index later
  with `outline.add_subsection_to "title", :first do` or
  `outline.insert_section_after "title"`
* `repeat :all do` , `:odd, :even, [1..]`. Use `repeat(2.., dynamic: true) {
  draw_text page_number - 1, at: bounds.top_left }` to add page numbers, but
  there is a function for page numbers `number_pages at: [bounds.right - 100,
  0], align: :right, start_count_at: 1` but should be called after all pages
* You can set password and permissions do prevent print or copy text
  https://github.com/prawnpdf/prawn/blob/master/manual/security/permissions.rb
  `ruby manual/security/permissions.rb ; open no_permissions.pdf` insert `foo`
* current file `File.basename(__FILE__)`
