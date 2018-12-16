require './A_etoile_mod'
include A_etoile

hSpaceShip={}
hLandPoint={}
tSurface=[]
hVectBord={}

if ARGV[0]=='0'
  hSpaceShip={x:6500,y:2600}
  hLandPoint={x:2700,y:150}
  hVectBord={x:7000,y:3000}
  
  tSurface << [{x:0,y:450},{x:300,y:750}]
  tSurface << [{x:300,y:750},{x:1000,y:450}]
  tSurface << [{x:1000,y:450},{x:1500,y:650}]
  tSurface << [{x:1500,y:650},{x:1800,y:850}]
  tSurface << [{x:1800,y:850},{x:2000,y:1950}]
  tSurface << [{x:2000,y:1950},{x:2200,y:1850}]
  tSurface << [{x:2200,y:1850},{x:2400,y:2000}]
  tSurface << [{x:2400,y:2000},{x:3100,y:1800}]
  tSurface << [{x:3100,y:1800},{x:3150,y:1550}]
  tSurface << [{x:3150,y:1550},{x:2500,y:1600}]
  tSurface << [{x:2500,y:1600},{x:2200,y:1550}]
  tSurface << [{x:2200,y:1550},{x:2100,y:750}]
  tSurface << [{x:2100,y:750},{x:2200,y:150}]
  tSurface << [{x:2200,y:150},{x:3200,y:150}]
  tSurface << [{x:3200,y:150},{x:3500,y:450}]
  tSurface << [{x:3500,y:450},{x:4000,y:950}]
  tSurface << [{x:4000,y:950},{x:4500,y:1450}]
  tSurface << [{x:4500,y:1450},{x:5000,y:1550}]
  tSurface << [{x:5000,y:1550},{x:5500,y:1500}]
  tSurface << [{x:5500,y:1500},{x:6000,y:950}]
  tSurface << [{x:6000,y:950},{x:6999,y:1750}]
elsif ARGV[0]=='1'
  hSpaceShip={x:6500,y:2000}
  hLandPoint={x:4200,y:220}
  hVectBord={x:7000,y:3000}
  
  tSurface << [{x:0,y:1800},{x:300,y:1200}]
  tSurface << [{x:300,y:1200},{x:1000,y:1550}]
  tSurface << [{x:1000,y:1550},{x:2000,y:1200}]
  tSurface << [{x:2000,y:1200},{x:2500,y:1650}]
  tSurface << [{x:2500,y:1650},{x:3700,y:220}]
  tSurface << [{x:3700,y:220},{x:4700,y:220}]
  tSurface << [{x:4700,y:220},{x:4750,y:1000}]
  tSurface << [{x:4750,y:1000},{x:4700,y:1650}]
  tSurface << [{x:4700,y:1650},{x:4000,y:1700}]
  tSurface << [{x:4000,y:1700},{x:3700,y:1600}]
  tSurface << [{x:3700,y:1600},{x:3750,y:1900}]
  tSurface << [{x:3750,y:1900},{x:4000,y:2100}]
  tSurface << [{x:4000,y:2100},{x:4900,y:2050}]
  tSurface << [{x:4900,y:2050},{x:5100,y:1000}]
  tSurface << [{x:5100,y:1000},{x:5500,y:500}]
  tSurface << [{x:5500,y:500},{x:6200,y:800}]
  tSurface << [{x:6200,y:800},{x:6999,y:600}]
else
  hSpaceShip = {x:1,y:1}
  hLandPoint = {x:9,y:9}
  hVectBord = {x:10,y:10}
  tSurface << [{x:0,y:2},{x:2,y:2}]
end

tGraph=A_etoile::initGraph(hVectBord,A_etoile::obstacle(tSurface))
tGraph,hStart,hFinish=A_etoile::initStartAndFinish(tGraph,hSpaceShip,hLandPoint)
tOpenSet=A_etoile::NaivePriorityQueue.new
tClosedSet=[]
hFather={}
tOpenSet<< hStart
while !(tOpenSet.empty?) do
  hCurrent=tOpenSet.pop
  p "Current node : " + hCurrent.to_s
  if (hCurrent[:x]==hFinish[:x])&&(hCurrent[:y]==hFinish[:y])
    p "Final path : " + A_etoile::reconstructPath(hFather, hCurrent).to_s
    exit
  end
  tClosedSet<< hCurrent
  tNeigh=neighbors(hCurrent, tGraph, tSurface)
  tNeigh.each do |hNeigh|
    if tClosedSet.select{|hPt|hPt[:x]==hNeigh[:x]&&hPt[:y]==hNeigh[:y]}.empty?
      nCost=hCurrent[:cost]+A_etoile::distance(hCurrent,hNeigh)
      hNOpenSet=tOpenSet.select(hNeigh)        
      if hNOpenSet==nil
        hNeighNew=hNeigh.clone
        hNeighNew[:cost]=nCost
        hNeighNew[:heuristic]=nCost+A_etoile::distance(hNeighNew,hFinish)
        tOpenSet<< hNeighNew
        hFather[hNeighNew]=hCurrent
      elsif hNOpenSet[:cost]>nCost
        hNOpenSet[:cost]=nCost
        hNOpenSet[:heuristic]=hNOpenSet[:cost]+A_etoile::distance(hNOpenSet,hFinish)
        hFather.reject!{|hKey|hKey[:x]==hNOpenSet[:x]&&hKey[:y]==hNOpenSet[:y]}
        hFather[hNOpenSet]=hCurrent
      end
    end
  end
end
