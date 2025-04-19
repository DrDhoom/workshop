#===============================================================================
#------------------------------= Smithing =-------------------------------------
#-----------------------------= by: DrDhoom =-----------------------------------
# Version: 1.0
# Date Published: 06 - 09 - 2012
#-------------------------------------------------------------------------------
# Introduction:
# With this script, you can make any weapon or armor. The unique about this 
# script, any weapon or armor you've made will gain additional bonus attribute
# and you can name it as you want.
#-------------------------------------------------------------------------------
# How to use:
#   - Insert this script above Main and Below OriginalWij's Input Text(Optional)
#-------------------------------------------------------------------------------
#===============================================================================

module Dhoom
  module Smith    
    Recipe = []
   #Recipe[index] = [ID, Type, [ID, Amount, Type], [ID, Amount, Type], ...]
    Recipe[0] = [5,"Weapon",[1,1,"Item"],[21,2,"Item"],[30,1,"Armor"]]
    Recipe[1] = [1,"Armor",[3,1,"Weapon"],[5,2,"Item"]]
    Recipe[2] = [9,"Weapon",[2,5,"Item"],[5,5,"Item"]]
    Recipe[3] = [30,"Weapon",[1,1,"Item"],[21,2,"Weapon"],[30,1,"Item"]]
    Recipe[4] = [21,"Armor",[2,5,"Item"],[5,5,"Armor"]]
    Recipe[5] = [22,"Armor",[2,5,"Item"],[5,5,"Item"]]
    
    #Renaming item by input, Require OriginalWij's Input Text
    #If set to false, added Add_Item_Name words into item's name. 
    Manual_Item_Renaming = true
    
    Add_Item_Name = "(Custom) "
    
    #If set to false, Add the words before item's name
    Add_Word_After_Name = false
    
    Item_SE = "Item1"
    
    #Display weapon attribute? [Two Handed, Fast Attack, Dual Attack, Critical Bonus]
    Display_Info_Weapon = [true, true, true, true]
    #Display armor attribute? [Prevent Critical, Half MP Cost, Double EXP Gain, Auto HP Recover]
    Display_Info_Armor = [true, true, true, true]
    
    Vocab_Info_Weapon = ["Two Handed", "Fast Attack", "Dual Attack", "Critical Bonus"]
    Vocab_Info_Armor = ["Prevent Critical", "Half MP Cost", "2x EXP", "Regeneration"]
    Input_Name_Help = "Name your item"
    Confirm_Help_Text = "Are you sure to make this item?"
  end
end

$dhoom_script = {} if $dhoom_script.nil?
$dhoom_script["Smithing"] = true

module RPG
  class BaseItem
    def initialize
      @id = 0
      @base_id = 0      
      @name = ""
      @icon_index = 0
      @description = ""
      @note = ""
    end
    attr_accessor :id
    attr_accessor :base_id
    attr_accessor :name
    attr_accessor :icon_index
    attr_accessor :description
    attr_accessor :note
  end
  
  class Weapon < BaseItem
    def initialize
      super
      @animation_id = 0
      @price = 0
      @hit = 95
      @atk = 0
      @add_atk = 0
      @def = 0
      @add_def = 0
      @spi = 0
      @add_spi = 0
      @agi = 0
      @add_agi = 0
      @two_handed = false
      @fast_attack = false
      @dual_attack = false
      @critical_bonus = false
      @element_set = []
      @state_set = []
    end
    attr_accessor :animation_id
    attr_accessor :price
    attr_accessor :hit
    attr_accessor :atk
    attr_accessor :add_atk
    attr_accessor :def
    attr_accessor :add_def
    attr_accessor :spi
    attr_accessor :add_spi
    attr_accessor :agi
    attr_accessor :add_agi
    attr_accessor :two_handed
    attr_accessor :fast_attack
    attr_accessor :dual_attack
    attr_accessor :critical_bonus
    attr_accessor :element_set
    attr_accessor :state_set
  end
  
  class Armor < BaseItem
    def initialize
      super
      @kind = 0
      @price = 0
      @eva = 0
      @atk = 0
      @add_atk = 0
      @def = 0
      @add_def = 0
      @spi = 0
      @add_spi = 0
      @agi = 0
      @add_agi = 0
      @prevent_critical = false
      @half_mp_cost = false
      @double_exp_gain = false
      @auto_hp_recover = false
      @element_set = []
      @state_set = []
    end
    attr_accessor :kind
    attr_accessor :price
    attr_accessor :eva
    attr_accessor :atk
    attr_accessor :add_atk
    attr_accessor :def
    attr_accessor :add_def
    attr_accessor :spi
    attr_accessor :add_spi
    attr_accessor :agi
    attr_accessor :add_agi
    attr_accessor :prevent_critical
    attr_accessor :half_mp_cost
    attr_accessor :double_exp_gain
    attr_accessor :auto_hp_recover
    attr_accessor :element_set
    attr_accessor :state_set
  end
