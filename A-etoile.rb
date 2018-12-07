PosInf=+1.0/0.0
hSpaceShip={}
hLandPoint={}
tSurface=[]

def formatPt(pt)
  ptFmt=pt.clone
  ptFmt[:x]=(ptFmt[:x]*596)/7000
  ptFmt[:y]=(ptFmt[:y]*255)/3000
  return ptFmt
end

def formatSurface(tSurface)
  tSurfaceFmt = tSurface.clone
  tSurfaceFmt.each do |pt|
    pt[:x]=(pt[:x]*596)/7000
    pt[:y]=(pt[:y]*255)/3000
  end
  return tSurfaceFmt
end

if ARGV[0].to_i==0
  hSpaceShip={x:6500,y:2600}
  hLandPoint={x:2700,y:150}
  
  tSurface << {x:0,y:450}
  tSurface << {x:300,y:750}
  tSurface << {x:1000,y:450}
  tSurface << {x:1500,y:650}
  tSurface << {x:1800,y:850}
  tSurface << {x:2000,y:1950}
  tSurface << {x:2200,y:1850}
  tSurface << {x:2400,y:2000}
  tSurface << {x:3100,y:1800}
  tSurface << {x:3150,y:1550}
  tSurface << {x:2500,y:1600}
  tSurface << {x:2200,y:1550}
  tSurface << {x:2100,y:750}
  tSurface << {x:2200,y:150}
  tSurface << {x:3200,y:150}
  tSurface << {x:3500,y:450}
  tSurface << {x:4000,y:950}
  tSurface << {x:4500,y:1450}
  tSurface << {x:5000,y:1550}
  tSurface << {x:5500,y:1500}
  tSurface << {x:6000,y:950}
  tSurface << {x:6999,y:1750}
else
  hSpaceShip={x:6500,y:2000}
  hLandPoint={x:4200,y:220}
  
  tSurface << {x:0,y:1800}
  tSurface << {x:300,y:1200}
  tSurface << {x:1000,y:1550}
  tSurface << {x:2000,y:1200}
  tSurface << {x:2500,y:1650}
  tSurface << {x:3700,y:220}
  tSurface << {x:4700,y:220}
  tSurface << {x:4750,y:1000}
  tSurface << {x:4700,y:1650}
  tSurface << {x:4000,y:1700}
  tSurface << {x:3700,y:1600}
  tSurface << {x:3750,y:1900}
  tSurface << {x:4000,y:2100}
  tSurface << {x:4900,y:2050}
  tSurface << {x:5100,y:1000}
  tSurface << {x:5500,y:500}
  tSurface << {x:6200,y:800}
  tSurface << {x:6999,y:600}
end
=begin
open('A-etoile.ps', 'w') { |f|
  f.puts "%!PS-Adobe-3.0"
  f.puts "%%BoundingBox: 0 0 596 792"
  f.puts "1 0 0 setrgbcolor"
  f.puts "3 setlinewidth"
  tSurfaceFmt=formatSurface(tSurface)
  tSurfaceFmt.each_cons(2) do |pt1, pt2|
    f.puts "#{pt1[:x]} #{pt1[:y]} moveto"
    f.puts "#{pt2[:x]} #{pt2[:y]} lineto"
    f.puts "stroke"
  end
  ptVaisFmt = formatPt(tSpaceShip)
  f.puts "#{ptVaisFmt[:x]} #{ptVaisFmt[:y]} 3 0 360 arc"
  f.puts "fill"
  f.puts "stroke"  
}
system('ps2pdf A-etoile.ps')

