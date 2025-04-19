#===============================================================================
#---------------------------= Shortcut Scene =----------------------------------
#-----------------------------= by: DrDhoom =-----------------------------------
# Version: 1.1
# Date Published: 27 - 12 - 2011
#-------------------------------------------------------------------------------
# Introduction:
# With this script, you can make a Shortcut for calling scene.
#-------------------------------------------------------------------------------
# How to use:
#  - Insert this script above Main
#-------------------------------------------------------------------------------
#===============================================================================

module Dhoom
  module ShortcutScene
    #Shortcut = [[Button, Scene], [Button, Scene], ...]

    # Button = Input button, look at Game Properties>Keyboard(F1 when playing)
    #          for more keys. The format is "Input::Keys".
    # Scene = Scene class.
    # You can add as many shortcut as you want.
 
    Shortcut = [[Input::R, Scene_Item],[Input::L, Scene_Skill]]
  end
end

class Scene_Map
 
  include Dhoom::ShortcutScene
 
  alias dhoom_map_shortcut_update update
 
  def update
    dhoom_map_shortcut_update
    update_shortcut
  end
 
  def update_shortcut
    return if $game_system.map_interpreter.running?
    for key in Shortcut
      if Input.trigger?(key[0])
        $game_player.straighten
        $scene = key[1].new
        return
      end
    end
  end
end
