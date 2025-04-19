#===============================================================================
#---------------------=•Common Event Before Skill •=---------------------------
#---------------------------=• by: DrDhoom •=-----------------------------------
# Version: 1.0
# Date Published: 18 - 05 - 2011
# RPGMakerID Community
#-------------------------------------------------------------------------------
# Introduction:
# Execute commont event before using skill
#-------------------------------------------------------------------------------
# How to use:
#  - Insert this script above Main
#===============================================================================
module Dhoom
  module CEBA
    COMMON_EVENT = [] #<--- Don't Delete this line
  #COMMON_EVENT[skill id] = common event id
    COMMON_EVENT[1] = 4
  end
end

class Scene_Battle
  alias dhoom_make_skill make_skill_action_result
  def make_skill_action_result
    dhoom_make_skill
    if Dhoom::CEBA::COMMON_EVENT[@skill.id] != nil
      common_event = $data_common_events[Dhoom::CEBA::COMMON_EVENT[@skill.id]]
      $game_system.battle_interpreter.setup(common_event.list, 0)
    end
  end
end
