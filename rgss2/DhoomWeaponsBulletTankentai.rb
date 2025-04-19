#===============================================================================
#-------------------=• Weapon's Bullet for Tankentai •=-------------------------
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
            if @active_battler.weapon_id == 0
          action = @active_battler.non_weapon
          immortaling
        else 
          action = $data_weapons[@active_battler.weapon_id].base_action
          if $data_weapons[@active_battler.weapon_id].state_set.include?(1)
            for member in $game_party.members + $game_troop.members
              next if member.immortal
              next if member.dead?
            member.dying = true
            end
          else
            immortaling
          end
        end
        ammo_atk_minus
            @include_ammo = false
         else
            @help_window.set_text(TEXT, 1)
        @help_window.visible = true
        @active_battler.active = false
        wait(45)
        @help_window.visible = false
        immortaling
        return
         end
      else
         if @active_battler.weapon == 0
        action = @active_battler.base_action
        immortaling
      else
        action = $data_weapons[@active_battler.weapon].base_action
        if $data_weapons[@active_battler.weapon].state_set.include?(1)
          for member in $game_party.members + $game_troop.members
            next if member.immortal
            next if member.dead?
            member.dying = true
          end
        else
          immortaling
        end
      end 
    end
    target_decision
    @spriteset.set_action(@active_battler.actor?, @active_battler.index, action)
    playing_action
   end
   
   def execute_action_skill
      if @active_battler.actor?
         if SKILL_NEED_AMMO.include?(@active_battler.action.skill.id)      
        check_ammo
        if @include_ammo
          ammo_atk_plus
          skill = @active_battler.action.skill
          return unless @active_battler.action.valid?
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
          ammo_atk_minus
          @include_ammo = false
        else
          @help_window.set_text(TEXT, 1)
          @help_window.visible = true
          @active_battler.active = false
          wait(45)
          @help_window.visible = false
          immortaling
          return
        end
         else       
            skill = @active_battler.action.skill
        return unless @active_battler.action.valid?
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
         skill = @active_battler.action.skill
      return unless @active_battler.action.valid?
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
   end
end

#===============================================================================
# End
#===============================================================================
