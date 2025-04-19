#===============================================================================
#---------------------=• Basic Attack Common Event •=---------------------------
#---------------------------=• by: DrDhoom •=-----------------------------------
# Version: 1.0 (For Atoa CBS)
# Date Published: 19 - 05 - 2011
# RPGMakerID Community
#-------------------------------------------------------------------------------
# Introduction:
# Execute commont event when using basic attack
#-------------------------------------------------------------------------------
# How to use:
#  - Insert this script above Main
#===============================================================================
module Dhoom
  module CEW
    COMMON_WEAPON = [] #<--- Don't Delete this line
    #COMMON_WEAPON[Weapon ID] = Common Event ID
    COMMON_WEAPON[1] = 4
    COMMON_WEAPON[2] = 1
    COMMON_WEAPON[3] = 2
 
    ENEMY = []
    #ENEMY[enemy id] = common event id
    ENEMY[1] = 1
 
    #ENE_ACTIVE = [enemy id]
    ENE_ACTIVE = [1]
 
    #ACTIVE = [weapon id]
    ACTIVE = [1,2]
  end
end

class Game_Enemy
  def enemy?
    return true
  end
end

class Game_Actor
  def enemy?
    return false
  end
end

class Scene_Battle
  alias dhoom_basic_action make_basic_action_result
  def make_basic_action_result(battler)
    dhoom_basic_action(battler)
    if battler.current_action.basic == 0
      if Dhoom::CEW::COMMON_WEAPON[battler.weapon_id] != nil
        if Dhoom::CEW::ACTIVE.include?(battler.weapon_id)
          common_event = $data_common_events[Dhoom::CEW::COMMON_WEAPON[battler.weapon_id]]
          $game_system.battle_interpreter.setup(common_event.list, 0)
        else
          @common_event_id = Dhoom::CEW::COMMON_WEAPON[battler.weapon_id]
        end
      elsif battler.enemy? and Dhoom::CEW::ENEMY[battler.id] != nil
        if Dhoom::CEW::ENE_ACTIVE.include?(battler.id)
          common_event = $data_common_events[Dhoom::CEW::ENEMY[battler.id]]
          $game_system.battle_interpreter.setup(common_event.list, 0)
        else
          @common_event_id = Dhoom::CEW::ENEMY[battler.id]
        end
      end
    end
  end
end
