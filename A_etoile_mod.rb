module A_etoile
  INF=+1.0/0.0

  def distance(e1,e2)
    Math.sqrt((e1[:x]-e2[:x])**2+(e1[:y]-e2[:y])**2)
  end

  def neighbors(hCurrent, tGraph, tSurface)
    tNeigh=[]
    hNeigh1 = {x:hCurrent[:x],y:hCurrent[:y]+1}
    hNGraph1 = tGraph.select{|hPt|hPt[:x]==hNeigh1[:x]&&hPt[:y]==hNeigh1[:y]}[0]
    bN1 = (hNGraph1 == nil || (hNGraph1 != nil && hNGraph1[:cost] != A_etoile::INF))
    if bN1
      tNeigh << hNeigh1
    end
    hNeigh2 = {x:hCurrent[:x]+1,y:hCurrent[:y]}
    hNGraph2 = tGraph.select{|hPt|hPt[:x]==hNeigh2[:x]&&hPt[:y]==hNeigh2[:y]}[0]
    bN2 = (hNGraph2 == nil || (hNGraph2 != nil && hNGraph2[:cost] != A_etoile::INF))
    if bN2
      tNeigh << hNeigh2
    end
    if bN1 || bN2 || (!bN1 && !bN2 && !belongSameSegmentSurface(hNeigh1, hNeigh2, tSurface))
      hNeigh1_2 = {x:hCurrent[:x]+1,y:hCurrent[:y]+1}
      hNGraph1_2 = tGraph.select{|hPt|hPt[:x]==hNeigh1_2[:x]&&hPt[:y]==hNeigh1_2[:y]}[0]
      bN1_2 = (hNGraph1_2 == nil || (hNGraph1_2 != nil && hNGraph1_2[:cost] != A_etoile::INF))
      if bN1_2
        tNeigh << hNeigh1_2
      end
    end
    hNeigh3 = {x:hCurrent[:x],y:hCurrent[:y]-1}
    hNGraph3 = tGraph.select{|hPt|hPt[:x]==hNeigh3[:x]&&hPt[:y]==hNeigh3[:y]}[0]
    bN3 = (hNGraph3 == nil || (hNGraph3 != nil && hNGraph3[:cost] != A_etoile::INF))
    if bN3
      tNeigh << hNeigh3
    end
    if bN2 || bN3 || (!bN2 && !bN3 && !belongSameSegmentSurface(hNeigh2, hNeigh3, tSurface))
      hNeigh2_3 = {x:hCurrent[:x]+1,y:hCurrent[:y]-1}
      hNGraph2_3 = tGraph.select{|hPt|hPt[:x]==hNeigh2_3[:x]&&hPt[:y]==hNeigh2_3[:y]}[0]
      bN2_3 = (hNGraph2_3 == nil || (hNGraph2_3 != nil && hNGraph2_3[:cost] != A_etoile::INF))
      if bN2_3
        tNeigh << hNeigh2_3
      end
    end
    hNeigh4 = {x:hCurrent[:x]-1,y:hCurrent[:y]}
    hNGraph4 = tGraph.select{|hPt|hPt[:x]==hNeigh4[:x]&&hPt[:y]==hNeigh4[:y]}[0]
    bN4 = (hNGraph4 == nil || (hNGraph4 != nil && hNGraph4[:cost] != A_etoile::INF))
    if bN4
      tNeigh << hNeigh4
    end
    if bN3 || bN4 || (!bN3 && !bN4 && !belongSameSegmentSurface(hNeigh3, hNeigh4, tSurface))
      hNeigh3_4 = {x:hCurrent[:x]-1,y:hCurrent[:y]-1}
      hNGraph3_4 = tGraph.select{|hPt|hPt[:x]==hNeigh3_4[:x]&&hPt[:y]==hNeigh3_4[:y]}[0]
      bN3_4 = (hNGraph3_4 == nil || (hNGraph3_4 != nil && hNGraph3_4[:cost] != A_etoile::INF))
      if bN3_4
        tNeigh << hNeigh3_4
      end
    end
    if bN4 || bN1 || (!bN4 && !bN1 && !belongSameSegmentSurface(hNeigh4, hNeigh1, tSurface))
      hNeigh4_1 = {x:hCurrent[:x]-1,y:hCurrent[:y]+1}
      hNGraph4_1 = tGraph.select{|hPt|hPt[:x]==hNeigh4_1[:x]&&hPt[:y]==hNeigh4_1[:y]}[0]
      bN4_1 = (hNGraph4_1 == nil || (hNGraph4_1 != nil && hNGraph4_1[:cost] != A_etoile::INF))
      if bN4_1
        tNeigh << hNeigh4_1
      end
    end
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
      pt[:cost]=INF
      pt[:heuristic]=INF
    end
    tGraph+=tBord
    tGraph.uniq!
    tObstacleCpy=tObstacle.clone
    tObstacleCpy.each do |pt|
      hVertex=tGraph.select{|hPt|hPt[:x]==pt[:x]&&hPt[:y]==pt[:y]}[0]
      if hVertex!=nil
        hVertex[:cost]=INF
        hVertex[:heuristic]=INF
      else
        pt[:cost]=INF
        pt[:heuristic]=INF
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
    tSurface.each do |s|
      tObstacle += segment2Array(s[0], s[1])
    end
    return tObstacle
  end

  def belongSameSegment(hPoint1, hPoint2, tSegment)
    return !segment2Array(tSegment[0], tSegment[1]).select{|hPt|hPt[:x]==hPoint1[:x]&&hPt[:y]==hPoint1[:y]}.empty? &&
           !segment2Array(tSegment[0], tSegment[1]).select{|hPt|hPt[:x]==hPoint2[:x]&&hPt[:y]==hPoint2[:y]}.empty?
  end

  def belongSameSegmentSurface(hPoint1, hPoint2, tSurface)
    tSurface.each do |tSegment|
      if belongSameSegment(hPoint1, hPoint2, tSegment)
        return true
      end
    end
    return false
  end

  def belongSurface(hPoint, tSurface)
    tSurface.each do |tSegment|
      if !segment2Array(tSegment[0], tSegment[1]).select{|hPt|hPt[:x]==hPoint[:x]&&hPt[:y]==hPoint[:y]}.empty?
        return true
      end
    end
    return false
  end
end