tSpaceShipFmt = formatPt(tSpaceShip)
i=0
50.times{
  open('A-etoile.ps', 'a') { |f|
    f.puts "#{tSpaceShipFmt[:x]-i} #{tSpaceShipFmt[:y]} 3 0 360 arc"
    f.puts "fill"
    f.puts "stroke"
  }
  system('ps2pdf A-etoile.ps')
  i+=5
  sleep 0.1
}
=end

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
  while (tFather.select{|hPt|hPt[:x]==e[:x]&&hPt[:y]==e[:y]}.empty?)
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
  def select(e)
    return @m_tE.select{|e0|e0[:x]==e[:x]&&e0[:y]==e[:y]}[0]
  end
  def empty?
    return @m_tE.empty?
  end
end

def segment2Array(tPt1, tPt2)
  tSeg2Ar=[]
  tPtI=[]
  tPtF=[]
  if tPt2[:x]!=tPt1[:x]
    if tPt2[:x]>tPt1[:x]
      tPtI=tPt1.clone
      tPtF=tPt2.clone
    else
      tPtI=tPt2.clone
      tPtF=tPt1.clone
    end
    nDX=tPtF[:x]-tPtI[:x]
    nDY=tPtF[:y]-tPtI[:y]
    nCoef=nDY.to_f/nDX.to_f
    for i in tPtI[:x]..tPtF[:x] do
      tSeg2Ar<< {x:i,y:tPtI[:y]+((i-tPtI[:x])*nCoef).round}
    end
  end
  if tPt2[:y]!=tPt1[:y]
    if tPt2[:y]>tPt1[:y]
      tPtI=tPt1.clone
      tPtF=tPt2.clone
    else
      tPtI=tPt2.clone
      tPtF=tPt1.clone
    end
    nDX=tPtF[:x]-tPtI[:x]
    nDY=tPtF[:y]-tPtI[:y]
    nCoef=nDX.to_f/nDY.to_f
    for i in tPtI[:y]..tPtF[:y] do
      tSeg2Ar<< {x:tPtI[:x]+((i-tPtI[:y])*nCoef).round,y:i}
    end
  end
  tSeg2Ar.uniq!
  return tSeg2Ar
end

def initGraph(hVectBord,tObstacle)
  tGraph=[]
  tBord=border(hVectBord)
  tBord.each do |pt|
    pt[:cost]=PosInf
    pt[:heuristic]=PosInf
  end
  tGraph+=tBord
  tGraph.uniq!
  tObstacleCpy=tObstacle.clone
  tObstacleCpy.each do |pt|
    hVertex=tGraph.select{|hPt|hPt[:x]==pt[:x]&&hPt[:y]==pt[:y]}[0]
    if hVertex!=nil
      hVertex[:cost]=PosInf
      hVertex[:heuristic]=PosInf
    else
      pt[:cost]=PosInf
      pt[:heuristic]=PosInf
      tGraph<< pt
    end
  end
  return tGraph
end

def initStartAndFinish(tGraph,hSpaceShip,hLandPoint)
  hFinish={}
  hFinish[:x]=hLandPoint[:x]
  hFinish[:y]=hLandPoint[:y]
  hFinish[:cost]=-1
  hFinish[:heuristic]=-1
  hStart={}
  hStart[:x]=hSpaceShip[:x]
  hStart[:y]=hSpaceShip[:y]
  hStart[:cost]=0
  hStart[:heuristic]=distance(hStart, hFinish)
  hVertex=tGraph.select{|hPt|hPt[:x]==hFinish[:x]&&hPt[:y]==hFinish[:y]}[0]
  if hVertex!=nil
    hVertex[:cost]=hFinish[:cost]
    hVertex[:heuristic]=hFinish[:heuristic]
  else
    tGraph<< hFinish
  end
    hVertex=tGraph.select{|hPt|hPt[:x]==hStart[:x]&&hPt[:y]==hStart[:y]}[0]
  if hVertex!=nil
    hVertex[:cost]=hStart[:cost]
    hVertex[:heuristic]=hStart[:heuristic]
  else
    tGraph<< hStart
  end
  return tGraph,hStart,hFinish
end

