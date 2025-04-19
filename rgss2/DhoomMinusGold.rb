#===============================================================================
#----------------------------=• Minus Gold •=----------------------------
#---------------------------=• by: DrDhoom •=-----------------------------------
# Version: 1.0
# Date Published: 17 - 05 - 2011
# RPGMakerID Community
#-------------------------------------------------------------------------------
# Introduction:
# Allowing to have minus gold.
#-------------------------------------------------------------------------------
# How to use:
#  - Insert this script above Main 
#===============================================================================


COLOR = Color.new(255,0,0)

class Game_Party < Game_Unit
  def gain_gold(n)
    @gold = [[@gold + n, -9999999].max, 9999999].min
  end
end

class Window_Base < Window
  def draw_currency_value(value, x, y, width)
    cx = contents.text_size(Vocab::gold).width   
    if value < 0
      self.contents.font.color = COLOR
      self.contents.draw_text(x, y, width-cx-2, WLH, value, 2)
    else
      self.contents.font.color = normal_color
      self.contents.draw_text(x, y, width-cx-2, WLH, value, 2)
    end
    self.contents.font.color = system_color
    self.contents.draw_text(x, y, width, WLH, Vocab::gold, 2)
  end
end