end

class Game_Actor < Game_Battler
  def included_equip(item)
    case item
    when RPG::Weapon
      weapon = $data_weapons[@weapon_id]
      armor1 = $data_weapons[@armor1_id]
      if weapon != nil and weapon.base_id != nil and weapon.base_id == item.id
        return true
      elsif two_swords_style and armor1 != nil and armor1.base_id != nil and armor1.base_id == item.id
        return true
      else
        return false
      end
    when RPG::Armor
      armor1 = $data_armors[@armor1_id]
      armor2 = $data_armors[@armor2_id]
      armor3 = $data_armors[@armor3_id]
      armor4 = $data_armors[@armor4_id]
      if not two_swords_style and armor1 != nil and armor1.base_id != nil and armor1.base_id == item.id
        return true
      elsif armor2 != nil and armor2.base_id != nil and armor2.base_id == item.id
        return true     
      elsif armor3 != nil and armor3.base_id != nil and armor3.base_id == item.id
        return true
      elsif armor4 != nil and armor4.base_id != nil and armor4.base_id == item.id
        return true
      else
        return false
      end
    end
  end
  
  def discard_equip(item)
    weapon = $data_weapons[@weapon_id]
    if two_swords_style
      armor1 = $data_weapons[@armor1_id]
    else
      armor1 = $data_armors[@armor1_id]
    end
    armor2 = $data_armors[@armor2_id]
    armor3 = $data_armors[@armor3_id]
    armor4 = $data_armors[@armor4_id]
    if item.is_a?(RPG::Weapon)
      if @weapon_id == item.id
        @weapon_id = 0
      elsif weapon != nil and weapon.base_id != nil and weapon.base_id == item.id
        @weapon_id = 0    
      elsif two_swords_style and @armor1_id == item.id
        @armor1_id = 0
      elsif two_swords_style and armor1 != nil and armor1.base_id != nil and armor1.base_id == item.id
        @armor1_id = 0
      end
    elsif item.is_a?(RPG::Armor)
      if not two_swords_style and @armor1_id == item.id
        @armor1_id = 0
      elsif not two_swords_style and armor1 != nil and armor1.base_id != nil and armor1.base_id == item.id
        @armor1_id = 0
      elsif @armor2_id == item.id
        @armor2_id = 0
      elsif armor2 != nil and armor2.base_id != nil and armor2.base_id == item.id
        @armor2_id = 0      
      elsif @armor3_id == item.id
        @armor3_id = 0
      elsif armor3 != nil and armor3.base_id != nil and armor3.base_id == item.id
        @armor3_id = 0
      elsif @armor4_id == item.id
        @armor4_id = 0
      elsif armor4 != nil and armor4.base_id != nil and armor4.base_id == item.id
        @armor4_id = 0
      end
    end
  end
end

class Game_Party < Game_Unit
  def has_item?(item, include_equip = false)
    if item_number(item) > 0
      return true
    end
    if include_equip
      for actor in members
        return true if actor.equips.include?(item)
        return true if actor.included_equip(item)
      end
    end    
    if item.is_a?(RPG::Weapon)
      for i in @weapons.keys.sort
        weapon = $data_weapons[i]
        if weapon != nil and weapon.base_id != nil and weapon.base_id == item.id and @weapons[i] > 0
          return true
        end        
      end
    elsif item.is_a?(RPG::Armor)
      for i in @armors.keys.sort
        armor = $data_armors[i]
        if armor != nil and armor.base_id != nil and armor.base_id == item.id and @armors[i] > 0
          return true
        end
      end
    end    
    return false
  end
  
  def gain_item(item, n, include_equip = false)
    number = item_number(item)
    case item
    when RPG::Item
      @items[item.id] = [[number + n, 0].max, 99].min
    when RPG::Weapon
      @weapons[item.id] = [[number + n, 0].max, 99].min
    when RPG::Armor
      @armors[item.id] = [[number + n, 0].max, 99].min
    end
    n += number
    if n < 0
      case item
      when RPG::Weapon
        for i in @weapons.keys.sort
          weapon = $data_weapons[i]
          if weapon != nil and weapon.base_id != nil and weapon.base_id == item.id and @weapons[i] > 0
            numb = @weapons[i]
            @weapons[i] += n
            n += numb
          end
        end
      when RPG::Armor
        for i in @armors.keys.sort
          armor = $data_armors[i]
          if armor != nil and armor.base_id != nil and armor.base_id == item.id and @armors[i] > 0
            numb = @armors[i]
            @armors[i] += n
            n += numb
          end
        end
      end
    end
    if include_equip and n < 0
      for actor in members
        while n < 0 and (actor.equips.include?(item) or actor.included_equip(item))
          actor.discard_equip(item)
          n += 1
        end
      end
    end
  end
