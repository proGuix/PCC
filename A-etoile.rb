open('A-etoile.ps', 'w') { |f|
  f.puts ""
  f.puts "%!PS-Adobe-3.0"
  f.puts "%%BoundingBox: 0 0 612 792"
  f.puts "0.5 setgray"
  f.puts "100 100 moveto"
  f.puts "200 200 lineto"
  f.puts "stroke"
}
system('ps2pdf A-etoile.ps')
