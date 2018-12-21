# coding: utf-8
require 'gtk3'
require './A_etoile_mod'
include A_etoile

HEIGHT=500
WIDTH=(HEIGHT*30.0)/27.0

class Board < Gtk::DrawingArea
  def initialize
    super
    @m_bInitError = false
    @m_sMessError = ""
    @m_nRadius=0
    @m_nScaleHeight=0
    @m_nScaleWidth=0
    @m_tFinalPath=[]
    @m_tHist=[]
    @m_bFinish=false
    @m_hSpaceShip={}
    @m_hLandPoint={}
    @m_tSurface=[]
    @m_hVectBord={}
    @m_tSurfaceFmt=[]
    @m_hSpaceShipFmt={}
    @m_hLandPointFmt={}
    @m_hVectBordFmt={}
    @m_tBordFmt=[]
    @m_tObstacleFmt=[]
    @m_tGraph=[]
    @m_hStart={}
    @m_hFinish={}
    @m_tOpenSet=A_etoile::NaivePriorityQueue.new
    @m_tClosedSet=[]
    @m_hFather={}
    override_background_color :normal, Gdk::RGBA.new(0, 0, 0, 1)
    signal_connect "draw" do
      on_draw
    end
  end

  def on_timer
    queue_draw
    return true
  end

  def init hSpaceShip, hLandPoint, tSurface, hVectBord, nCoefReduc
    @m_hSpaceShip = hSpaceShip
    @m_hLandPoint = hLandPoint
    @m_tSurface = tSurface
    @m_hVectBord = hVectBord
    @m_nCoefReduc = nCoefReduc
    
    if (@m_hSpaceShip == {} ||
        @m_hLandPoint == {} ||
        @m_hVectBord == {})
      @m_sMessError = "Certaines données sont manquantes"
      @m_bInitError = true
    end
    
    if !@m_bInitError && (@m_hVectBord[:x] <= 0 || @m_hVectBord[:y] <= 0)
      @m_sMessError = "La hauteur et la largeur de la zone doivent être strictements positives"
      @m_bInitError = true
    end
    if !@m_bInitError && (@m_hSpaceShip[:x] <= 0 || @m_hSpaceShip[:y] <= 0 || @m_hSpaceShip[:x] >= @m_hVectBord[:x] || @m_hSpaceShip[:y] >= @m_hVectBord[:y])
      @m_sMessError = "Le point de départ doit se trouver à l'intérieur strict de la zone"
      @m_bInitError = true
    end
    if !@m_bInitError && (@m_hLandPoint[:x] <= 0 || @m_hLandPoint[:y] <= 0 || @m_hLandPoint[:x] >= @m_hVectBord[:x] || @m_hLandPoint[:y] >= @m_hVectBord[:y])
      @m_sMessError = "Le point d'arrivée doit se trouver à l'intérieur strict de la zone"
      @m_bInitError = true
    end
    if !@m_bInitError && belongSurface(@m_hSpaceShip, @m_tSurface)
      @m_sMessError = "Le point de départ ne doit pas se trouver sur un obstacle"
      @m_bInitError = true
    end
    if !@m_bInitError && belongSurface(@m_hLandPoint, @m_tSurface)
      @m_sMessError = "Le point d'arrivée ne doit pas se trouver sur un obstacle"
      @m_bInitError = true
    end
    
    if !@m_bInitError
      if @m_nCoefReduc != 1
        @m_hSpaceShip[:x] = (@m_hSpaceShip[:x]/@m_nCoefReduc).to_i
        @m_hSpaceShip[:y] = (@m_hSpaceShip[:y]/@m_nCoefReduc).to_i
        @m_hLandPoint[:x] = (@m_hLandPoint[:x]/@m_nCoefReduc).to_i
        @m_hLandPoint[:y] = (@m_hLandPoint[:y]/@m_nCoefReduc).to_i
        @m_hVectBord[:x] = (@m_hVectBord[:x]/@m_nCoefReduc).to_i
        @m_hVectBord[:y] = (@m_hVectBord[:y]/@m_nCoefReduc).to_i
        @m_tSurface.each do |s|
          s[0][:x] = (s[0][:x]/@m_nCoefReduc).to_i
          s[0][:y] = (s[0][:y]/@m_nCoefReduc).to_i
          s[1][:x] = (s[1][:x]/@m_nCoefReduc).to_i
          s[1][:y] = (s[1][:y]/@m_nCoefReduc).to_i
        end
      end
      
      @m_nRadius=[[(WIDTH/@m_hVectBord[:x])/5, (HEIGHT/@m_hVectBord[:y])/5].min, 1].max
      @m_nScaleHeight=HEIGHT-(2*@m_nRadius)
      @m_nScaleWidth=WIDTH-(2*@m_nRadius)
      @m_tSurface.each do |s|
        @m_tSurfaceFmt << [{x:((s[0][:x]*@m_nScaleWidth)/@m_hVectBord[:x]).to_i,y:((s[0][:y]*@m_nScaleHeight)/@m_hVectBord[:y]).to_i}, {x:((s[1][:x]*@m_nScaleWidth)/@m_hVectBord[:x]).to_i,y:((s[1][:y]*@m_nScaleHeight)/@m_hVectBord[:y]).to_i}]
      end
      @m_hSpaceShipFmt={x:(@m_hSpaceShip[:x]*@m_nScaleWidth)/@m_hVectBord[:x],y:(@m_hSpaceShip[:y]*@m_nScaleHeight)/@m_hVectBord[:y]}
      @m_hLandPointFmt={x:(@m_hLandPoint[:x]*@m_nScaleWidth)/@m_hVectBord[:x],y:(@m_hLandPoint[:y]*@m_nScaleHeight)/@m_hVectBord[:y]}
      @m_hVectBordFmt[:x]=@m_nScaleWidth
      @m_hVectBordFmt[:y]=@m_nScaleHeight
      @m_tBordFmt=A_etoile::border(@m_hVectBordFmt)
      @m_tObstacleFmt = A_etoile::obstacle(@m_tSurfaceFmt)

      @m_tGraph=A_etoile::initGraph(@m_hVectBord,A_etoile::obstacle(@m_tSurface))
      @m_tGraph, @m_hStart, @m_hFinish=A_etoile::initStartAndFinish(@m_tGraph,@m_hSpaceShip,@m_hLandPoint)
      @m_tOpenSet << @m_hStart
      GLib::Timeout.add([1000/@m_hVectBord[:x], 1000/@m_hVectBord[:y], 1].max){on_timer}
    end
  end
  
  def on_draw
    cr = window.create_cairo_context
    if @m_bInitError
      w = allocation.width / 2
      h = allocation.height / 2
      
      cr.set_font_size 15
      te = cr.text_extents @m_sMessError
      
      cr.set_source_rgb 1.0, 1.0, 1.0
      
      cr.move_to w - te.width/2, h
      cr.show_text @m_sMessError
    elsif !@m_tOpenSet.empty? && !@m_bFinish
      hCurrent=@m_tOpenSet.pop

      @m_tHist.reject!{|hKey|hKey[:x]==hCurrent[:x]&&hKey[:y]==hCurrent[:y]}
      @m_tHist << hCurrent
      p "Current node : " + hCurrent.to_s

      cr.set_source_rgb 1.0, 1.0, 1.0
      cr.paint
      
      cr.set_source_rgb 1.0, 0.0, 0.0
      @m_tBordFmt.each do |pt|
        cr.arc @m_nRadius+pt[:x], @m_nRadius+pt[:y], @m_nRadius, 0, 2*Math::PI
        cr.fill
      end
      @m_tObstacleFmt.each do |pt|
        cr.arc @m_nRadius+pt[:x], @m_nRadius+pt[:y], @m_nRadius, 0, 2*Math::PI
        cr.fill
      end
      
      cr.set_source_rgb 0.0, 0.0, 1.0
      @m_tHist.each do |pt|
        cr.arc @m_nRadius+((pt[:x]*@m_nScaleWidth)/@m_hVectBord[:x]), @m_nRadius+((pt[:y]*@m_nScaleHeight)/@m_hVectBord[:y]), @m_nRadius, 0, 2*Math::PI
        cr.fill
      end

      cr.set_source_rgb 0.6, 0.2, 0.0
      cr.arc @m_nRadius+@m_hSpaceShipFmt[:x], @m_nRadius+@m_hSpaceShipFmt[:y], @m_nRadius*2, 0, 2*Math::PI
      cr.fill

      cr.set_source_rgb 1.0, 0.5, 0.31
      cr.arc @m_nRadius+@m_hLandPointFmt[:x], @m_nRadius+@m_hLandPointFmt[:y], @m_nRadius*2, 0, 2*Math::PI
      cr.fill
      
      if (hCurrent[:x]==@m_hFinish[:x])&&(hCurrent[:y]==@m_hFinish[:y])
        @m_tFinalPath=A_etoile::reconstructPath(@m_hFather, hCurrent)
        p "Final path : " + @m_tFinalPath.to_s
        @m_bFinish=true
      end
      @m_tClosedSet << hCurrent
      tNeigh=A_etoile::neighbors(hCurrent, @m_tGraph, @m_tSurface)
      tNeigh.each do |hNeigh|
        if @m_tClosedSet.select{|hPt|hPt[:x]==hNeigh[:x]&&hPt[:y]==hNeigh[:y]}.empty?
          nCost=hCurrent[:cost]+A_etoile::distance(hCurrent,hNeigh)
          hNOpenSet=@m_tOpenSet.select(hNeigh)        
          if hNOpenSet==nil
            hNeighNew=hNeigh.clone
            hNeighNew[:cost]=nCost
            hNeighNew[:heuristic]=nCost+(5*A_etoile::distance(hNeighNew,@m_hFinish))
            @m_tOpenSet << hNeighNew
            @m_hFather[hNeighNew]=hCurrent
          elsif hNOpenSet[:cost]>nCost
            hNOpenSet[:cost]=nCost
            hNOpenSet[:heuristic]=hNOpenSet[:cost]+(5*A_etoile::distance(hNOpenSet, @m_hFinish))
            @m_hFather.reject!{|hKey|hKey[:x]==hNOpenSet[:x]&&hKey[:y]==hNOpenSet[:y]}
            @m_hFather[hNOpenSet]=hCurrent
          end
        end
      end
    elsif @m_bFinish
      cr.set_source_rgb 1.0, 1.0, 1.0
      cr.paint
      
      cr.set_source_rgb 1.0, 0.0, 0.0
      @m_tBordFmt.each do |pt|
        cr.arc @m_nRadius+pt[:x], @m_nRadius+pt[:y], @m_nRadius, 0, 2*Math::PI
        cr.fill
      end
      @m_tObstacleFmt.each do |pt|
        cr.arc @m_nRadius+pt[:x], @m_nRadius+pt[:y], @m_nRadius, 0, 2*Math::PI
        cr.fill
      end
      
      cr.set_source_rgb 0.0, 0.0, 1.0
      @m_tHist.each do |pt|
        cr.arc @m_nRadius+((pt[:x]*@m_nScaleWidth)/@m_hVectBord[:x]), @m_nRadius+((pt[:y]*@m_nScaleHeight)/@m_hVectBord[:y]), @m_nRadius, 0, 2*Math::PI
        cr.fill
      end
      
      cr.set_source_rgb 0.6, 0.2, 0.0
      cr.arc @m_nRadius+@m_hSpaceShipFmt[:x], @m_nRadius+@m_hSpaceShipFmt[:y], @m_nRadius*2, 0, 2*Math::PI
      cr.fill

      cr.set_source_rgb 1.0, 0.5, 0.31
      cr.arc @m_nRadius+@m_hLandPointFmt[:x], @m_nRadius+@m_hLandPointFmt[:y], @m_nRadius*2, 0, 2*Math::PI
      cr.fill
      
      cr.set_source_rgb 0.0, 1.0, 0.0
      @m_tFinalPath.each do |pt|
        cr.arc @m_nRadius+((pt[:x]*@m_nScaleWidth)/@m_hVectBord[:x]), @m_nRadius+((pt[:y]*@m_nScaleHeight)/@m_hVectBord[:y]), @m_nRadius, 0, 2*Math::PI
        cr.fill
      end
    end
  end
