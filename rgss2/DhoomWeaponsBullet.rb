#===============================================================================
#--------------------------=• Weapon's Bullet •=---------------------------------
#---------------------------=• by: DrDhoom •=-----------------------------------
# Version: 1.2
# Date Published: 11 - 11 - 2011
# RPGMakerID Community
#-------------------------------------------------------------------------------
# Introduction:
# With this script, Player must have an ammo of specified weapon to use it.
#-------------------------------------------------------------------------------
# Compatibility:
# Note: not tested in other battle system
#-------------------------------------------------------------------------------
# How to use:
#  - Insert this script above Main
#-------------------------------------------------------------------------------
# Changelog:
# 09/11/2011 : •Starting
#              •v1.0 publish base script
#              •v1.1 added skill ammunition
# 11/11/2011 : •v1.2 added ammunition usage and damage
#===============================================================================

module Dhoom
   module Bullet
      TEXT = "Run out of ammo." #The text that appear if the ammo is run out
      
      #Don't do anything with this------------------------------------------------
      BULLET = []
      BULLET_PROP = []
      #---------------------------------------------------------------------------
      
      #BULLET[Weapon ID] = [Item ID]
      BULLET[4] = [22]
    BULLET[11] = [21,22,23]
      
      #Define the bullet damage and usage. If bullet not defined, it will use
      #default value
      
      #DEFAULT_PROP = [Usage, Damage]
      DEFAULT_PROP = [1, 0]
      
      #BULLET_PROP[Item ID] = [Usage, Damage]
      BULLET_PROP[21] = [4, 20]
    BULLET_PROP[23] = [2, 5]
      
      #SKILL_NEED_AMMO = [skill ID]
      SKILL_NEED_AMMO = [83,84]
   end
end

class Scene_Battle
 
   include Dhoom::Bullet
   
   def check_ammo
      if BULLET[@active_battler.weapon_id] != nil
         @item = nil
         for i in 0..BULLET[@active_battler.weapon_id].size-1
            if $game_party.items.include?($data_items[BULLET[@active_battler.weapon_id][i]])
               if BULLET_PROP[BULLET[@active_battler.weapon_id][i]] != nil
                  if $game_party.item_number($data_items[BULLET[@active_battler.weapon_id][i]]) >= BULLET_PROP[BULLET[@active_battler.weapon_id][i]][0]
                     @item = $data_items[BULLET[@active_battler.weapon_id][i]]
                     break
                  end
               elsif $game_party.item_number($data_items[BULLET[@active_battler.weapon_id][i]]) >= DEFAULT_PROP[0]
                  @item = $data_items[BULLET[@active_battler.weapon_id][i]]
                  break
               end
            end
         end
         if @item != nil
            if BULLET_PROP[@item.id] != nil
               $game_party.lose_item(@item, BULLET_PROP[@item.id][0])
          @include_ammo = true
            else
               $game_party.lose_item(@item, DEFAULT_PROP[0])
          @include_ammo = true
            end
         else
            @include_ammo = false
         end
      end
   end
 
  def ammo_atk_plus
    if @include_ammo
      if BULLET_PROP[@item.id] != nil
        @active_battler.atk += BULLET_PROP[@item.id][1]
      else
        @active_battler.atk += DEFAULT_PROP[1]
      end
    end   
  end
 
  def ammo_atk_minus
    if @include_ammo
      if BULLET_PROP[@item.id] != nil
        @active_battler.atk -= BULLET_PROP[@item.id][1]
      else
        @active_battler.atk -= DEFAULT_PROP[1]
      end
    end   
  end
   
   def execute_action_attack
      if @active_battler.actor?
         check_ammo
         if @include_ammo
        ammo_atk_plus
            text = sprintf(Vocab::DoAttack, @active_battler.name)
            @message_window.add_instant_text(text)
            targets = @active_battler.action.make_targets
            display_attack_animation(targets)
            wait(20)
            for target in targets
               target.attack_effect(@active_battler)
               display_action_effects(target)
            end
        ammo_atk_minus
            @include_ammo = false
         else
            @message_window.add_instant_text(TEXT)
            wait(40)
         end
      else
         text = sprintf(Vocab::DoAttack, @active_battler.name)
         @message_window.add_instant_text(text)
         targets = @active_battler.action.make_targets
         display_attack_animation(targets)
         wait(20)
         for target in targets
            target.attack_effect(@active_battler)
            display_action_effects(target)
         end
      end
   end
   
   def execute_action_skill
      if @active_battler.actor?
         if SKILL_NEED_AMMO.include?(@active_battler.action.skill.id)      
        check_ammo
        if @include_ammo
          ammo_atk_plus
          skill = @active_battler.action.skill
          text = @active_battler.name + skill.message1
          @message_window.add_instant_text(text)
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
          ammo_atk_minus
          @include_ammo = false
        else
          @message_window.add_instant_text(TEXT)
          wait(40)
        end
         else       
            skill = @active_battler.action.skill
            text = @active_battler.name + skill.message1
            @message_window.add_instant_text(text)
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
      else
         skill = @active_battler.action.skill
         text = @active_battler.name + skill.message1
         @message_window.add_instant_text(text)
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
