PositiveInfinity = +1.0/0.0

def main
  ptVaisseau={}
  pts=[]
  
  def formatPt(pt)
    ptFmt=pt.clone
    ptFmt[:x]=(ptFmt[:x]*596)/7000
    ptFmt[:y]=(ptFmt[:y]*255)/3000
    return ptFmt
  end
  
  def formatPts(pts)
    ptsFmt = pts.clone
    ptsFmt.each do |pt|
      pt[:x]=(pt[:x]*596)/7000
      pt[:y]=(pt[:y]*255)/3000
    end
    return ptsFmt
  end

  if ARGV[0].to_i==0
    ptVaisseau={x:6500,y:2600}
    
    pts << {x:0,y:450}
    pts << {x:300,y:750}
    pts << {x:1000,y:450}
    pts << {x:1500,y:650}
    pts << {x:1800,y:850}
    pts << {x:2000,y:1950}
    pts << {x:2200,y:1850}
    pts << {x:2400,y:2000}
    pts << {x:3100,y:1800}
    pts << {x:3150,y:1550}
    pts << {x:2500,y:1600}
    pts << {x:2200,y:1550}
    pts << {x:2100,y:750}
    pts << {x:2200,y:150}
    pts << {x:3200,y:150}
    pts << {x:3500,y:450}
    pts << {x:4000,y:950}
    pts << {x:4500,y:1450}
    pts << {x:5000,y:1550}
    pts << {x:5500,y:1500}
    pts << {x:6000,y:950}
    pts << {x:6999,y:1750}
  else
    ptVaisseau={x:6500,y:2000}

    pts << {x:0,y:1800}
    pts << {x:300,y:1200}
    pts << {x:1000,y:1550}
    pts << {x:2000,y:1200}
    pts << {x:2500,y:1650}
    pts << {x:3700,y:220}
    pts << {x:4700,y:220}
    pts << {x:4750,y:1000}
    pts << {x:4700,y:1650}
    pts << {x:4000,y:1700}
    pts << {x:3700,y:1600}
    pts << {x:3750,y:1900}
    pts << {x:4000,y:2100}
    pts << {x:4900,y:2050}
    pts << {x:5100,y:1000}
    pts << {x:5500,y:500}
    pts << {x:6200,y:800}
    pts << {x:6999,y:600}
  end

  open('A-etoile.ps', 'w') { |f|
    f.puts "%!PS-Adobe-3.0"
    f.puts "%%BoundingBox: 0 0 596 792"
    f.puts "1 0 0 setrgbcolor"
    f.puts "3 setlinewidth"
    ptsFmt=formatPts(pts)
    ptsFmt.each_cons(2) do |pt1, pt2|
      f.puts "#{pt1[:x]} #{pt1[:y]} moveto"
      f.puts "#{pt2[:x]} #{pt2[:y]} lineto"
      f.puts "stroke"
    end
    ptVaisFmt = formatPt(ptVaisseau)
    f.puts "#{ptVaisFmt[:x]} #{ptVaisFmt[:y]} 3 0 360 arc"
    f.puts "fill"
    f.puts "stroke"  
  }
  system('ps2pdf A-etoile.ps')
  
=begin
     ptVaisFmt = formatPt(ptVaisseau)
  i=0
  50.times{
    open('A-etoile.ps', 'a') { |f|
      f.puts "#{ptVaisFmt[:x]-i} #{ptVaisFmt[:y]} 3 0 360 arc"
      f.puts "fill"
      f.puts "stroke"
    }
    system('ps2pdf A-etoile.ps')
    i+=5
    sleep 0.1
  }
=end
end

main

def _findWithCostInf(tE,e)
  return tE.find{|e0|e0[:x]==e[:x]&&e0[:y]==e[:y]&&e0[:cost]<e[:cost]}!=nil
end

def distance(e1,e2)
  Math.sqrt((e1[:x]-e2[:x])**2+(e1[:y]-e2[:y])**2)
end

def neighbors(e)
  tNeigh=[]
  tNeigh<<{x:e[:x],y:e[:y]+1}
  tNeigh<<{x:e[:x],y:e[:y]-1}
  tNeigh<<{x:e[:x]+1,y:e[:y]}
  tNeigh<<{x:e[:x]-1,y:e[:y]}
  tNeigh<<{x:e[:x]+1,y:e[:y]+1}
  tNeigh<<{x:e[:x]+1,y:e[:y]-1}
  tNeigh<<{x:e[:x]-1,y:e[:y]+1}
  tNeigh<<{x:e[:x]-1,y:e[:y]-1}
  return tNeigh
end

def reconstructPath(tFather,e)
  tPath=[]
  tPath << e
  while tFather.include?(e)
    e=tFather[e]
    tPath.unshift e
  end
  return tPath
end

class NaivePriorityQueue
  def initialize
    @m_tE = []
  end
  def <<(e)
    @m_tE << e
  end
  def pop
    @m_tE.sort!{|e1,e2| e1[:heuristic]<=>e2[:heuristic]}
    @m_tE.delete_at(0)
  end
  def findWithCostInf(e)
    return _findWithCostInf(@m_tE,e)
  end
  def find(e)
    return @m_tE.find{|e0|e0[:x]==e[:x]&&e0[:y]==e[:y]}!=nil
  end
  def empty?
    return @m_tE.empty?
  end
end

def segment(tPt1, tPt2)
  tSegment=[]
  tPtI=[]
  tPtF=[]
  if tPt2[:x]>tPt1[:x] || (tPt2[:x]==tPt1[:x] && tPt2[:y]>tPt1[:y])
    tPtI=tPt1.clone
    tPtF=tPt2.clone
  else
    tPtI=tPt2.clone
    tPtF=tPt1.clone
  end
  if tPtI[:x]!=tPtF[:x]
    nDX=tPtF[:x]-tPtI[:x]
    nDY=tPtF[:y]-tPtI[:y]
    nCoef=nDY.to_f/nDX.to_f
    for i in tPtI[:x]..tPtF[:x] do
      tSegment<< {x:i,y:tPtI[:y]+((i-tPtI[:x])*nCoef).round}
    end
  else
    for i in tPtI[:y]..tPtF[:y] do
      tSegment<< {x:tPtI[:x],y:i}
    end
  end
  return tSegment
end

def initGraph(tSurface, tBord)
  tGraph=[]
  tSurface.each do |pt|

  end
  return tGraph
end

def border
  bord=[]
  bord+=segment({x:0,y:0},{x:596,y:0})
  bord+=segment({x:596,y:0},{x:596,y:255})
  bord+=segment({x:596,y:255},{x:0,y:255})
  bord+=segment({x:0,y:255},{x:0,y:0})
  return bord
end

q = NaivePriorityQueue.new
q<<{x:7,y:1,cost:0,heuristic:3}
q<<{x:5,y:3,cost:0,heuristic:8}
q<<{x:6,y:2,cost:0,heuristic:2}

p q.pop
p q.findWithCostInf({x:6,y:2,cost:0,heuristic:2})
p q.find({x:6,y:3,cost:-1,heuristic:2})
p distance({x:7,y:1,cost:0,heuristic:3}, {x:5,y:3,cost:0,heuristic:8})
p q.empty?
p neighbors({x:3,y:7})

tFather={}
tFather[{x:7,y:13}]={x:0,y:0}
tFather[{x:3,y:7}]={x:7,y:13}
p reconstructPath(tFather, {x:3,y:7})

p segment({x:-5,y:3},{x:-2,y:-3})
#p border
p segment({x:0,y:0},{x:1,y:255})
