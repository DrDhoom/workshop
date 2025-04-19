#===============================================================================
#
# [VX] Multi Skill, Item, Weapon, and Armor Description
# By DrDhoom
#
# Last Date Updated: 2011.01.13
#
# Script ini berfungsi untuk mengganti deskripsi skill, item, weapon, atau armor.
# Script ini bisa digunakan untuk berbagai macam tujuan, misal: mengganti bahasa
# pada deskripsi.
#
#===============================================================================
# Instructions
#===============================================================================
#
# Masukkan script ini dimana saja diatas Main
#
# - Untuk menambah deskripsi, Tulis tag berikut pada Skill, item, weapon, atau
#  armor notetag:
#  <description>
#  Tulis disini...
#  </description>
# - Gunakan switch untuk mengganti deskripsi. Tulis tag dibawah ini pada notetag
#  desc_switch: switch id
#
#===============================================================================
# Known bug: Pada akhir deskripsi akan ada dua kotak ('\n\r').
#===============================================================================
module MSIWADesc
 
  SKILL_GLOB_SWITCH = 0 #Skill global switch jika switch pada notetag tidak di-
                        # tulis
  ITEM_GLOB_SWITCH = 0 #Item global switch jika switch pada notetag tidak ditulis
  WEAPON_GLOB_SWITCH = 0 #Weapon global switch jika switch pada notetag tidak di-
                        # tulis
  ARMOR_GLOB_SWITCH = 0 #Armor global switch jika switch pada notetag tidak di-
                        # tulis
  #Biarkan 0 kalau switch tidak dipakai.
 
  BEGIN_SIWA_DESCRIPTION = /<(?:description)>/i
  END_SIWA_DESCRIPTION = /<\/(?:description)>/i
 
end

module RPG
 
  class BaseItem
   
  def create_description_cache
    @__siwa_description = ""

    description_flag = false
    self.note.each_line { |line|
      case line
      when MSIWADesc::BEGIN_SIWA_DESCRIPTION
        description_flag = true
      when MSIWADesc::END_SIWA_DESCRIPTION
        description_flag = false
      else
        if description_flag
          @__siwa_description += line
        end
      end
    }
  end
 
  def siwa_description
    create_description_cache if @__siwa_description == nil
    return @__siwa_description
  end
   
    def description_switch
      self.note.each_line { |line|
      return line.gsub('desc_switch: ', '').chomp.to_i if line.include?('desc_switch: ')
      }
      return 0
    end
  end 
end

#===============================================================================
# Overwrite Window_Skill update_help
#===============================================================================
class Window_Skill < Window_Selectable
 
  def update_help
    if skill != nil
      if $game_switches[skill.description_switch] and skill.siwa_description != nil
        @help_window.set_text(skill == nil ? "" : skill.siwa_description)
      elsif $game_switches[MSIWADesc::SKILL_GLOB_SWITCH] and skill.siwa_description != nil
        @help_window.set_text(skill == nil ? "" : skill.siwa_description)
      else
        @help_window.set_text(skill == nil ? "" : skill.description)
      end
    else
      @help_window.set_text(skill == nil ? "" : skill.description)
    end
  end
end

#===============================================================================
# Overwrite Window_Item update_help
#===============================================================================
class Window_Item < Window_Selectable
 
  def update_help
    if item != nil
      if $game_switches[item.description_switch] and item.siwa_description != nil
        @help_window.set_text(item == nil ? "" : item.siwa_description)
      elsif $game_switches[MSIWADesc::ITEM_GLOB_SWITCH] and item.siwa_description != nil and item.is_a?(RPG::Item)
        @help_window.set_text(item == nil ? "" : item.siwa_description)
      else
        @help_window.set_text(item == nil ? "" : item.description)
      end
    else
      @help_window.set_text(item == nil ? "" : item.description)
    end
  end
end


#===============================================================================
# Overwrite Window_Equip update_help
#===============================================================================
class Window_Equip < Window_Selectable
 
  def update_help
    if item != nil
      if $game_switches[item.description_switch] and item.siwa_description != nil
        @help_window.set_text(item == nil ? "" : item.siwa_description)
      elsif $game_switches[MSIWADesc::WEAPON_GLOB_SWITCH] and item.siwa_description != nil and item.is_a?(RPG::Weapon)
        @help_window.set_text(item == nil ? "" : item.siwa_description)
      elsif $game_switches[MSIWADesc::ARMOR_GLOB_SWITCH] and item.siwa_description != nil and item.is_a?(RPG::Armor)
        @help_window.set_text(item == nil ? "" : item.siwa_description)
      else
        @help_window.set_text(item == nil ? "" : item.description)
      end
    else
      @help_window.set_text(item == nil ? "" : item.description)
    end
  end
end

#===============================================================================
# End Script
#===============================================================================
