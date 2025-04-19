#===============================================================================
#--------------------------=• Hunting Level •=----------------------------
#---------------------------=• by: DrDhoom •=-----------------------------------
# Version: 1.0
# Date Published: 17 - 05 - 2011
# RPGMakerID Community
#-------------------------------------------------------------------------------
# Introduction:
# Make hunting level by defeat enemy. Can be used in event by variables.
#-------------------------------------------------------------------------------
# How to use:
#  - Insert this script above Main 
#===============================================================================

module Dhoom
  module HEXP
   
    VAR_HEXP = 1 #Variable for Hunt EXP
    VAR_HLEVEL = 2 #Variable for Hunt Level
   
    BASE_EXP = 1 #Base monster hunt EXP
    START_LEVEL = 1 #Starting hunting level
    MONS_EXP = [] #Don't delete
   
    MONS_EXP[1] = 13 #MONS_EXP[enemy id] = hunt exp
   
    EXP_REQ = 25 #Hunt exp requirment for level up. EXP REQ * hunt Level
   
  end
end

module RPG
  class Enemy
   
    include Dhoom::HEXP
   
    def create_hexp
      if !MONS_EXP[@id].nil?
        @hunt_exp = MONS_EXP[@id]
      else
        @hunt_exp = BASE_EXP
      end
    end
   
    def hunt_exp
      if @hunt_exp == nil
        create_hexp
      end
      return @hunt_exp
    end
  end
end

class Game_Enemy < Game_Battler
 
  def hunt_exp
    return enemy.hunt_exp
  end
end


class Game_Party < Game_Unit
 
  include Dhoom::HEXP
 
  attr_accessor :hunt_exp
  attr_accessor :hunt_level
 
  alias dhoom_hexp_party_ini initialize
 
  def initialize
    super
    dhoom_hexp_party_ini
    @hunt_exp = 0
    @hunt_level = START_LEVEL
  end
 
  def check_hlevel_up
    if EXP_REQ * @hunt_level < @hunt_exp
      @hunt_exp -= @hunt_level *EXP_REQ
      @hunt_level += 1
    end
  end
end

class Game_Troop < Game_Unit
 
  def hunt_exp_total
    hunt_exp = 0
    for enemy in dead_members
      hunt_exp += enemy.hunt_exp unless enemy.hidden
    end
    return hunt_exp
  end
end

class Scene_Title < Scene_Base
  include Dhoom::HEXP
  alias dhoom_hexp_title_main main
 
  def main
    dhoom_hexp_title_main
    $game_variables[VAR_HEXP] = $game_party.hunt_exp
    $game_variables[VAR_HLEVEL] = $game_party.hunt_level
  end
end


class Scene_Battle < Scene_Base
 
  include Dhoom::HEXP 
  alias dhoom_hexp_disp_lev display_level_up
 
  def display_level_up
    dhoom_hexp_disp_lev
    $game_party.hunt_exp += $game_troop.hunt_exp_total
    $game_party.check_hlevel_up
    $game_variables[VAR_HEXP] = $game_party.hunt_exp
    $game_variables[VAR_HLEVEL] = $game_party.hunt_level
  end
end
