#===============================================================================
#----------------------------=• Colorfull •=------------------------------------
#---------------------------=• by: DrDhoom •=-----------------------------------
# Version: 1.0
# Date Published: 26 - 05 - 2011
# RPGMakerID Community
#-------------------------------------------------------------------------------
# Introduction:
# Change color of items, armors, weapons, actor name, and actor class.
#-------------------------------------------------------------------------------
# How to use:
#  - Insert this script above Main
#===============================================================================

module Dhoom
  module COL
    BASE_ACTOR_COL = Color.new(125,125,0)
    BASE_CLASS_COL = Color.new(50,50,0)
    BASE_SKILL_COL = Color.new(0,0,220)
    BASE_ITEM_COL = Color.new(0,230,0)
    BASE_ARMOR_COL = Color.new(0,150,150)
    BASE_WEAPON_COL = Color.new(255,225,0)
 
    ACTOR_COL = []
    ACTOR_COL[1] = Color.new(255,0,0)
 
    CLASS_COL = []
    CLASS_COL[1] = Color.new(0,255,0)
 
    SKILL_COL = []
    SKILL_COL[1] = Color.new(0,0,255)
 
    ITEM_COL = []
    ITEM_COL[1] = Color.new(0,125,125)
 
    ARMOR_COL = []
    ARMOR_COL[1] = Color.new(125,125,0)
 
    WEAPON_COL = []
    WEAPON_COL[1] = Color.new(0,255,255)
  end
end

class Window_Base < Window
  include Dhoom::COL
 
  def hp_color2(actor)
    return knockout_color if actor.hp == 0
    return crisis_color if actor.hp < actor.maxhp / 4
    return ACTOR_COL[actor.id] if ACTOR_COL[actor.id].is_a?(Color)
    return BASE_ACTOR_COL
  end
 
  def class_color(actor)
    return CLASS_COL[actor.id] if CLASS_COL[actor.id].is_a?(Color)
    return BASE_CLASS_COL
  end
 
  def xsx_color(item)
    if item.is_a?(RPG::Skill)
      return SKILL_COL[item.id] if SKILL_COL[item.id].is_a?(Color)
      return BASE_SKILL_COL
    elsif item.is_a?(RPG::Item)
      return ITEM_COL[item.id] if ITEM_COL[item.id].is_a?(Color)
      return BASE_ITEM_COL
    elsif item.is_a?(RPG::Armor)
      return ARMOR_COL[item.id] if ARMOR_COL[item.id].is_a?(Color)
      return BASE_ARMOR_COL
    elsif item.is_a?(RPG::Weapon)
      return WEAPON_COL[item.id] if WEAPON_COL[item.id].is_a?(Color)
      return BASE_WEAPON_COL
    end
  end
 
  def draw_actor_name(actor, x, y)
    self.contents.font.color = hp_color2(actor)
    self.contents.draw_text(x, y, 108, WLH, actor.name)
  end
 
  def draw_actor_class(actor, x, y)
    self.contents.font.color = class_color(actor)
    self.contents.draw_text(x, y, 108, WLH, actor.class.name)
  end
 
  def draw_item_name(item, x, y, enabled = true)
    if item != nil
      draw_icon(item.icon_index, x, y, enabled)
      self.contents.font.color = xsx_color(item)
      self.contents.font.color.alpha = enabled ? 255 : 128
      self.contents.draw_text(x + 24, y, 172, WLH, item.name)
    end
  end
end