end

class Game_Interpreter
  def command_111
    result = false
    case @params[0]
    when 0  # Switch
      result = ($game_switches[@params[1]] == (@params[2] == 0))
    when 1  # Variable
      value1 = $game_variables[@params[1]]
      if @params[2] == 0
        value2 = @params[3]
      else
        value2 = $game_variables[@params[3]]
      end
      case @params[4]
      when 0  # value1 is equal to value2
        result = (value1 == value2)
      when 1  # value1 is greater than or equal to value2
        result = (value1 >= value2)
      when 2  # value1 is less than or equal to value2
        result = (value1 <= value2)
      when 3  # value1 is greater than value2
        result = (value1 > value2)
      when 4  # value1 is less than value2
        result = (value1 < value2)
      when 5  # value1 is not equal to value2
        result = (value1 != value2)
      end
    when 2  # Self switch
      if @original_event_id > 0
        key = [@map_id, @original_event_id, @params[1]]
        if @params[2] == 0
          result = ($game_self_switches[key] == true)
        else
          result = ($game_self_switches[key] != true)
        end
      end
    when 3  # Timer
      if $game_system.timer_working
        sec = $game_system.timer / Graphics.frame_rate
        if @params[2] == 0
          result = (sec >= @params[1])
        else
          result = (sec <= @params[1])
        end
      end
    when 4  # Actor
      actor = $game_actors[@params[1]]
      if actor != nil
        case @params[2]
        when 0  # in party
          result = ($game_party.members.include?(actor))
        when 1  # name
          result = (actor.name == @params[3])
        when 2  # skill
          result = (actor.skill_learn?($data_skills[@params[3]]))
        when 3  # weapon
          if !actor.weapons.include?($data_weapons[@params[3]])
            for weapon in actor.weapons
              if weapon != nil and weapon.base_id != nil and weapon.base_id == $data_weapons[@params[3]].id
                result = true
                break
              else
                result = false
              end
            end
          else
            result = (actor.weapons.include?($data_weapons[@params[3]]))
          end          
        when 4  # armor
          if !actor.armors.include?($data_armors[@params[3]])
            for armor in actor.armors
              if armor != nil and armor.base_id != nil and armor.base_id == $data_armors[@params[3]].id
                result = true
                break
              else
                result = false
              end
            end
          else
            result = (actor.armors.include?($data_armors[@params[3]]))
          end
        when 5  # state
          result = (actor.state?(@params[3]))
        end
      end
    when 5  # Enemy
      enemy = $game_troop.members[@params[1]]
      if enemy != nil
        case @params[2]
        when 0  # appear
          result = (enemy.exist?)
        when 1  # state
          result = (enemy.state?(@params[3]))
        end
      end
    when 6  # Character
      character = get_character(@params[1])
      if character != nil
        result = (character.direction == @params[2])
      end
    when 7  # Gold
      if @params[2] == 0
        result = ($game_party.gold >= @params[1])
      else
        result = ($game_party.gold <= @params[1])
      end
    when 8  # Item
      result = $game_party.has_item?($data_items[@params[1]])
    when 9  # Weapon
      result = $game_party.has_item?($data_weapons[@params[1]], @params[2])
    when 10  # Armor
      result = $game_party.has_item?($data_armors[@params[1]], @params[2])
    when 11  # Button
      result = Input.press?(@params[1])
    when 12  # Script
      result = eval(@params[1])
    when 13  # Vehicle
      result = ($game_player.vehicle_type == @params[1])
    end
    @branch[@indent] = result     # Store determination results in hash
    if @branch[@indent] == true
      @branch.delete(@indent)
      return true
    end
    return command_skip
  end
end

