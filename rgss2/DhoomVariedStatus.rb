#===============================================================================
#--------------------------=• Varied Status •=----------------------------
#---------------------------=• by: DrDhoom •=-----------------------------------
# Version: 1.0
# Date Published: 17 - 05 - 2011
# Battle Add-on
# RPGMakerID Community
#-------------------------------------------------------------------------------
# Introduction:
# Varieting enemy status by random number.
#-------------------------------------------------------------------------------
# How to use:
#  - Insert this script above Main 
#===============================================================================

module Dhoom
  module VARIED
   
    BASE_VARIED = 20 #Base random number for all enemy, except ENEMY_VARIED
   
    ENEMY_VARIED = [] #<-- Don't delete.
    ENEMY_VARIED[1] = 20 #ENEMY_VARIED[enemy id] = number
   
  end
end

class Game_Battler
  include Dhoom::VARIED
  def make_varied_status(id)
    if ENEMY_VARIED[id] != nil
      varied = rand(ENEMY_VARIED[id])
    else
      varied = rand(BASE_VARIED)
    end
    @maxhp_plus += (varied * 10)
    @maxmp_plus += (varied * 5)
    @atk_plus += varied
    @def_plus += varied
    @spi_plus += varied
    @agi_plus += varied
  end
end

class Game_Enemy
  def varied_status
    make_varied_status(@enemy_id)
    @hp = maxhp
    @mp = maxmp
  end
end

class Game_Troop
  alias dhoom_varied_make_names make_unique_names
  def make_unique_names
    dhoom_varied_make_names
    for enemy in members
      enemy.varied_status
    end
  end
end
