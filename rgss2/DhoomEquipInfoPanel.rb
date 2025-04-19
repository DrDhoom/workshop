#===============================================================================
#--------------------------= Equip Info Panel =---------------------------------
#-----------------------------= by: DrDhoom =-----------------------------------
# Version: 1.0
# Date Published: 06 - 09 - 2012
#-------------------------------------------------------------------------------
# Introduction:
# This script will added info window into Equip Scene. This window will show 
# atk, def, agi, spi, and attribute of weapons or armors.
#-------------------------------------------------------------------------------
# How to use:
#   - Insert this script above Main
#-------------------------------------------------------------------------------
#===============================================================================

module Dhoom
  module Equip_Info_Panel
    #Display weapon attribute? [Two Handed, Fast Attack, Dual Attack, Critical Bonus]
    Display_Info_Weapon = [true, true, true, true]
    #Display armor attribute? [Prevent Critical, Half MP Cost, Double EXP Gain, Auto HP Recover]
    Display_Info_Armor = [true, true, true, true]
    
    Vocab_Info_Weapon = ["Two Handed", "Fast Attack", "Dual Attack", "Critical Bonus"]
    Vocab_Info_Armor = ["Prevent Critical", "Half MP Cost", "2x EXP", "Regeneration"]
  end
end

$dhoom_script = {} if $dhoom_script.nil?
$dhoom_script["EquipInfoPanel"] = true

class Window_Base < Window  
  def info_window=(window)
    @info_window = window
  end
end

class Window_Equip < Window_Selectable
  def update_help
    @info_window.refresh(item) if @info_window != nil
    @help_window.set_text(item == nil ? "" : item.description)
  end
end

class Window_EquipItem < Window_Item
  alias dhoom_info_equip_item_init initialize
  def initialize(x, y, width, height, actor, equip_type)
    dhoom_info_equip_item_init(x, y, width, height, actor, equip_type)
    @column_max = 1
    self.width = 272
    create_contents
    refresh
  end
  
  def update_help
    @info_window.refresh(item) if @info_window != nil
    @help_window.set_text(item == nil ? "" : item.description)
  end
end

class Window_Info < Window_Base
  include Dhoom::Equip_Info_Panel
  def initialize
    super(272,0,272,104)
    self.contents.font.size = 14
  end
  
  def refresh(item)
    if item.is_a?(RPG::Item) or item.nil?
      self.contents.clear
    end    
    if !item.is_a?(RPG::Item) and item != nil  
      self.contents.clear
      self.contents.font.color = system_color
      self.contents.draw_text(0,0,self.contents.width/2-8,24,Vocab::atk+":")    
      self.contents.draw_text(0,18,self.contents.width/2-8,24,Vocab::def+":") 
      self.contents.draw_text(128,0,self.contents.width/2-8,24,Vocab::spi+":")
      self.contents.draw_text(128,18,self.contents.width/2-8,24,Vocab::agi+":")
      self.contents.font.color = normal_color
      if $dhoom_script["Smithing"] and item.add_atk != nil and item.add_atk > 0
        atk = item.atk - item.add_atk
        self.contents.draw_text(0,0,self.contents.width/2-8,24,atk.to_s+"+"+item.add_atk.to_s,2)
      else
        self.contents.draw_text(0,0,self.contents.width/2-8,24,item.atk.to_s,2)
      end
      if $dhoom_script["Smithing"] and item.add_def != nil and item.add_def > 0
        deff = item.def - item.add_def
        self.contents.draw_text(0,18,self.contents.width/2-8,24,deff.to_s+"+"+item.add_def.to_s,2)
      else
        self.contents.draw_text(0,18,self.contents.width/2-8,24,item.def.to_s,2)
      end
      if $dhoom_script["Smithing"] and item.add_spi != nil and item.add_spi > 0
        spi = item.spi - item.add_spi
        self.contents.draw_text(128,0,self.contents.width/2-8,24,spi.to_s+"+"+item.add_spi.to_s,2)
      else
        self.contents.draw_text(128,0,self.contents.width/2-8,24,item.spi.to_s,2)
      end
      if $dhoom_script["Smithing"] and item.add_agi != nil and item.add_agi > 0
        agi = item.agi - item.add_agi
        self.contents.draw_text(128,18,self.contents.width/2-8,24,agi.to_s+"+"+item.add_agi.to_s,2)
      else
        self.contents.draw_text(128,18,self.contents.width/2-8,24,item.agi.to_s,2)
      end      
      line = 1
      if item.is_a?(RPG::Weapon)
        if item.two_handed and Display_Info_Weapon[0]
          self.contents.draw_text(0,18*line+18,self.contents.width/2-8,18,Vocab_Info_Weapon[0])
          line += 1
        end
        if item.fast_attack and Display_Info_Weapon[1]
          self.contents.draw_text(0,18*line+18,self.contents.width/2-8,18,Vocab_Info_Weapon[1])
          line += 1
        end
        if item.dual_attack and Display_Info_Weapon[2]
          if line >= 3
            self.contents.draw_text(128,18*(line-2)+18,self.contents.width/2-8,18,Vocab_Info_Weapon[2])
          else
            self.contents.draw_text(0,18*line+18,self.contents.width/2-8,18,Vocab_Info_Weapon[2])
          end
          line += 1
        end
        if item.critical_bonus and Display_Info_Weapon[3]
          if line >= 3
            self.contents.draw_text(128,18*(line-2)+18,self.contents.width/2-8,18,Vocab_Info_Weapon[3])
          else
            self.contents.draw_text(0,18*line+18,self.contents.width/2-8,18,Vocab_Info_Weapon[3])
          end
          line += 1
        end
      elsif item.is_a?(RPG::Armor)
        if item.prevent_critical and Display_Info_Armor[0]
          self.contents.draw_text(0,18*line+18,self.contents.width/2-8,18,Vocab_Info_Armor[0])
          line += 1
        end
        if item.half_mp_cost and Display_Info_Armor[1]
          self.contents.draw_text(0,18*line+18,self.contents.width/2-8,18,Vocab_Info_Armor[1])
          line += 1
        end
        if item.double_exp_gain and Display_Info_Armor[2]
          if line >= 3
            self.contents.draw_text(128,18*(line-2)+18,self.contents.width/2-8,18,Vocab_Info_Armor[2])
          else
            self.contents.draw_text(0,18*line+18,self.contents.width/2-8,18,Vocab_Info_Armor[2])
          end
          line += 1
        end
        if item.auto_hp_recover and Display_Info_Armor[3]
          if line >= 3
            self.contents.draw_text(128,18*(line-2)+18,self.contents.width/2-8,18,Vocab_Info_Armor[3])
          else
            self.contents.draw_text(0,18*line+18,self.contents.width/2-8,18,Vocab_Info_Armor[3])
          end
          line += 1
        end
      end
    end
  end
end 

class Scene_Equip < Scene_Base
  alias dhoom_info_equip_start start
  def start
    dhoom_info_equip_start
    @info_window = Window_Info.new
    @info_window.y = 208
    @info2_window = Window_Info.new
    @info2_window.y = 312
    @equip_window.info_window = @info_window
    for window in @item_windows
      window.info_window = @info2_window
    end
  end
  
  alias dhoom_info_equip_update update
  def update
    dhoom_info_equip_update
    @info_window.update
    @info2_window.update
    if @equip_window.active
      @info2_window.contents.clear
    end
  end
  
  alias dhoom_info_equip_terminate terminate
  def terminate
    dhoom_info_equip_terminate
    @info_window.dispose
    @info2_window.dispose
  end
end