def border(hVectBord)
  bord=[]
  bord+=segment2Array({x:0,y:0},{x:hVectBord[:x],y:0})
  bord+=segment2Array({x:hVectBord[:x],y:0},{x:hVectBord[:x],y:hVectBord[:y]})
  bord+=segment2Array({x:hVectBord[:x],y:hVectBord[:y]},{x:0,y:hVectBord[:y]})
  bord+=segment2Array({x:0,y:hVectBord[:y]},{x:0,y:0})
  return bord
end

def obstacle(tSurface)
  tObstacle=[]
  tSurface.each_cons(2) do |pt1, pt2|
    tObstacle+=segment2Array(pt1,pt2)
  end
  return tObstacle
end

#p q.pop
#p q.findWithCostInf({x:6,y:2,cost:0,heuristic:2})
#p q.find({x:6,y:3,cost:-1,heuristic:2})
#p distance({x:7,y:1,cost:0,heuristic:3}, {x:5,y:3,cost:0,heuristic:8})
#p q.empty?
#p neighbors({x:3,y:7})

#tFather={}
#tFather[{x:7,y:13}]={x:0,y:0}
#tFather[{x:3,y:7}]={x:7,y:13}
#p reconstructPath(tFather, {x:3,y:7})
#p segment2Array({x:-2,y:-3},{x:2,y:3})
#p border({x:7000,y:3000})
#p obstacle(tSurface)
hSpaceShip={x:2,y:1}
hLandPoint={x:1,y:1}
tSurface=[{x:2,y:2},{x:1,y:2}]
tGraph=initGraph({x:3,y:3},obstacle(tSurface))
tGraph,hStart,hFinish=initStartAndFinish(tGraph,hSpaceShip,hLandPoint)
#p tGraph

tOpenSet=NaivePriorityQueue.new
tClosedSet=[]
hFather={}

tOpenSet<< hStart
i=0
while !(tOpenSet.empty?) do
  p "tOpenSet"
  p tOpenSet
  hCurrent=tOpenSet.pop
  p "hCurrent"
  p hCurrent
  p "tOpenSet"
  p tOpenSet
  if (hCurrent[:x]==hFinish[:x])&&(hCurrent[:y]==hFinish[:y])
    p "reconstructPath"
    p reconstructPath(hFather, hFinish)
  end
  tClosedSet<< hCurrent
  p tClosedSet
  tNeigh=neighbors(hCurrent)
  p "tNeigh"
  p tNeigh
  tNeigh.each do |hNeigh|
    if tClosedSet.select{|hPt|hPt[:x]==hNeigh[:x]&&hPt[:y]==hNeigh[:y]}.empty?
      hNGraph=tGraph.select{|hPt|hPt[:x]==hNeigh[:x]&&hPt[:y]==hNeigh[:y]}[0]
      if hNGraph==nil||(hNGraph!=nil&&hNGraph[:cost]!=PosInf)
        nCost=hCurrent[:cost]+distance(hCurrent,hNeigh)
        hNOpenSet=tOpenSet.select(hNeigh)
        p "hHOpenSet"
        p hNOpenSet
        
        if hNOpenSet==nil
          hNeighConstruct={}
          hNeighConstruct[:x]=hNeigh[:x]
          hNeighConstruct[:y]=hNeigh[:y]
          hNeighConstruct[:cost]=nCost
          hNeighConstruct[:heuristic]=nCost+distance(hNeighConstruct,hFinish)
          tOpenSet<< hNeighConstruct
          hFather[hNeigh]=hCurrent
        elsif hNOpenSet[:cost]>nCost
          hNOpenSet[:cost]=nCost
          hNOpenSet[:heuristic]=hNOpenSet[:cost]+distance(hNOpenSet,hFinish)
          hFather[hNeigh]=hCurrent
        end
        p "tOpenSet"
        p tOpenSet
        p "hFather"
        p hFather
      end
    end
    i+=1
  end
end