class Window_Smith_Select < Window_Selectable
  include Dhoom::Smith
  def initialize
    super(0, 56, 272, 360)
    @column_max = 1
    self.index = 0
    check_avaible_recipe
    refresh
  end
  
  def recreate
    check_avaible_recipe
    refresh
  end
  
  def update
    super
  end
  
  def dispose
    super
  end
  
  def avaible?
    return @avaible_recipe[self.index]
  end
  
  def check_avaible_recipe
    @avaible_recipe = []
    for i in 0...Recipe.size
      @avaible_recipe[i] = false
      tmp = 0
      for a in 2...Recipe[i].size
        case Recipe[i][a][2]
        when "Weapon"
          item = $data_weapons[Recipe[i][a][0]]
        when "Armor"
          item = $data_armors[Recipe[i][a][0]]
        when "Item"
          item = $data_items[Recipe[i][a][0]]
        end        
        if $game_party.items.include?(item) and $game_party.item_number(item) >= Recipe[i][a][1]
          tmp += 1
        end
      end
      if tmp == Recipe[i].size - 2
        @avaible_recipe[i] = true
      end
    end
  end
  
  def refresh
    @data = []
    @item_recipe = []
    for i in 0...Recipe.size
      if Recipe[i][1] == "Weapon"
        @item_recipe[i] = $data_weapons[Recipe[i][0]]
      elsif Recipe[i][1] == "Armor"
        @item_recipe[i] = $data_armors[Recipe[i][0]]
      end
    end
    for item in @item_recipe
      @data.push(item)
    end
    @item_max = @data.size
    create_contents
    for i in 0...@item_max
      draw_item(i)
    end
  end

  def draw_item(index)
    rect = item_rect(index)
    self.contents.clear_rect(rect)
    item = @data[index]
    if item != nil
      enabled = @avaible_recipe[index]
      rect.width -= 4
      draw_item_name(item, rect.x, rect.y, enabled)
    end
  end
  
  def item
    return @data[self.index]
  end
  
  def more_window=(window)
    @more_window = window
    update_help
  end
  
  def info_window=(window)
    @info_window = window
    update_help
  end
  
  def update_help
    @help_window.set_text(@data[self.index] == nil ? "" : @data[self.index].description)
    @info_window.refresh(@data[self.index]) if @info_window != nil
    @more_window.refresh(self.index) if @more_window != nil
  end
end

class Window_Smith_Info < Window_Base
  include Dhoom::Smith
  def initialize
    super(272,56,272,128)
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
      self.contents.draw_text(0,24,self.contents.width/2-8,24,Vocab::def+":")  
      self.contents.draw_text(128,0,self.contents.width/2-8,24,Vocab::spi+":")
      self.contents.draw_text(128,24,self.contents.width/2-8,24,Vocab::agi+":")     
      self.contents.font.color = normal_color
      self.contents.draw_text(0,0,self.contents.width/2-8,24,item.atk.to_s,2)
      self.contents.draw_text(0,24,self.contents.width/2-8,24,item.def.to_s,2)      
      self.contents.draw_text(128,0,self.contents.width/2-8,24,item.spi.to_s,2)
      self.contents.draw_text(128,24,self.contents.width/2-8,24,item.agi.to_s,2)
      line = 1
      if item.is_a?(RPG::Weapon)
        if item.two_handed and Display_Info_Weapon[0]
          self.contents.draw_text(0,24*line+24,self.contents.width/2-8,24,Vocab_Info_Weapon[0])
          line += 1
        end
        if item.fast_attack and Display_Info_Weapon[1]
          self.contents.draw_text(0,24*line+24,self.contents.width/2-8,24,Vocab_Info_Weapon[1])
          line += 1
        end
        if item.dual_attack and Display_Info_Weapon[2]
          if line >= 3
            self.contents.draw_text(128,24*(line-2)+24,self.contents.width/2-8,24,Vocab_Info_Weapon[2])
          else
            self.contents.draw_text(0,24*line+24,self.contents.width/2-8,24,Vocab_Info_Weapon[2])
          end
          line += 1
        end
        if item.critical_bonus and Display_Info_Weapon[3]
          if line >= 3
            self.contents.draw_text(128,24*(line-2)+24,self.contents.width/2-8,24,Vocab_Info_Weapon[3])
          else
            self.contents.draw_text(0,24*line+24,self.contents.width/2-8,24,Vocab_Info_Weapon[3])
          end
          line += 1
        end
      elsif item.is_a?(RPG::Armor)
        if item.prevent_critical and Display_Info_Armor[0]
          self.contents.draw_text(0,24*line+24,self.contents.width/2-8,24,Vocab_Info_Armor[0])
          line += 1
        end
        if item.half_mp_cost and Display_Info_Armor[1]
          self.contents.draw_text(0,24*line+24,self.contents.width/2-8,24,Vocab_Info_Armor[1])
          line += 1
        end
        if item.double_exp_gain and Display_Info_Armor[2]
          if line >= 3
            self.contents.draw_text(128,24*(line-2)+24,self.contents.width/2-8,24,Vocab_Info_Armor[2])
          else
            self.contents.draw_text(0,24*line+24,self.contents.width/2-8,24,Vocab_Info_Armor[2])
          end
          line += 1
        end
        if item.auto_hp_recover and Display_Info_Armor[3]
          if line >= 3
            self.contents.draw_text(128,24*(line-2)+24,self.contents.width/2-8,24,Vocab_Info_Armor[3])
          else
            self.contents.draw_text(0,24*line+24,self.contents.width/2-8,24,Vocab_Info_Armor[3])
          end
          line += 1
        end
      end
    end
  end
