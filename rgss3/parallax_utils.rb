#==============================================================================
#
# • Dhoom Parallax Utils v1.1
# -- Last Updated: 29.12.2014
# -- Requires: None
#
#==============================================================================

module Dhoom
  module Parallax_Utils
    #HOW TO USE
    #The script will automatically search for any parallax graphics.
    #Put any of this after parallax filename
    # _overlay
    # _anim_(frame)
    # _overlay_anim_(frame)
    #You don't have to specify the total frame for animation, the script
    #will do it automatically.
    #example :
    # Parallax filename = parallax_example
    #   parallax_example_overlay
    #   parallax_example_anim_1, parallax_example_anim_2, parallax_example_anim_3
    #   parallax_example_overlay_anim_1
    
    #Put map ID here to disable any modified parallax properties
    IGNORE_MAP = [5]
    #Parallax animation speed
    ANIM_SPEED = 10
  end
end

class Game_Map
  attr_reader   :animated_parallax_name
  attr_reader   :animated_parallax_total_frame
  attr_reader   :overlay_parallax_name
  attr_reader   :overlay_animated_parallax_name
  attr_reader   :overlay_animated_parallax_total_frame

  alias dhoom_parutils_gmmap_setup setup
  def setup(map_id)
    dhoom_parutils_gmmap_setup(map_id)
    return if Dhoom::Parallax_Utils::IGNORE_MAP.include?(@map_id)
    setup_animated_parallax
    setup_overlay_parallax
    setup_overlay_animated_parallax
  end
  
  def setup_animated_parallax
    return unless any_animated_parallax?    
    @animated_parallax_name = "#{@parallax_name}_anim_"
    @animated_parallax_total_frame = get_frame(@animated_parallax_name)
  end
  
  def setup_overlay_parallax
    return unless any_overlay_parallax?
    @overlay_parallax_name = "#{parallax_name}_overlay"
  end
  
  def setup_overlay_animated_parallax
    return if !any_overlay_animated_parallax?
    @overlay_animated_parallax_name = "#{parallax_name}_overlay_anim_"
    @overlay_animated_parallax_total_frame = get_frame(@overlay_animated_parallax_name)
  end
  
  def get_frame(name)
    frame = 1
    while FileTest.exist?("Graphics/Parallaxes/#{name}#{frame}.png") do
      frame += 1
    end
    frame -= 1
    return frame
  end
  
  def any_animated_parallax?
    return FileTest.exist?("Graphics/Parallaxes/#{@parallax_name}_anim_1.png")
  end  
  
  def any_overlay_parallax?
    return FileTest.exist?("Graphics/Parallaxes/#{@parallax_name}_overlay.png")
  end
  
  def any_overlay_animated_parallax?
    return FileTest.exist?("Graphics/Parallaxes/#{@parallax_name}_overlay_anim_1.png")
  end
end

