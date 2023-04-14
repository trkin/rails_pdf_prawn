require 'listen'

listener = Listen.to('./lib') do |modified, added, removed|
  puts(modified: modified, added: added, removed: removed)
  load "lib/example.rb"
end
listener.start
sleep