end  

class Window_Smith_Ingredient < Window_Base
  include Dhoom::Smith
  def initialize
    super(272,184,272,232)
    self.contents.font.size = 14
  end
  
  def refresh(index)
    self.contents.clear
    for i in 2...Recipe[index].size
      case Recipe[index][i][2]
      when "Weapon"
        item = $data_weapons[Recipe[index][i][0]]
      when "Armor"
        item = $data_armors[Recipe[index][i][0]]
      when "Item"
        item = $data_items[Recipe[index][i][0]]
      end
      if $game_party.item_number(item) >= Recipe[index][i][1]
        enabled = true
      else
        enabled = false
      end
      amount = $game_party.item_number(item).to_s+"/"+Recipe[index][i][1].to_s
      draw_item_name(item, 0, (i-2)*24, enabled, amount)
    end
  end
  
  def draw_item_name(item, x, y, enabled, amount)
    if item != nil
      draw_icon(item.icon_index, x, y)
      if enabled
        self.contents.font.color = normal_color
      else
        self.contents.font.color = knockout_color
      end
      self.contents.draw_text(x + 24, y, self.contents.width-32, WLH, item.name)
      self.contents.draw_text(x + 24, y, self.contents.width-32, WLH, amount, 2)
    end
  end
end

class Window_Smith_Help < Window_Base
  def initialize
    super(0, 200, 544, WLH + 32)
  end

  def set_text(text)
    if text != @text
      self.width = self.contents.text_size(text).width+32
      self.x = (544-self.width)/2
      create_contents
      self.contents.clear
      self.contents.font.color = normal_color
      self.contents.draw_text(4, 0, self.width - 40, WLH, text, 1)
      @text = text
    end
  end
end

