require 'gtk3'

HEIGHT=500
WIDTH=HEIGHT*(30.0/27.0)
DELAY=1000
RADIUS=2

class Board < Gtk::DrawingArea
  def initialize(hSpaceShip,hLandPoint,tSurface,hVectBord)
    @m_hSpaceShip=hSpaceShip
    @m_hLandPoint=hLandPoint
    @m_tSurface=tSurface
    @m_hVectBord=hVectBord
    super
    override_background_color :normal, Gdk::RGBA.new(0, 0, 0, 1)
    signal_connect "draw" do  
      on_draw
    end
    GLib::Timeout.add(DELAY) { on_timer }
  end

  def on_timer
    queue_draw
    return true
  end
  
  def on_draw
    cr = window.create_cairo_context
    cr.set_source_rgb 1.0, 1.0, 1.0
    cr.paint
    
    cr.set_source_rgb 1.0, 0.0, 0.0
    cr.arc 0, 0, RADIUS, 0, 2*Math::PI
    cr.fill

    draw_surface cr    
  end

  def draw_surface cr
    cr.move_to 10,10
    cr.line_to 30,30
    cr.stroke
  end
end

class RubyApp < Gtk::Window
  def initialize
    super
    set_title "animation boule rouge"
    signal_connect "destroy" do 
      Gtk.main_quit 
    end
    @board = Board.new({},{},[],{})
    add @board
    set_default_size WIDTH, HEIGHT
    set_window_position :center
    show_all
  end
end

window = RubyApp.new
Gtk.main
