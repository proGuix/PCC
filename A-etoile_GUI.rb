require 'gtk3'

HEIGHT=500
WIDTH=HEIGHT*(30.0/27.0)
DELAY_LOOP=1*1000
RADIUS=2
DELAY_REDRAW=0.1

class Board < Gtk::DrawingArea
  def initialize
    super
    @tHist=[]
    @bFinish=false
    @m_tSurfaceFmt=[]
    @m_hSpaceShipFmt={}
    @m_hLandPointFmt={}
    override_background_color :normal, Gdk::RGBA.new(0, 0, 0, 1)
    signal_connect "draw" do
      on_draw
    end
    GLib::Timeout.add(DELAY_LOOP){loop}
  end

  def init hSpaceShip,hLandPoint,tSurface,hVectBord
    if (hSpaceShip!={} &&
                    hLandPoint!={} &&
                                tSurface!=[] &&
                                          hVectBord!={}
       )
      @m_hSpaceShip=hSpaceShip
      @m_hLandPoint=hLandPoint
      @m_tSurface=tSurface
      @m_hVectBord=hVectBord

      @tSurface.each do |pt|
        @m_tSurfaceFmt<<{x:(pt[:x]*WIDTH)/@m_hVectBord[:x],y:(pt[:y]*HEIGHT)/@m_hVectBord[:y]}
      end
      @m_hSpaceShipFmt={x:(@m_hSpaceShip[:x]*WIDTH)/@m_hVectBord[:x],y:(@m_hSpaceShip[:y]*HEIGHT)/@m_hVectBord[:y]}
      @m_hLandPointFmt={x:(@m_hLandPoint[:x]*WIDTH)/@m_hVectBord[:x],y:(@m_hLandPoint[:y]*HEIGHT)/@m_hVectBord[:y]}
    end
  end
  
  def loop
    if start_or_continue
      tOpenSet<< hStart
      while !(tOpenSet.empty?) do
        hCurrent=tOpenSet.pop

        @tHist.reject!{|hKey|hKey[:x]==hCurrent[:x]&&hKey[:y]==hCurrent[:y]}
        @tHist<< hCurrent
        queue_draw
        sleep(DELAY_REDRAW)
        
        if (hCurrent[:x]==hFinish[:x])&&(hCurrent[:y]==hFinish[:y])
          p reconstructPath(hFather, hCurrent)
          @bFinish=true
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
    end
  end

  def start_or_continue
    return (@m_hSpaceShip!={} &&
            @m_hLandPoint!={} &&
            @m_tSurface!=[] &&
            @m_hVectBord!={} &&
            @bFinish==false)
  end
    
  def on_draw
    if start_or_continue
      cr = window.create_cairo_context
      cr.set_source_rgb 1.0, 1.0, 1.0
      cr.paint
      
      cr.set_source_rgb 1.0, 0.0, 0.0
      cr.arc 0, 0, RADIUS, 0, 2*Math::PI
      cr.fill

      draw_surface cr
    end
  end

  def draw_surface cr
    @m_tSurfaceFmt.each_cons(2) do |pt1, pt2|
      cr.move_to pt1[:x],pt1[:y]
      cr.line_to pt2[:x],pt2[:y]
      cr.stroke
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

board = Board.new
board.init({},{},[],{})
window = RubyApp.new
window.add_board board
Gtk.main