class Scene_Smith < Scene_Base
  include Dhoom::Smith
  def start
    super
    create_menu_background
    create_windows
  end
  
  def create_windows
    @select_window = Window_Smith_Select.new
    @info_window = Window_Smith_Info.new
    @ingredient_window = Window_Smith_Ingredient.new
    @help2_window = Window_Help.new
    @select_window.help_window = @help2_window
    @select_window.info_window = @info_window
    @select_window.more_window = @ingredient_window
    @help_window = Window_Smith_Help.new
    @help_window.set_text(Confirm_Help_Text)
    @confirm_window = Window_Command.new(@help_window.width, ["Yes","No"])
    @confirm_window.y = @help_window.y + 56
    @confirm_window.x = @help_window.x
    @confirm_window.active = false
    @confirm_window.visible = false
    @help_window.visible = false
  end
  
  def update
    super
    update_menu_background
    @select_window.update
    @info_window.update
    @ingredient_window.update
    @help_window.update
    @help2_window.update
    @confirm_window.update    
    if @select_window.active
      update_item_select
    elsif @confirm_window.active
      update_confirmation
    end
  end
  
  def update_item_select
    if Input.trigger?(Input::C)
      if @select_window.avaible?
        Sound.play_decision
        @select_window.active = false
        @help_window.visible = true
        @confirm_window.visible = true
        @confirm_window.active = true
        return
      else
        Sound.play_buzzer
      end
    elsif Input.trigger?(Input::B)
      Sound.play_cancel
      $scene = Scene_Map.new
    end
  end
    
  def update_confirmation
    if Input.trigger?(Input::C)      
      case @confirm_window.index
      when 0
        Sound.play_decision
        @help_window.set_text(Input_Name_Help)
        @confirm_window.visible = false
        @confirm_window.active = false
        if Manual_Item_Renaming
          $scene.text_input(@help_window.x-185, @help_window.y+16)
          while $scene.inputting_text?
            Graphics.update
            Input.update
            $scene.update_text_input
          end
        end
        make_item
        dispose_ingredient
        @select_window.recreate
        @help_window.visible = false
        @select_window.active = true
        @inputting = false
        sound = RPG::SE.new(Item_SE)
        sound.play
        return
      when 1
        Sound.play_cancel
        @confirm_window.visible = false
        @confirm_window.active = false
        @help_window.visible = false
        @select_window.active = true
      end
    elsif Input.trigger?(Input::B)
      Sound.play_cancel
      @confirm_window.visible = false
      @confirm_window.active = false
      @help_window.visible = false
      @select_window.active = true
    end
  end
  
  def make_item
    base_item = @select_window.item
    if base_item.is_a?(RPG::Weapon)
      $data_weapons[$data_weapons.size] = RPG::Weapon.new      
      item = $data_weapons[$data_weapons.size-1]
      item.id = $data_weapons.size-1
      for clas in $data_classes
        if clas != nil and clas.weapon_set.include?(base_item.id)
          clas.weapon_set.push(item.id)
        end
      end
      item.animation_id = base_item.animation_id
      item.hit = base_item.hit
      item.critical_bonus = base_item.critical_bonus
      item.fast_attack = base_item.fast_attack
      item.dual_attack = base_item.dual_attack
      item.two_handed = base_item.two_handed
      item.element_set = base_item.element_set.dup
      item.state_set = base_item.state_set.dup      
      random = rand(50)
      if random >= 45
        item.fast_attack = true
      end
      if random >= 47
        item.dual_attack = true
      end
      if random >= 49
        item.critical_bonus = true
      end
    elsif base_item.is_a?(RPG::Armor)
      $data_armors[$data_armors.size] = RPG::Armor.new      
      item = $data_armors[$data_armors.size-1]
      item.id = $data_armors.size-1
      for clas in $data_classes
        if clas != nil and clas.armor_set.include?(base_item.id)
          clas.armor_set.push(item.id)
        end
      end
      item.kind = base_item.kind
      item.eva = base_item.eva      
      item.prevent_critical = base_item.prevent_critical
      item.half_mp_cost = base_item.half_mp_cost
      item.double_exp_gain = base_item.double_exp_gain
      item.auto_hp_recover = base_item.auto_hp_recover    
      random = rand(50)
      if random >= 43
        item.prevent_critical = true
      end
      if random >= 45
        item.half_mp_cost = true
      end
      if random >= 47
        item.double_exp_gain = true
      end
      if random >= 49
        item.auto_hp_recover = true
      end
    end    
    item.icon_index = base_item.icon_index
    item.note = base_item.note
    item.description = base_item.description
    item.add_atk = rand(base_item.atk*20/100+2)
    item.add_def = rand(base_item.def*20/100+2)
    item.add_agi = rand(base_item.agi*20/100+2)
    item.add_spi = rand(base_item.spi*20/100+2)
    item.atk = base_item.atk+item.add_atk
    item.def = base_item.def+item.add_def
    item.agi = base_item.agi+item.add_agi
    item.spi = base_item.spi+item.add_spi
    item.base_id = base_item.id
    item.price = base_item.price + rand(base_item.price*20/100)
    if Manual_Item_Renaming
      item.name = $text_input
    else
      if Add_Word_After_Name
        item.name = base_item.name+Add_Item_Name
      else
        item.name = Add_Item_Name+base_item.name
      end
    end
    $game_party.gain_item(item, 1)
  end
  
  def dispose_ingredient
    for i in 2...Recipe[@select_window.index].size
      case Recipe[@select_window.index][i][2]
      when "Weapon"
        item = $data_weapons[Recipe[@select_window.index][i][0]]
      when "Armor"
        item = $data_armors[Recipe[@select_window.index][i][0]]
      when "Item"
        item = $data_items[Recipe[@select_window.index][i][0]]
      end
      $game_party.lose_item(item, Recipe[@select_window.index][i][1],true)
    end
  end
  
  def terminate
    super
    dispose_menu_background
    @select_window.dispose
    @info_window.dispose
    @ingredient_window.dispose
    @help_window.dispose
    @confirm_window.dispose
    @help2_window.dispose
  end
end
