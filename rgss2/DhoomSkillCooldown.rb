#===============================================================================
#--------------------------=• Skill Cooldown •=---------------------------------
#---------------------------=• by: DrDhoom •=-----------------------------------
# Version: 1.2
# Date Published: 05 - 04 - 2011
# Battle Addon
# RPGMakerID Community
#-------------------------------------------------------------------------------
# Introduction:
# This script make a skill have cooldown.
#-------------------------------------------------------------------------------
# Compatibility:
# - Tankentai Sideview Battle System
# - Wij's Battle Macros
# Note: not tested in other battle system
#-------------------------------------------------------------------------------
# How to use:
#  - Insert this script above Main
#  - Insert under all Battle System Core Script
#===============================================================================

module Dhoom
  module SkillCooldown
 
    SHOW_COOLDOWN_NUMBER = true #true = cooldown number of skill show
                                #      at the end of skill name
 
    COOLDOWN_COLOR = []  #<----Don't delete this line
 
    #RGB Color
    COOLDOWN_COLOR[1] = 255  #Red
    COOLDOWN_COLOR[2] = 0    #Green
    COOLDOWN_COLOR[3] = 0    #Blue
    COOLDOWN_COLOR[4] = 128  #Alpha
 
    SKILL_CD = []        #<----Don't delete this line
 
    #SKILL_CD[skill id] = number of cooldown (1 is minimum number)
    SKILL_CD[1] = 1
    SKILL_CD[2] = 9
   
    DONT_RESET_COOLDOWN_SWITCH = 1
  end
end

#===============================================================================
# Start
#===============================================================================
$imported = {} if $imported == nil
$imported["DSkillCooldown"] = true
#-------------------------------------------------------------------------------
# Window Base
#-------------------------------------------------------------------------------

class Window_Base
 
  def draw_skill_cooldown_name(item, x, y, enabled = true)
    if item != nil
      if @actor.skill_cooldown(item.id) != nil
        if @actor.skill_cooldown(item.id)!= 0
          cd_color = Color.new(Dhoom::SkillCooldown::COOLDOWN_COLOR[1],
          Dhoom::SkillCooldown::COOLDOWN_COLOR[2],
          Dhoom::SkillCooldown::COOLDOWN_COLOR[3],
          Dhoom::SkillCooldown::COOLDOWN_COLOR[4])
          draw_icon(item.icon_index, x, y, enabled)
          self.contents.font.color = cd_color
          if Dhoom::SkillCooldown::SHOW_COOLDOWN_NUMBER
            self.contents.draw_text(x + 24, y, 172, WLH, item.name + '(' +@actor.skill_cooldown(item.id).to_s + ')')
          else
            self.contents.draw_text(x + 24, y, 172, WLH, item.name)
          end
        else
          draw_icon(item.icon_index, x, y, enabled)
          self.contents.font.color = normal_color
          self.contents.font.color.alpha = enabled ? 255 : 128
          self.contents.draw_text(x + 24, y, 172, WLH, item.name)
        end
      else
        draw_icon(item.icon_index, x, y, enabled)
        self.contents.font.color = normal_color
        self.contents.font.color.alpha = enabled ? 255 : 128
        self.contents.draw_text(x + 24, y, 172, WLH, item.name)
      end
    end
  end
end

#-------------------------------------------------------------------------------
# Window Skill
#-------------------------------------------------------------------------------

class Window_Skill < Window_Selectable
 
  def draw_item(index)
    rect = item_rect(index)
    self.contents.clear_rect(rect)
    skill = @data[index]
    if skill != nil
      rect.width -= 4
      enabled = @actor.skill_can_use?(skill)
      draw_skill_cooldown_name(skill, rect.x, rect.y, enabled)
      self.contents.draw_text(rect, @actor.calc_mp_cost(skill), 2)
    end
  end
end

#-------------------------------------------------------------------------------
# Game Actor
#-------------------------------------------------------------------------------

class Game_Battler
 
  alias dsc_battler_init initialize
  alias dsc_skill_can_use? skill_can_use?
 
  def initialize
    dsc_battler_init
    @skill_cooldown = []
  end
 
  def make_cooldown_value(id)
    @skill_cooldown[id] = Dhoom::SkillCooldown::SKILL_CD[id]
    if $imported == nil
      @skill_cooldown[id] += 1
    elsif $imported["TankentaiATB"]
      @skill_cooldown[id] -= 0
    elsif $imported["TankentaiSideview"]
      @skill_cooldown[id] += 1
    else
      @skill_cooldown[id] += 1
    end
  end
 
  def skill_cooldown(id)
    return @skill_cooldown[id]
  end
 
  def decrease_cooldown(id)
    @skill_cooldown[id] -= 1
  end
 
  def skill_can_use?(skill)
    if skill_cooldown(skill.id) != nil
      return false if skill_cooldown(skill.id) != 0
    end
    dsc_skill_can_use?(skill)
  end
 
  def reset_cooldown
    @skill_cooldown = []
  end
end

#-------------------------------------------------------------------------------
# Scene Battle
#-------------------------------------------------------------------------------

class Scene_Battle < Scene_Base
 
  alias dsc_execute_action_skill execute_action_skill
  alias dsc_start_actor_command_selection start_actor_command_selection
  alias dsc_battle_end battle_end
 
  def execute_action_skill
    dsc_execute_action_skill
    skill = @active_battler.action.skill
    if Dhoom::SkillCooldown::SKILL_CD[skill.id] != nil
      @active_battler.make_cooldown_value(skill.id)
    end
  end
 
  def start_actor_command_selection
    dsc_start_actor_command_selection
    if @active_battler != nil and @active_battler.actor?   
      for skill in @active_battler.skills
        if @active_battler.skill_cooldown(skill.id) != nil
          if @active_battler.skill_cooldown(skill.id) != 0
            @active_battler.decrease_cooldown(skill.id)
          end
        end
      end
    elsif @commander !=nil
      for skill in @commander.skills
        if @commander.skill_cooldown(skill.id) != nil
          if @commander.skill_cooldown(skill.id) != 0
            @commander.decrease_cooldown(skill.id)
          end
        end
      end
    end
  end
 
  def battle_end(result)
    if !$game_switches[Dhoom::SkillCooldown::DONT_RESET_COOLDOWN_SWITCH]
      for actor in $game_party.members
        actor.reset_cooldown
      end
      for enemy in $game_troop.members
        enemy.reset_cooldown
      end
    end
    dsc_battle_end(result)
  end
end

#===============================================================================
# End
#===============================================================================
