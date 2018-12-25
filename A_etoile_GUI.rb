# coding: utf-8
require 'gtk3'
require './A_etoile_mod'
include A_etoile

HEIGHT=500
WIDTH=(HEIGHT*30.0)/27.0

class Board < Gtk::DrawingArea
  def initialize
    super
    @m_nDistMin = 0
    @m_sCornerRef = "LT"
    @m_nWeight = 0
    @m_nCoefReduc = 1
    @m_bInitError = false
    @m_sMessError = ""
    @m_nRadius = 0
    @m_nScaleHeight = 0
    @m_nScaleWidth = 0
    @m_tFinalPath = []
    @m_tHist = []
    @m_bFinish = false
    @m_hSpaceShip = {}
    @m_hLandPoint = {}
    @m_tSurface = []
    @m_tObstacle = []
    @m_hVectBord = {}
    @m_hSpaceShipFmt = {}
    @m_hLandPointFmt = {}
    @m_hCurrent = {}
    @m_tGraph = []
    @m_hStart = {}
    @m_hFinish = {}
    @m_tOpenSet = A_etoile::PriorityQueue.new
    @m_tClosedSet = []
    @m_hFather = {}
    override_background_color :normal, Gdk::RGBA.new(0, 0, 0, 1)
    signal_connect "draw" do
      on_draw
    end
  end

  def init hSpaceShip, hLandPoint, tSurface, hVectBord, nWeight, nCoefReduc, sCornerRef, nDistMin
    @m_hSpaceShip = hSpaceShip
    @m_hLandPoint = hLandPoint
    @m_tSurface = tSurface
    @m_hVectBord = hVectBord
    @m_nWeight = nWeight
    @m_nCoefReduc = nCoefReduc
    @m_sCornerRef = sCornerRef
    @m_nDistMin = nDistMin
    
    if (@m_hSpaceShip == {} ||
        @m_hLandPoint == {} ||
        @m_hVectBord == {})
      @m_sMessError = "Certaines données sont manquantes"
      @m_bInitError = true
    end

    if !@m_bInitError && @m_nCoefReduc <= 0
      @m_sMessError = "Le coefficient de réduction doit être strictement positif"
      @m_bInitError = true
    end
    if !@m_bInitError && @m_nCoefReduc != 1
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
    if !@m_bInitError && @m_nCoefReduc == 1 && belongSurface(@m_hSpaceShip, @m_tSurface)
      @m_sMessError = "Le point de départ ne doit pas se trouver sur un obstacle"
      @m_bInitError = true
    end
    if !@m_bInitError && @m_nCoefReduc == 1 && belongSurface(@m_hLandPoint, @m_tSurface)
      @m_sMessError = "Le point d'arrivée ne doit pas se trouver sur un obstacle"
      @m_bInitError = true
    end
    if !@m_bInitError && !["LT", "LB"].include?(@m_sCornerRef)
      #LT (LEFT TOP), LB (LEFT BOTTOM)
      @m_sMessError = "Le coin de référence doit se situer en haut à gauche ou en bas à gauche"
      @m_bInitError = true
    end
    
    if !@m_bInitError      
      @m_nRadius=[[(WIDTH/@m_hVectBord[:x])/5, (HEIGHT/@m_hVectBord[:y])/5].min, 1].max
      @m_nScaleHeight=HEIGHT-(2*@m_nRadius)
      @m_nScaleWidth=WIDTH-(2*@m_nRadius)
      @m_hSpaceShipFmt = {x:(@m_hSpaceShip[:x]*@m_nScaleWidth)/@m_hVectBord[:x],y:(@m_hSpaceShip[:y]*@m_nScaleHeight)/@m_hVectBord[:y]}
      @m_hLandPointFmt = {x:(@m_hLandPoint[:x]*@m_nScaleWidth)/@m_hVectBord[:x],y:(@m_hLandPoint[:y]*@m_nScaleHeight)/@m_hVectBord[:y]}
      @m_tObstacle = A_etoile::obstacle(@m_tSurface)
      @m_tGraph = A_etoile::initGraph(@m_tObstacle)
      @m_tGraph, @m_hStart, @m_hFinish = A_etoile::initStartAndFinish(@m_tGraph, @m_hSpaceShip, @m_hLandPoint)
      @m_tOpenSet << @m_hStart
      GLib::Timeout.add([1000/@m_hVectBord[:x], 1000/@m_hVectBord[:y], 1].max){queue_draw}
    end
  end
  
  def on_draw
    cr = window.create_cairo_context
    if @m_bInitError
      draw_error_message cr
    elsif !@m_tOpenSet.empty? && !@m_bFinish
      @m_hCurrent=@m_tOpenSet.pop
      @m_tHist.reject!{|hKey|hKey[:x] == @m_hCurrent[:x] && hKey[:y] == @m_hCurrent[:y]}
      @m_tHist << @m_hCurrent
      p "Current node : " + @m_hCurrent.to_s
      draw_current_state cr
      treat_current_node
    else
      draw_final_state cr
    end
  end
  
  def draw_error_message cr
    w = allocation.width / 2
    h = allocation.height / 2    
    cr.set_font_size 15
    te = cr.text_extents @m_sMessError
    cr.set_source_rgb 1.0, 1.0, 1.0    
    cr.move_to w - te.width/2, h
    cr.show_text @m_sMessError
  end

  def treat_current_node
    if (@m_hCurrent[:x] == @m_hFinish[:x]) && (@m_hCurrent[:y] == @m_hFinish[:y])
      @m_tFinalPath = A_etoile::reconstructPath(@m_hFather, @m_hCurrent)
      p "Final path : " + @m_tFinalPath.to_s
      if @m_nCoefReduc != 1
        p "Final path inflated : " + A_etoile::InflatePath(@m_tFinalPath, @m_nCoefReduc).to_s
      end
      @m_bFinish = true
    end
    @m_tClosedSet << @m_hCurrent
    tNeigh = A_etoile::neighbors(@m_hCurrent, @m_tGraph, @m_tSurface)
    tNeigh.each do |hNeigh|
      if A_etoile::IsAllDistanceMin(@m_hVectBord, @m_tObstacle, @m_hStart, @m_hFinish, hNeigh, @m_nDistMin)
        if hNeigh[:x] > 0 && hNeigh[:x] < @m_hVectBord[:x] && hNeigh[:y] > 0 && hNeigh[:y] < @m_hVectBord[:y]
          if @m_tClosedSet.select{|hPt|hPt[:x] == hNeigh[:x] && hPt[:y] == hNeigh[:y]}.empty?
            nCost = @m_hCurrent[:cost] + A_etoile::distance(@m_hCurrent, hNeigh)
            hNOpenSet = @m_tOpenSet.select(hNeigh)        
            if hNOpenSet == nil
              hNeighNew = hNeigh.clone
              hNeighNew[:cost] = nCost
              hNeighNew[:heuristic] = nCost + (@m_nWeight * A_etoile::distance(hNeighNew, @m_hFinish))
              @m_tOpenSet << hNeighNew
              @m_hFather[hNeighNew] = @m_hCurrent
            elsif hNOpenSet[:cost] > nCost
              hNOpenSet[:cost] = nCost
              hNOpenSet[:heuristic] = hNOpenSet[:cost] + (@m_nWeight * A_etoile::distance(hNOpenSet, @m_hFinish))
              @m_hFather.reject!{|hKey|hKey[:x] == hNOpenSet[:x] && hKey[:y] == hNOpenSet[:y]}
              @m_hFather[hNOpenSet] = @m_hCurrent
            end
          end
        end
      end
    end
  end
  
  def draw_current_state cr
    cr.set_source_rgb 1.0, 1.0, 1.0
    cr.paint
    cr.set_source_rgb 1.0, 0.0, 0.0
    cr.set_line_cap 2
    cr.set_line_width 2*@m_nRadius
    cr.move_to @m_nRadius, @m_nRadius
    cr.line_to WIDTH-@m_nRadius, @m_nRadius
    cr.stroke
    cr.move_to WIDTH-@m_nRadius, @m_nRadius
    cr.line_to WIDTH-@m_nRadius, HEIGHT-@m_nRadius
    cr.stroke
    cr.move_to WIDTH-@m_nRadius, HEIGHT-@m_nRadius
    cr.line_to @m_nRadius, HEIGHT-@m_nRadius
    cr.stroke
    cr.move_to @m_nRadius, @m_nRadius
    cr.line_to @m_nRadius, HEIGHT-@m_nRadius
    cr.stroke
    @m_tSurface.each do |s|
      cr.set_line_cap 1
      cr.set_line_width 2*@m_nRadius
      cr.move_to @m_nRadius+((s[0][:x]*@m_nScaleWidth)/@m_hVectBord[:x]), A_etoile::PosYByCorner(@m_nRadius+((s[0][:y]*@m_nScaleHeight)/@m_hVectBord[:y]), @m_sCornerRef, HEIGHT)
      cr.line_to @m_nRadius+((s[1][:x]*@m_nScaleWidth)/@m_hVectBord[:x]), A_etoile::PosYByCorner(@m_nRadius+((s[1][:y]*@m_nScaleHeight)/@m_hVectBord[:y]), @m_sCornerRef, HEIGHT)
      cr.stroke
    end
    cr.set_source_rgb 0.0, 0.0, 1.0
    @m_tHist.each do |pt|
      cr.arc @m_nRadius+((pt[:x]*@m_nScaleWidth)/@m_hVectBord[:x]), A_etoile::PosYByCorner(@m_nRadius+((pt[:y]*@m_nScaleHeight)/@m_hVectBord[:y]), @m_sCornerRef, HEIGHT), @m_nRadius, 0, 2*Math::PI
      cr.fill
    end
    cr.set_source_rgb 0.6, 0.2, 0.0
    cr.arc @m_nRadius+@m_hSpaceShipFmt[:x], A_etoile::PosYByCorner(@m_nRadius+@m_hSpaceShipFmt[:y], @m_sCornerRef, HEIGHT), @m_nRadius*2, 0, 2*Math::PI
    cr.fill
    cr.set_source_rgb 1.0, 0.5, 0.31
    cr.arc @m_nRadius+@m_hLandPointFmt[:x], A_etoile::PosYByCorner(@m_nRadius+@m_hLandPointFmt[:y], @m_sCornerRef, HEIGHT), @m_nRadius*2, 0, 2*Math::PI
    cr.fill
  end

  def draw_final_state cr
    draw_current_state cr
    cr.set_source_rgb 0.0, 1.0, 0.0
    if @m_tFinalPath.length == 1
      cr.arc @m_nRadius+((@m_tFinalPath[0][:x]*@m_nScaleWidth)/@m_hVectBord[:x]), A_etoile::PosYByCorner(@m_nRadius+((@m_tFinalPath[0][:y]*@m_nScaleHeight)/@m_hVectBord[:y]), @m_sCornerRef, HEIGHT), @m_nRadius, 0, 2*Math::PI
      cr.fill
    elsif @m_tFinalPath.length > 1
      @m_tFinalPath.each_cons(2) do |pt1, pt2|
        cr.set_line_width 2*@m_nRadius
        cr.set_line_cap 1
        cr.move_to @m_nRadius+((pt1[:x]*@m_nScaleWidth)/@m_hVectBord[:x]), A_etoile::PosYByCorner(@m_nRadius+((pt1[:y]*@m_nScaleHeight)/@m_hVectBord[:y]), @m_sCornerRef, HEIGHT)
        cr.line_to @m_nRadius+((pt2[:x]*@m_nScaleWidth)/@m_hVectBord[:x]), A_etoile::PosYByCorner(@m_nRadius+((pt2[:y]*@m_nScaleHeight)/@m_hVectBord[:y]), @m_sCornerRef, HEIGHT)
        cr.stroke
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