end

class RubyApp < Gtk::Window
  def initialize
    super
    set_title "A* GUI"
    signal_connect "destroy" do
      Gtk.main_quit
    end
    set_default_size WIDTH, HEIGHT
    set_window_position :center
  end
  
  def add_board board
    add board
    show_all
  end
end

tSurface = []
#tSurface << [{x:2,y:3},{x:3,y:4}]
#tSurface << [{x:3,y:2},{x:4,y:3}]
#tSurface << [{x:4,y:3},{x:5,y:2}]
#tSurface << [{x:3,y:4},{x:2,y:5}]
#tSurface << [{x:2,y:2},{x:3,y:2}]
#tSurface << [{x:2,y:2},{x:2,y:3}]
#tSurface << [{x:9,y:0},{x:4,y:5}]
#tSurface << [{x:7,y:7},{x:7,y:9}]
#tSurface << [{x:2,y:5},{x:2,y:7}]
#tSurface << [{x:2,y:7},{x:3,y:7}]
#tSurface << [{x:5,y:7},{x:5,y:6}]
#tSurface << [{x:3,y:7},{x:5,y:9}]
#hSpaceShip = {x:1,y:1}
#hLandPoint = {x:9,y:9}
#hVectBord = {x:10,y:10}

#hSpaceShip={x:65,y:26}
#hLandPoint={x:27,y:2}
#hVectBord={x:70,y:30}
#tSurface << [{x:0,y:4},{x:3,y:7}]
#tSurface << [{x:3,y:7},{x:10,y:4}]
#tSurface << [{x:10,y:4},{x:15,y:6}]
#tSurface << [{x:15,y:6},{x:18,y:8}]
#tSurface << [{x:18,y:8},{x:20,y:19}]
#tSurface << [{x:20,y:19},{x:22,y:18}]
#tSurface << [{x:22,y:18},{x:24,y:20}]
#tSurface << [{x:24,y:20},{x:31,y:18}]
#tSurface << [{x:31,y:18},{x:31,y:15}]
#tSurface << [{x:31,y:15},{x:25,y:16}]
#tSurface << [{x:25,y:16},{x:22,y:15}]
#tSurface << [{x:22,y:15},{x:21,y:7}]
#tSurface << [{x:21,y:7},{x:22,y:1}]
#tSurface << [{x:22,y:1},{x:32,y:1}]
#tSurface << [{x:32,y:1},{x:35,y:4}]
#tSurface << [{x:35,y:4},{x:40,y:9}]
#tSurface << [{x:40,y:9},{x:45,y:14}]
#tSurface << [{x:45,y:14},{x:50,y:15}]
#tSurface << [{x:50,y:15},{x:55,y:15}]
#tSurface << [{x:55,y:15},{x:60,y:9}]
#tSurface << [{x:60,y:9},{x:69,y:17}]

hSpaceShip={x:6500,y:2600}
hLandPoint={x:2700,y:151}
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

board = Board.new
board.init(hSpaceShip, hLandPoint, tSurface, hVectBord, 3)
window = RubyApp.new
window.add_board board
Gtk.main
