#===============================================================================
#----------------------=• Easy Skill Combo Script •=----------------------------
#---------------------------=• by: DrDhoom •=-----------------------------------
# Version: 1.1
# Date Published: 07 - 04 - 2011
# Battle Addon
# RPGMakerID Community
#-------------------------------------------------------------------------------
# Changelog:
# V:1.1 - Make compatible with Tankentai SBS and Add combo chain.
#-------------------------------------------------------------------------------
# Introduction:
# Make a combo skill.
#-------------------------------------------------------------------------------
# Compatibility:
# - Tankentai Sideview Battle System
# Note: not tested in other battle system
#-------------------------------------------------------------------------------
# How to use:
#  - Insert this script above Main 
#===============================================================================

module Dhoom 
  module SkillCombo
   
    COMBO_TEXT = "COMBO!!!" #The shown text if combo skill triggered.
                            #Leave empty like "", if you don't want it appear.
   
    FIRST_SKILL = []  #<----Don't delete this line
    SECOND_SKILL = []  #<----Don't delete this line
    COMBO_SKILL = []  #<----Don't delete this line
   
    #FIRST/SECOND/COMBO_SKILL[combo id] = skill id
    FIRST_SKILL[1] = 1
    SECOND_SKILL[1] = 2
    COMBO_SKILL[1] = 3 #--
                      # | Combo Chain
    FIRST_SKILL[2] = 3 #--
    SECOND_SKILL[2] = 41
    COMBO_SKILL[2] = 6
   
  end
end

#===============================================================================
# Start
#===============================================================================

$imported = {} if $imported == nil
$imported["DSkillCombo"] = true

#-------------------------------------------------------------------------------
# Scene Battle
#-------------------------------------------------------------------------------

class Scene_Battle < Scene_Base
 
  alias dsco_execute_action_attack execute_action_attack
  alias dsco_execute_action_guard execute_action_guard
  alias dsco_execute_action_item execute_action_item
 
  if $imported["TankentaiATB"] == nil
   
    alias dsco_turn_end turn_end
   
    def turn_end
      dsco_turn_end
      @first_skill = []
    end
  end
 
  def execute_action_guard
    dsco_execute_action_guard
    @first_skill = []
  end
 
  def execute_action_item
    dsco_execute_action_item
    @first_skill = []
  end
 
  def execute_action_attack
    dsco_execute_action_attack
    @first_skill = []
  end
 
  if $imported["TankentaiSideview"]
   
    def pop_help(obj)
      return if obj.extension.include?("HELPHIDE")
      @help_window = Window_Help.new if @help_window == nil
      if obj.is_a?(RPG::Skill)
        if @combo
          @help_window.set_text(Dhoom::SkillCombo::COMBO_TEXT + ' ' + obj.name + '!', 1)
        else
          @help_window.set_text(obj.name, 1)
        end
      else
        @help_window.set_text(obj.name, 1)
      end
      @help_window.visible = true
    end
   
    def execute_action_skill
      if Dhoom::SkillCombo::FIRST_SKILL.include?(@active_battler.action.skill.id)
        i = Dhoom::SkillCombo::FIRST_SKILL.index(@active_battler.action.skill.id)
        @first_skill = []
        @first_skill[i] = Dhoom::SkillCombo::FIRST_SKILL[i]
        @combo = false
      elsif Dhoom::SkillCombo::SECOND_SKILL.include?(@active_battler.action.skill.id)
        i = Dhoom::SkillCombo::SECOND_SKILL.index(@active_battler.action.skill.id)
        if @first_skill != nil
          if Dhoom::SkillCombo::FIRST_SKILL[i] == @first_skill[i]
            @first_skill = []
            @active_battler.action.set_skill(Dhoom::SkillCombo::COMBO_SKILL[i])
            if Dhoom::SkillCombo::FIRST_SKILL.include?(@active_battler.action.skill.id)
              i = Dhoom::SkillCombo::FIRST_SKILL.index(@active_battler.action.skill.id)
              @first_skill[i] = Dhoom::SkillCombo::FIRST_SKILL[i]
            end
            @combo = true
          else
            @first_skill = []
            @first_skill[i] = Dhoom::SkillCombo::FIRST_SKILL[i]
            @combo = false
          end
        else
          @first_skill = []
          @first_skill[i] = Dhoom::SkillCombo::FIRST_SKILL[i]
          @combo = false
        end
      end
      skill = @active_battler.action.skill
      return unless @active_battler.action.valid? # 3.3d, Force action bug fix
      if skill.plus_state_set.include?(1)
        for member in $game_party.members + $game_troop.members
          next if member.immortal
          next if member.dead?
          member.dying = true
        end
      else
        immortaling
      end
      target_decision(skill)
      @spriteset.set_action(@active_battler.actor?, @active_battler.index, skill.base_action)
      pop_help(skill)
      playing_action
      @active_battler.mp -= @active_battler.calc_mp_cost(skill)
      @status_window.refresh
      $game_temp.common_event_id = skill.common_event_id
    end
   
  else
   
    def execute_action_skill
      if Dhoom::SkillCombo::FIRST_SKILL.include?(@active_battler.action.skill.id)
        i = Dhoom::SkillCombo::FIRST_SKILL.index(@active_battler.action.skill.id)
        @first_skill = []
        @first_skill[i] = Dhoom::SkillCombo::FIRST_SKILL[i]
        skill = @active_battler.action.skill
        text = @active_battler.name + skill.message1
        @message_window.add_instant_text(text)
      elsif Dhoom::SkillCombo::SECOND_SKILL.include?(@active_battler.action.skill.id)
        i = Dhoom::SkillCombo::SECOND_SKILL.index(@active_battler.action.skill.id)
        if @first_skill != nil
          if Dhoom::SkillCombo::FIRST_SKILL[i] == @first_skill[i]
            @first_skill = []
            @active_battler.action.set_skill(Dhoom::SkillCombo::COMBO_SKILL[i])
            if Dhoom::SkillCombo::FIRST_SKILL.include?(@active_battler.action.skill.id)
              i = Dhoom::SkillCombo::FIRST_SKILL.index(@active_battler.action.skill.id)
              @first_skill[i] = Dhoom::SkillCombo::FIRST_SKILL[i]
            end
            skill = @active_battler.action.skill
            text = Dhoom::SkillCombo::COMBO_TEXT + ' ' + skill.name + '!'
            text2 = @active_battler.name + skill.message1
            @message_window.add_instant_text(text)
            wait(10)
            @message_window.add_instant_text(text2)
          else
            @first_skill = []
            @first_skill[i] = Dhoom::SkillCombo::FIRST_SKILL[i]
            skill = @active_battler.action.skill
            text = @active_battler.name + skill.message1
            @message_window.add_instant_text(text)
          end
        else
          @first_skill = []
          @first_skill[i] = Dhoom::SkillCombo::FIRST_SKILL[i]
          skill = @active_battler.action.skill
          text = @active_battler.name + skill.message1
          @message_window.add_instant_text(text)
        end 
      end
      unless skill.message2.empty?
        wait(10)
        @message_window.add_instant_text(skill.message2)
      end
      targets = @active_battler.action.make_targets
      display_animation(targets, skill.animation_id)
      @active_battler.mp -= @active_battler.calc_mp_cost(skill)
      $game_temp.common_event_id = skill.common_event_id
      for target in targets
        target.skill_effect(@active_battler, skill)
        display_action_effects(target, skill)
      end
    end
  end
end

#===============================================================================
# End
#===============================================================================
