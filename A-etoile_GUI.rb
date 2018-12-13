# coding: utf-8
require 'gtk3'
require './A-etoile'
include A_etoile

HEIGHT=500
WIDTH=HEIGHT*(30.0/27.0)
DELAY_LOOP=1*1000
RADIUS=5
DELAY_REDRAW=0.1
HEIGHT_0=HEIGHT-(2*RADIUS)
WIDTH_0=WIDTH-(2*RADIUS)

class Board < Gtk::DrawingArea
  def initialize
    super
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
    override_background_color :normal, Gdk::RGBA.new(0, 0, 0, 1)
    signal_connect "draw" do
      on_draw
    end
    GLib::Timeout.add(DELAY_LOOP){loop}
  end

  def init hSpaceShip,hLandPoint,tSurface,hVectBord
    if (hSpaceShip != {} &&
        hLandPoint != {} &&
        tSurface != [] &&
        hVectBord != {})
      @m_hSpaceShip=hSpaceShip
      @m_hLandPoint=hLandPoint
      @m_tSurface=tSurface
      @m_hVectBord=hVectBord

      @m_tSurface.each do |pt|
        @m_tSurfaceFmt << {x:((pt[:x]*WIDTH_0)/@m_hVectBord[:x]).to_i,y:((pt[:y]*HEIGHT_0)/@m_hVectBord[:y]).to_i}
      end
      @m_hSpaceShipFmt={x:(@m_hSpaceShip[:x]*WIDTH_0)/@m_hVectBord[:x],y:(@m_hSpaceShip[:y]*HEIGHT_0)/@m_hVectBord[:y]}
      @m_hLandPointFmt={x:(@m_hLandPoint[:x]*WIDTH_0)/@m_hVectBord[:x],y:(@m_hLandPoint[:y]*HEIGHT_0)/@m_hVectBord[:y]}
      @m_hVectBordFmt[:x]=WIDTH_0
      @m_hVectBordFmt[:y]=HEIGHT_0
      @m_tBordFmt=A_etoile::border(@m_hVectBordFmt)
      @m_tObstacleFmt = A_etoile::obstacle(@m_tSurfaceFmt)
    end
  end
  
  def loop
    if start_or_continue
      tGraph=A_etoile::initGraph(@m_hVectBord,A_etoile::obstacle(@m_tSurface))
      tGraph,hStart,hFinish=A_etoile::initStartAndFinish(tGraph,@m_hSpaceShip,@m_hLandPoint)
      tOpenSet=A_etoile::NaivePriorityQueue.new
      tClosedSet=[]
      hFather={}
      tOpenSet<< hStart
      while !(tOpenSet.empty?) do
        hCurrent=tOpenSet.pop

        @m_tHist.reject!{|hKey|hKey[:x]==hCurrent[:x]&&hKey[:y]==hCurrent[:y]}
        @m_tHist << hCurrent
        p "Current node : " + hCurrent.to_s
        queue_draw
        #sleep(DELAY_REDRAW)
        
        if (hCurrent[:x]==hFinish[:x])&&(hCurrent[:y]==hFinish[:y])
          @m_tFinalPath=A_etoile::reconstructPath(hFather, hCurrent)
          p "Final path : " + @m_tFinalPath.to_s
          @m_bFinish=true
          return
        end
        tClosedSet<< hCurrent
        tNeigh=A_etoile::neighbors(hCurrent)
        tNeigh.each do |hNeigh|
          if tClosedSet.select{|hPt|hPt[:x]==hNeigh[:x]&&hPt[:y]==hNeigh[:y]}.empty?
            hNGraph=tGraph.select{|hPt|hPt[:x]==hNeigh[:x]&&hPt[:y]==hNeigh[:y]}[0]
            if hNGraph == nil || (hNGraph != nil && hNGraph[:cost] != A_etoile::INF)
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
      end
    end
  end
  
  def start_or_continue
    return (@m_hSpaceShip != {} &&
            @m_hLandPoint != {} &&
            @m_tSurface != [] &&
            @m_hVectBord != {} &&
            @m_bFinish == false)
  end
  
  def on_draw
    cr = window.create_cairo_context
    cr.set_source_rgb 1.0, 1.0, 1.0
    cr.paint
    
    cr.set_source_rgb 1.0, 0.0, 0.0
    @m_tBordFmt.each do |pt|
      cr.arc RADIUS+pt[:x], RADIUS+pt[:y], RADIUS, 0, 2*Math::PI
      cr.fill
    end
    @m_tObstacleFmt.each do |pt|
      cr.arc RADIUS+pt[:x], RADIUS+pt[:y], RADIUS, 0, 2*Math::PI
      cr.fill
    end
    
    cr.set_source_rgb 0.0, 0.0, 1.0
    @m_tHist.each do |pt|
      cr.arc RADIUS+((pt[:x]*WIDTH_0)/@m_hVectBord[:x]), RADIUS+((pt[:y]*HEIGHT_0)/@m_hVectBord[:y]), RADIUS, 0, 2*Math::PI
      cr.fill
    end

    cr.set_source_rgb 0.6, 0.2, 0.0
    cr.arc RADIUS+@m_hSpaceShipFmt[:x], RADIUS+@m_hSpaceShipFmt[:y], RADIUS*2, 0, 2*Math::PI
    cr.fill

    cr.set_source_rgb 1.0, 0.5, 0.31
    cr.arc RADIUS+@m_hLandPointFmt[:x], RADIUS+@m_hLandPointFmt[:y], RADIUS*2, 0, 2*Math::PI
    cr.fill
    
    cr.set_source_rgb 0.0, 1.0, 0.0
    @m_tFinalPath.each do |pt|
      cr.arc RADIUS+((pt[:x]*WIDTH_0)/@m_hVectBord[:x]), RADIUS+((pt[:y]*HEIGHT_0)/@m_hVectBord[:y]), RADIUS, 0, 2*Math::PI
      cr.fill
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

tSurface=[{x:0,y:2},{x:2,y:2}]
tSurface+=[{x:2,y:2},{x:3,y:1}]
hSpaceShip={x:1,y:1}
hLandPoint={x:1,y:6}
hVectBord={x:9,y:9}
board = Board.new
board.init(hSpaceShip,hLandPoint,tSurface,hVectBord)
window = RubyApp.new
window.add_board board
Gtk.main