#hSpaceShip={x:7,y:6}
#hLandPoint={x:2,y:2}
#hVectBord={x:10,y:10}
#tSurface << [{x:0,y:5},{x:10,y:5}]

#hSpaceShip={x:6500,y:2600}
#hLandPoint={x:2700,y:151}
#hVectBord={x:7000,y:3000}
#tSurface << [{x:0,y:450},{x:300,y:750}]
#tSurface << [{x:300,y:750},{x:1000,y:450}]
#tSurface << [{x:1000,y:450},{x:1500,y:650}]
#tSurface << [{x:1500,y:650},{x:1800,y:850}]
#tSurface << [{x:1800,y:850},{x:2000,y:1950}]
#tSurface << [{x:2000,y:1950},{x:2200,y:1850}]
#tSurface << [{x:2200,y:1850},{x:2400,y:2000}]
#tSurface << [{x:2400,y:2000},{x:3100,y:1800}]
#tSurface << [{x:3100,y:1800},{x:3150,y:1550}]
#tSurface << [{x:3150,y:1550},{x:2500,y:1600}]
#tSurface << [{x:2500,y:1600},{x:2200,y:1550}]
#tSurface << [{x:2200,y:1550},{x:2100,y:750}]
#tSurface << [{x:2100,y:750},{x:2200,y:150}]
#tSurface << [{x:2200,y:150},{x:3200,y:150}]
#tSurface << [{x:3200,y:150},{x:3500,y:450}]
#tSurface << [{x:3500,y:450},{x:4000,y:950}]
#tSurface << [{x:4000,y:950},{x:4500,y:1450}]
#tSurface << [{x:4500,y:1450},{x:5000,y:1550}]
#tSurface << [{x:5000,y:1550},{x:5500,y:1500}]
#tSurface << [{x:5500,y:1500},{x:6000,y:950}]
#tSurface << [{x:6000,y:950},{x:6999,y:1750}]

hSpaceShip={x:6500,y:2000}
hLandPoint={x:4200,y:300}
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

nWeight = 2
nCoefReduc = 200
sCornerRef = "LB"
nDistMin = 1

board = Board.new
board.init hSpaceShip, hLandPoint, tSurface, hVectBord, nWeight, nCoefReduc, sCornerRef, nDistMin
window = RubyApp.new
window.add_board board
Gtk.main