class Spriteset_Map
  alias dhoom_parutils_sprsmap_create_parallax create_parallax
  def create_parallax
    dhoom_parutils_sprsmap_create_parallax
    @animated_parallax = Plane.new(@viewport1)
    @animated_parallax.z = -100
    @overlay_parallax = Plane.new(@viewport3)
    @overlay_animated_parallax = Plane.new(@viewport3)
  end
  
  alias dhoom_parutils_sprsmap_update update
  def update
    dhoom_parutils_sprsmap_update
    return if Dhoom::Parallax_Utils::IGNORE_MAP.include?($game_map.map_id)
    update_animated_parallax
    update_overlay_parallax
    update_overlay_animated_parallax
  end
  
  alias dhoom_arutils_sprsmap_update_parallax update_parallax
  def update_parallax
    dhoom_arutils_sprsmap_update_parallax
    return if Dhoom::Parallax_Utils::IGNORE_MAP.include?($game_map.map_id)
    @parallax.ox = $game_map.display_x * 32
    @parallax.oy = $game_map.display_y * 32
  end
  
  def update_animated_parallax
    return unless $game_map.any_animated_parallax?
    if @animated_parallax_name != $game_map.animated_parallax_name
      @animated_parallax_name = $game_map.animated_parallax_name
      @animated_parallax_frame = 1
      @animated_parallax_wait = Dhoom::Parallax_Utils::ANIM_SPEED
      if @animated_parallax.bitmap != nil
        @animated_parallax.bitmap.dispose
        @animated_parallax.bitmap = nil        
      end
      if @animated_parallax_name != "" and $game_map.any_animated_parallax?
        update_animated_parallax_graphic
      end
      Graphics.frame_reset
    end
    return unless $game_map.animated_parallax_name
    if @animated_parallax_wait > 0
      @animated_parallax_wait -= 1
    else
      if @animated_parallax_frame < $game_map.animated_parallax_total_frame
        @animated_parallax_frame += 1
      else
        @animated_parallax_frame = 1
      end
      update_animated_parallax_graphic
      @animated_parallax_wait = Dhoom::Parallax_Utils::ANIM_SPEED
    end
    @animated_parallax.ox = $game_map.display_x * 32
    @animated_parallax.oy = $game_map.display_y * 32
  end
  
  def update_animated_parallax_graphic
    @animated_parallax.bitmap = Cache.parallax("#{@animated_parallax_name}#{@animated_parallax_frame}")
  end
  
  def update_overlay_parallax
    return unless $game_map.any_overlay_parallax?    
    if @overlay_parallax_name != $game_map.overlay_parallax_name
      @overlay_parallax_name = $game_map.overlay_parallax_name
      if @overlay_parallax.bitmap != nil
        @overlay_parallax.bitmap.dispose
        @overlay_parallax.bitmap = nil        
      end
      if @overlay_parallax_name != "" and $game_map.any_overlay_parallax?
        @overlay_parallax.bitmap = Cache.parallax(@overlay_parallax_name)
      end
      Graphics.frame_reset
    end
    @overlay_parallax.ox = $game_map.display_x * 32
    @overlay_parallax.oy = $game_map.display_y * 32
  end
  
  def update_overlay_animated_parallax
    return unless $game_map.any_overlay_animated_parallax?
    if @overlay_animated_parallax_name != $game_map.overlay_animated_parallax_name
      @overlay_animated_parallax_name = $game_map.overlay_animated_parallax_name
      @overlay_animated_parallax_frame = 1
      @overlay_animated_parallax_wait = Dhoom::Parallax_Utils::ANIM_SPEED
      if @overlay_animated_parallax.bitmap != nil
        @overlay_animated_parallax.bitmap.dispose
        @overlay_animated_parallax.bitmap = nil        
      end
      if @overlay_animated_parallax_name != "" and $game_map.any_overlay_animated_parallax?
        update_overlay_animated_parallax_graphic
      end
      Graphics.frame_reset
    end
    return unless $game_map.overlay_animated_parallax_name
    if @overlay_animated_parallax_wait > 0
      @overlay_animated_parallax_wait -= 1
    else
      if @overlay_animated_parallax_frame < $game_map.overlay_animated_parallax_total_frame
        @overlay_animated_parallax_frame += 1
      else
        @overlay_animated_parallax_frame = 1
      end
      update_overlay_animated_parallax_graphic
      @overlay_animated_parallax_wait = Dhoom::Parallax_Utils::ANIM_SPEED
    end
    @overlay_animated_parallax.ox = $game_map.display_x * 32
    @overlay_animated_parallax.oy = $game_map.display_y * 32
  end
  
  def update_overlay_animated_parallax_graphic
    @overlay_animated_parallax.bitmap = Cache.parallax("#{@overlay_animated_parallax_name}#{@overlay_animated_parallax_frame}")
  end
  
  alias dhoom_parutils_sprsmap_dispose_parallax dispose_parallax
  def dispose_parallax
    dhoom_parutils_sprsmap_dispose_parallax
    @animated_parallax.dispose unless @animated_parallax.nil?
    @overlay_parallax.dispose unless @overlay_parallax.nil?
    @overlay_animated_parallax.dispose unless @overlay_animated_parallax.nil?
  end
end
