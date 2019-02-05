#==============================================================================
#
# • Dhoom Khas Awesome Light Effects - Disable Switch addon v1.1
#   drd-workshop.blogspot.com
# -- Last Updated: 06.02.2019
# -- Requires: Khas Awesome Light Effects
#
#==============================================================================
$imported = {} if $imported.nil?
$imported["DhoomKALEDisableSwitch"] = true
#==============================================================================
# • CONFIGURATION
#==============================================================================
module Dhoom
  module KALE
#------------------------------------------------------------------------------
#   Switch ID for enabling and disabling the lighting.
#------------------------------------------------------------------------------
    SWITCH_DISABLE_LIGHT_EFFECTS = 10
  end
end

class Light_Surface
  attr_accessor :timer
  
  alias dhoom_kale_lighsurface_change_color change_color
  def change_color(time,r,g,b,a=nil)
    if $game_switches[Dhoom::KALE::SWITCH_DISABLE_LIGHT_EFFECTS]
      @timer = 0
      return
    end
    dhoom_kale_lighsurface_change_color(time,r,g,b,a)
  end
  
  alias dhoom_kale_lighsurface_change_alpha change_alpha
  def change_alpha(time,a)
    if $game_switches[Dhoom::KALE::SWITCH_DISABLE_LIGHT_EFFECTS]
      @timer = 0
      return
    end
    dhoom_kale_lighsurface_change_alpha(time,a)
  end
end


class Spriteset_Map
  include Dhoom::KALE
  def dispose_lights
    $game_map.effect_surface.timer = 0
    $game_map.lantern.dispose
    $game_map.light_sources.each { |source| source.dispose_light }
    unless $game_map.light_surface.nil?
      $game_map.light_surface.bitmap.dispose
      $game_map.light_surface.dispose
      $game_map.light_surface = nil
    end
  end
  
  alias dhoom_kale_sprsmap_update_lights update_lights
  def update_lights
    if $game_switches[SWITCH_DISABLE_LIGHT_EFFECTS]
      dispose_lights if $game_map.light_surface
      return
    elsif !$game_map.light_surface
      setup_lights
    end    
    dhoom_kale_sprsmap_update_lights
  end
  
  alias dhoom_kale_sprsmap_setup_lights setup_lights 
  def setup_lights   
    return if $game_switches[SWITCH_DISABLE_LIGHT_EFFECTS]
    dhoom_kale_sprsmap_setup_lights
  end
end