def main
  ptVaisseau=[]
  pts=[]
  
  def formatPt(pt)
    ptFmt=pt.clone
    ptFmt[0]=(ptFmt[0]*596)/7000
    ptFmt[1]=(ptFmt[1]*255)/3000
    return ptFmt
  end
  
  def formatPts(pts)
    ptsFmt = pts.clone
    ptsFmt.each do |pt|
      pt[0]=(pt[0]*596)/7000
      pt[1]=(pt[1]*255)/3000
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
  
=begin
     ptVaisFmt = formatPt(ptVaisseau)
  i=0
  50.times{
    open('A-etoile.ps', 'a') { |f|
      f.puts "#{ptVaisFmt[0]-i} #{ptVaisFmt[1]} 3 0 360 arc"
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

def neighs(e)
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
  while tFather.include?(e)
    e=tFather[e]
    tPath << e
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

q = NaivePriorityQueue.new
q<<{x:7,y:1,cost:0,heuristic:3}
q<<{x:5,y:3,cost:0,heuristic:8}
q<<{x:6,y:2,cost:0,heuristic:2}

p q.pop
p q.findWithCostInf({x:6,y:2,cost:0,heuristic:2})
p q.find({x:6,y:3,cost:-1,heuristic:2})
p distance({x:7,y:1,cost:0,heuristic:3}, {x:5,y:3,cost:0,heuristic:8})
p q.empty?
p neighs({x:3,y:7})

tFather=[]
tFather<< {{x:3,y:7}=>{x:7,y:13}}
p reconstructPath(tFather, {x:7,y:13})
