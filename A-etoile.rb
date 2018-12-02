ptVaisseau=[]
pts=[]

def formatPt(pt)
  ptFmt=pt.clone
  ptFmt[0]=(ptFmt[0]*596)/7000
  ptFmt[1]=(ptFmt[1]*391)/3000
  return ptFmt
end
  
def formatPts(pts)
  ptsFmt = pts.clone
  ptsFmt.each do |pt|
    pt[0]=(pt[0]*596)/7000
    pt[1]=(pt[1]*391)/3000
  end
  return ptsFmt
end

if ARGV[0].to_i==0
  ptVaisseau=[6500,2600]
  
  pts.push([0, 450])
  pts.push([300, 750])
  pts.push([1000, 450])
  pts.push([1500, 650])
  pts.push([1800, 850])
  pts.push([2000, 1950])
  pts.push([2200, 1850])
  pts.push([2400, 2000])
  pts.push([3100, 1800])
  pts.push([3150, 1550])
  pts.push([2500, 1600])
  pts.push([2200, 1550])
  pts.push([2100, 750])
  pts.push([2200, 150])
  pts.push([3200, 150])
  pts.push([3500, 450])
  pts.push([4000, 950])
  pts.push([4500, 1450])
  pts.push([5000, 1550])
  pts.push([5500, 1500])
  pts.push([6000, 950])
  pts.push([6999, 1750])
else
  ptVaisseau=[6500,2000]

  pts.push([0,1800])
  pts.push([300,1200])
  pts.push([1000,1550])
  pts.push([2000,1200])
  pts.push([2500,1650])
  pts.push([3700,220])
  pts.push([4700,220])
  pts.push([4750,1000])
  pts.push([4700,1650])
  pts.push([4000,1700])
  pts.push([3700,1600])
  pts.push([3750,1900])
  pts.push([4000,2100])
  pts.push([4900,2050])
  pts.push([5100,1000])
  pts.push([5500,500])
  pts.push([6200,800])
  pts.push([6999,600])
end

open('A-etoile.ps', 'w') { |f|
  f.puts "%!PS-Adobe-3.0"
  f.puts "%%BoundingBox: 0 0 596 792"
  f.puts "1 0 0 setrgbcolor"
  f.puts "3 setlinewidth"
  ptsFmt=formatPts(pts)
  ptsFmt.each_cons(2) do |pt1, pt2|
    f.puts "#{pt1[0]} #{pt1[1]} moveto"
    f.puts "#{pt2[0]} #{pt2[1]} lineto"
    f.puts "stroke"
  end
  ptVaisFmt = formatPt(ptVaisseau)
  f.puts "#{ptVaisFmt[0]} #{ptVaisFmt[1]} 3 0 360 arc"
  f.puts "fill"
  f.puts "stroke"
}
system('ps2pdf A-etoile.ps')
