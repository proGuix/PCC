PosInf=+1.0/0.0
hSpaceShip={}
hLandPoint={}
tSurface=[]

def formatPt(pt)
  ptFmt={x:(ptFmt[:x]*596)/7000,y:(ptFmt[:y]*255)/3000}
  return ptFmt
end

def formatSurface(tSurface)
  tSurfaceFmt = []
  tSurface.each do |pt|
    tSurfaceFmt<<{x:(pt[:x]*596)/7000,y:(pt[:y]*255)/3000}
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

def reconstructPath(hFather,hFinish)
  tPath=[]
  if hFather.empty?
    tPath<< hFinish
  else
    hCurrent=(hFather.keys.select{|hKey|hKey[:x]==hFinish[:x]&&hKey[:y]==hFinish[:y]}[0])
    tPath << hCurrent
    loop do
      hCurrent=hFather[hCurrent]
      break if hCurrent==nil
      tPath.unshift hCurrent
    end
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
  if tPt2==tPt1
    tSeg2Ar<< tPt1.clone
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
  hFinish=hLandPoint.clone
  hFinish[:cost]=-1
  hFinish[:heuristic]=0
  hStart=hSpaceShip.clone
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

hSpaceShip={x:1,y:1}
hLandPoint={x:9,y:9}
tSurface=[{x:0,y:2},{x:2,y:2}]
tGraph=initGraph({x:10,y:10},obstacle(tSurface))
tGraph,hStart,hFinish=initStartAndFinish(tGraph,hSpaceShip,hLandPoint)

tOpenSet=NaivePriorityQueue.new
tClosedSet=[]
hFather={}

tOpenSet<< hStart
while !(tOpenSet.empty?) do
  hCurrent=tOpenSet.pop
  if (hCurrent[:x]==hFinish[:x])&&(hCurrent[:y]==hFinish[:y])
    p reconstructPath(hFather, hCurrent)
#    exit
  end
  tClosedSet<< hCurrent
  tNeigh=neighbors(hCurrent)
  tNeigh.each do |hNeigh|
    if tClosedSet.select{|hPt|hPt[:x]==hNeigh[:x]&&hPt[:y]==hNeigh[:y]}.empty?
      hNGraph=tGraph.select{|hPt|hPt[:x]==hNeigh[:x]&&hPt[:y]==hNeigh[:y]}[0]
      if hNGraph==nil||(hNGraph!=nil&&hNGraph[:cost]!=PosInf)
        nCost=hCurrent[:cost]+distance(hCurrent,hNeigh)
        hNOpenSet=tOpenSet.select(hNeigh)        
        if hNOpenSet==nil
          hNeighNew=hNeigh.clone
          hNeighNew[:cost]=nCost
          hNeighNew[:heuristic]=nCost+distance(hNeighNew,hFinish)
          tOpenSet<< hNeighNew
          hFather[hNeighNew]=hCurrent
        elsif hNOpenSet[:cost]>nCost
          hNOpenSet[:cost]=nCost
          hNOpenSet[:heuristic]=hNOpenSet[:cost]+distance(hNOpenSet,hFinish)
          hFather.reject!{|hKey|hKey[:x]==hNOpenSet[:x]&&hKey[:y]==hNOpenSet[:y]}
          hFather[hNOpenSet]=hCurrent
        end
      end
    end
  end
end
