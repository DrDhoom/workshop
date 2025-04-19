#===============================================================================
#------------------------= Weapon/Armor Durabilty =-----------------------------
#-----------------------------= by: DrDhoom =-----------------------------------
# Version: 2
# Date Published: 13 - 09 - 2012
#-------------------------------------------------------------------------------
# Introduction:
# With this script, you can make a weapon or armor have durability. If
# item durability become 0, that item will be discarded. Durability of item
# decrease by 1 after battle end.
# Note : Item with the same ID doesn't share the same durability anymore.
#-------------------------------------------------------------------------------
# How to use:
#  - Insert this script above Main 
#-------------------------------------------------------------------------------
# Changelog:
#  - V1.0 11 - 12 - 2011 : First Realease
#  - V1.1 13 - 12 - 2011 : Added following feature :
#    - Item name with 0 durability can be inserting with custom text.
#    - Item with 0 durability now can be not discarded, but that item can't be
#      equipped
#    - Adding function fix_durability
#    - Adding function broken_count
#    - Adding function in $game_party:
#      - check_durability
#      - decrease_durability
#      - decrease_all_durability
#      - fix_all_durability
#      - fix_all_equipped_durability
#      - break_all_durability
#    - Adding FixShop scene
#    - Adding some comment
#  - V1.1a 16 - 12 - 2011 : Fixed Bug :
#    - Error when opening Item and Skill Menu
#  - V2 13 - 09 - 2012 : Major Change :
#    - Now, every item with the same ID has its own durability
#    - Rewrite almost all of function
#    - Adding function fix_equip_durability
#    Removed feature :
#    - function broken_count
#    - function check_durability
#    - function fix_all_equipped_durability
#    - since every items has its own durability, editing durability variable
#      directly would cause an error
#-------------------------------------------------------------------------------
# (Compatible with Tankentai SBS)
#===============================================================================

module Dhoom
  module Durability
       
    #You can call this function by $game_party.function, where function is one
    #below:
    # - decrease_durability(actor id,region)
    #                                  #decrease equipped item's durability
    #                                    from actor by 1 in region.
    #                                    Actor ID = 0 to all actors
    #                                    Region 0..4 (weapon..armor4) or 5 to
    #                                    all region.
    # - decrease_all_durability        #decrease all item's durability by 1
    # - fix_all_durability              #fix all item, including items in
    #                                    inventory
    # - fix_equip_durability(actor id,region)
    #                                  #fix equipped item's durability
    #                                    from actor by 1 in region.
    #                                    Actor ID = 0 to all actors
    #                                    Region 0..4 (weapon..armor4) or 5 to
    #                                    all region.
    # - break_all_durability            #Set all item's durability to 0,
    #                                    including items in inventory
       
    #If true, the percentage of durability shown after item's name
    SHOW_DURABILITY_PERCENTAGE = true
   
    #If item's durability is 0, put this text to item's name
    BROKEN_ITEM_TEXT = "BROKEN "
   
    # 0 = In front of item's name, 1 = Behind item's name
    BROKEN_ITEM_TEXT_ALIGN = 0
   
    # Color for broken item's name : Color.new(R,G,B)
    BROKEN_ITEM_TEXT_COLOR = Color.new(255,0,0)
   
    #Weapon_Dur[Weapon ID] = Durability
    Weapon_Dur = []
    Weapon_Dur[1] = 1
    Weapon_Dur[15] = 2
   
    #Armor_Dur[Armor ID] = Durability
    Armor_Dur = []
    Armor_Dur[1] = 3
    Armor_Dur[8] = 2
    Armor_Dur[14] = 1
    Armor_Dur[24] = 4
   
    #Dont discard item with durability below or equal to 0, but that item can't
    #be equipped and you can fix that item with event by this command :
    # - for Weapon = $data_weapons[Weapon ID].fix_durability
    # - for Armor = $data_armors[Armor ID].fix_durability
    #or by entering Fix Shop by this command:
    # - $scene = Scene_FixShop.new
    DONT_DISCARD = true
   
    #If true, when you enter Fix Shop, the price for fix that item is based
    #from what you specified below.
    #If false, set the price by item's default price.
    USE_CUSTOM_PRICE = true
   
    # 0 = Half item's price,
    # 1 = Normal item's price,
    CUSTOM_PRICE_METHOD = 1
   
    #Weapon_FPrice[Weapon ID] = Fix Price
    Weapon_FPrice = []
    Weapon_FPrice[1] = 200
    Weapon_FPrice[15] = 100
   
    #Armor_FPrice[Armor ID] = Fix Price
    Armor_FPrice = []
    Armor_FPrice[1] = 80
    Armor_FPrice[8] = 160
    Armor_FPrice[14] = 240
    Armor_FPrice[24] = 320
   
    #Used for FixShop Scene
    Voc_Command1 = "Fix"
    Voc_Command2 = "Leave"
    Confirm_Text = "Do you really want to fix this item?"
  end
end

$dhoom_script = {} if $dhoom_script.nil?
$dhoom_script["WA_Durability"] = true

$data_weapons_dur = [] if $data_weapons_dur.nil?
$data_armors_dur = [] if $data_armors_dur.nil?

module RPG 
  class BaseItem
    def dur_initialize
      @durability = 0
      @base_dur = 0
    end
    attr_accessor :durability
    attr_accessor :base_dur
  end
 
  class Weapon < BaseItem
    include Dhoom::Durability
    def create_durability
      dur_initialize     
      for i in 0...Weapon_Dur[@id]
        x = $data_weapons.size
        $data_weapons[x] = $data_weapons[@id].dup
        $data_weapons[x].id = x
        $data_weapons[x].durability = i
        $data_weapons[x].base_dur = @id
        if i == 0
          case BROKEN_ITEM_TEXT_ALIGN
          when 0
            $data_weapons[x].name = BROKEN_ITEM_TEXT + $data_weapons[x].name
          when 1
            $data_weapons[x].name = $data_weapons[x].name + BROKEN_ITEM_TEXT
          end
        else
          if SHOW_DURABILITY_PERCENTAGE
            percent = i.to_f/Weapon_Dur[@id]*100
            $data_weapons[x].name += " " + percent.to_i.to_s + "%"
          end
        end
        $data_weapons_dur[@id] = [] if $data_weapons_dur[@id].nil?
        $data_weapons_dur[@id].push(x)
        for clas in $data_classes
          if clas != nil and clas.weapon_set.include?(@id)
            clas.weapon_set.push(x)
          end
        end
      end
      @durability = Weapon_Dur[@id]
      @name += " 100%" if SHOW_DURABILITY_PERCENTAGE
    end
   
    def fix_price
      if Weapon_FPrice[@id] != nil
        price = Weapon_FPrice[@id]
      elsif Weapon_FPrice[@base_dur] != nil
        price = Weapon_FPrice[@base_dur]
      end
      if USE_CUSTOM_PRICE
        case CUSTOM_PRICE_METHOD
        when 0
          return price/2
        when 1
          return price
        end       
      else
        case CUSTOM_PRICE_METHOD
        when 0
          return @price/2
        when 1
          return @price
        end
      end
    end
  end
 
  class Armor < BaseItem
    include Dhoom::Durability
    def create_durability
      dur_initialize     
      for i in 0...Armor_Dur[@id]
        x = $data_armors.size
        $data_armors[x] = $data_armors[@id].dup
        $data_armors[x].id = x
        $data_armors[x].durability = i
        $data_armors[x].base_dur = @id
        if i == 0
          case BROKEN_ITEM_TEXT_ALIGN
          when 0
            $data_armors[x].name = BROKEN_ITEM_TEXT + $data_armors[x].name
          when 1
            $data_armors[x].name = $data_armors[x].name + BROKEN_ITEM_TEXT
          end
        else
          if SHOW_DURABILITY_PERCENTAGE
            percent = i.to_f/Armor_Dur[@id]*100
            $data_armors[x].name += " " + percent.to_i.to_s + "%"
          end
        end
        $data_armors_dur[@id] = [] if $data_armors_dur[@id].nil?
        $data_armors_dur[@id].push(x)
        for clas in $data_classes
          if clas != nil and clas.armor_set.include?(@id)
            clas.armor_set.push(x)
          end
        end
      end
      @durability = Armor_Dur[@id]
      @name += " 100%" if SHOW_DURABILITY_PERCENTAGE
    end
   
    def fix_price
      if Armor_FPrice[@id] != nil
        price = Armor_FPrice[@id]
      elsif Armor_FPrice[@base_dur] != nil
        price = Armor_FPrice[@base_dur]
      end
      if USE_CUSTOM_PRICE
        case CUSTOM_PRICE_METHOD
        when 0
          return price/2
        when 1
          return price
        end
      else
        case CUSTOM_PRICE_METHOD
        when 0
          return @price/2
        when 1
          return @price
        end
      end
    end
  end
end

class Game_Actor < Game_Battler
  def weapon_id=(id)
    @weapon_id = id
  end
 
  def armor1_id=(id)
    @armor1_id = id
  end
 
  def armor2_id=(id)
    @armor2_id = id
  end
 
  def armor3_id=(id)
    @armor3_id = id
  end
 
  def armor4_id=(id)
    @armor4_id = id
  end
 
  alias dhoom_dura_act_equip? equippable? 
  def equippable?(item)
    if item.durability != nil and item.durability == 0
      return false
    end
    dhoom_dura_act_equip?(item)
  end
 
  def included_equip(item)
    case item
    when RPG::Weapon
      weapon = $data_weapons[@weapon_id]
      armor1 = $data_weapons[@armor1_id]
      if weapon != nil and weapon.base_dur != nil and weapon.base_dur == item.id
        return true
      elsif two_swords_style and armor1 != nil and armor1.base_dur != nil and armor1.base_dur == item.id
        return true
      else
        return false
      end
    when RPG::Armor
      armor1 = $data_armors[@armor1_id]
      armor2 = $data_armors[@armor2_id]
      armor3 = $data_armors[@armor3_id]
      armor4 = $data_armors[@armor4_id]
      if not two_swords_style and armor1 != nil and armor1.base_dur != nil and armor1.base_dur == item.id
        return true
      elsif armor2 != nil and armor2.base_dur != nil and armor2.base_dur == item.id
        return true   
      elsif armor3 != nil and armor3.base_dur != nil and armor3.base_dur == item.id
        return true
      elsif armor4 != nil and armor4.base_dur != nil and armor4.base_dur == item.id
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
      elsif weapon != nil and weapon.base_dur != nil and weapon.base_dur == item.id
        @weapon_id = 0   
      elsif two_swords_style and @armor1_id == item.id
        @armor1_id = 0
      elsif two_swords_style and armor1 != nil and armor1.base_dur != nil and armor1.base_dur == item.id
        @armor1_id = 0
      end
    elsif item.is_a?(RPG::Armor)
      if not two_swords_style and @armor1_id == item.id
        @armor1_id = 0
      elsif not two_swords_style and armor1 != nil and armor1.base_dur != nil and armor1.base_dur == item.id
        @armor1_id = 0
      elsif @armor2_id == item.id
        @armor2_id = 0
      elsif armor2 != nil and armor2.base_dur != nil and armor2.base_dur == item.id
        @armor2_id = 0     
      elsif @armor3_id == item.id
        @armor3_id = 0
      elsif armor3 != nil and armor3.base_dur != nil and armor3.base_dur == item.id
        @armor3_id = 0
      elsif @armor4_id == item.id
        @armor4_id = 0
      elsif armor4 != nil and armor4.base_dur != nil and armor4.base_dur == item.id
        @armor4_id = 0
      end
    end
  end
end

class Game_Party < Game_Unit
  include Dhoom::Durability
 
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
        if weapon != nil and weapon.base_dur != nil and weapon.base_dur == item.id and @weapons[i] > 0
          return true
        end       
      end
    elsif item.is_a?(RPG::Armor)
      for i in @armors.keys.sort
        armor = $data_armors[i]
        if armor != nil and armor.base_dur != nil and armor.base_dur == item.id and @armors[i] > 0
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
          if weapon != nil and weapon.base_dur != nil and weapon.base_dur == item.id and @weapons[i] > 0
            numb = @weapons[i]
            @weapons[i] += n
            n += numb
          end
        end
      when RPG::Armor
        for i in @armors.keys.sort
          armor = $data_armors[i]
          if armor != nil and armor.base_dur != nil and armor.base_dur == item.id and @armors[i] > 0
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
 
  def fix_equip_durability(actor_id = 0, region = 5)
    for actor in members
      if actor_id == 0 or actor_id == actor.id
        if actor.weapon_id != 0 and (Weapon_Dur[actor.weapon_id] != nil or ($data_weapons[actor.weapon_id].base_dur != 0 and $data_weapons[actor.weapon_id].base_dur != nil))
          if region == 5 or region == 0
            item = $data_weapons[actor.weapon_id]
            if item.base_dur != nil and item.base_dur != 0
              actor.weapon_id = item.base_dur
            end
          end
        end
        if actor.two_swords_style
          if actor.armor1_id != 0 and (Weapon_Dur[actor.armor1_id] != nil or ($data_weapons[actor.armor1_id].base_dur != 0 and $data_weapons[actor.armor1_id].base_dur != nil))
            if region == 5 or region == 1
              item = $data_weapons[actor.armor1_id]
              if item.base_dur != nil and item.base_dur != 0
                actor.armor1_id = item.base_dur
              end
            end
          end
        else
          if actor.armor1_id != 0 and (Armor_Dur[actor.armor1_id] != nil or ($data_armors[actor.armor1_id].base_dur != 0 and $data_armors[actor.armor1_id].base_dur != nil))
            if region == 5 or region == 1
              item = $data_armors[actor.armor1_id]
              if item.base_dur != nil and item.base_dur != 0
                actor.armor1_id = item.base_dur
              end
            end
          end
        end
        if actor.armor2_id != 0 and (Armor_Dur[actor.armor2_id] != nil or ($data_armors[actor.armor2_id].base_dur != 0 and $data_armors[actor.armor2_id].base_dur != nil))
          if region == 5 or region == 2
            item = $data_armors[actor.armor2_id]
            if item.base_dur != nil and item.base_dur != 0
              actor.armor2_id = item.base_dur
            end
          end
        end
        if actor.armor3_id != 0 and (Armor_Dur[actor.armor3_id] != nil or ($data_armors[actor.armor3_id].base_dur != 0 and $data_armors[actor.armor3_id].base_dur != nil))
          if region == 5 or region == 3
            item = $data_armors[actor.armor3_id]
            if item.base_dur != nil and item.base_dur != 0
              actor.armor3_id = item.base_dur
            end
          end
        end
        if actor.armor4_id != 0 and (Armor_Dur[actor.armor4_id] != nil or ($data_armors[actor.armor4_id].base_dur != 0 and $data_armors[actor.armor4_id].base_dur != nil))
          if region == 5 or region == 4
            item = $data_armors[actor.armor4_id]
            if item.base_dur != nil and item.base_dur != 0
              actor.armor4_id = item.base_dur
            end
          end
        end
      end
    end
  end
 
  def fix_all_durability
    for item in items
      if item.is_a?(RPG::Weapon) and item.base_dur != nil and item.base_dur != 0
        numb = item_number(item)
        gain_item($data_weapons[item.base_dur],numb)
        gain_item(item,-numb)
      elsif item.is_a?(RPG::Armor) and item.base_dur != nil and item.base_dur != 0
        numb = item_number(item)
        gain_item($data_armors[item.base_dur],numb)
        gain_item(item,-numb)
      end
    end
    fix_equip_durability
  end 
 
  def decrease_durability(actor_id=0,region=5)
    for actor in members
      if actor_id == 0 or actor_id == actor.id
        if actor.weapon_id != 0 and (Weapon_Dur[actor.weapon_id] != nil or ($data_weapons[actor.weapon_id].base_dur != 0 and $data_weapons[actor.weapon_id].base_dur != nil))
          if region == 5 or region == 0
            item = $data_weapons[actor.weapon_id]
            id = actor.weapon_id
            dura = item.durability - 1
            if dura == 0
              if item.durability == Weapon_Dur[actor.weapon_id]
                gain_item($data_weapons[$data_weapons_dur[id][0]],1) if DONT_DISCARD
              else
                gain_item($data_weapons[$data_weapons_dur[item.base_dur][0]],1) if DONT_DISCARD
              end
              actor.weapon_id = 0
            elsif item.durability == Weapon_Dur[actor.weapon_id]
              actor.weapon_id = $data_weapons_dur[id][dura]
            else
              actor.weapon_id = $data_weapons_dur[item.base_dur][dura]
            end
          end
        end
        if actor.two_swords_style
          if actor.armor1_id != 0 and (Weapon_Dur[actor.armor1_id] != nil or ($data_weapons[actor.armor1_id].base_dur != 0 and $data_weapons[actor.armor1_id].base_dur != nil))
            if region == 5 or region == 1
              item = $data_weapons[actor.armor1_id]
              id = actor.armor1_id
              dura = item.durability - 1
              if dura == 0
                if item.durability == Weapon_Dur[actor.armor1_id]
                  gain_item($data_weapons[$data_weapons_dur[id][0]],1) if DONT_DISCARD
                else
                  gain_item($data_weapons[$data_weapons_dur[item.base_dur][0]],1) if DONT_DISCARD
                end
                actor.armor1_id = 0
              elsif item.durability == Weapon_Dur[actor.armor1_id]
                actor.armor1_id = $data_weapons_dur[id][dura]
              else
                actor.armor1_id = $data_weapons_dur[item.base_dur][dura]
              end
            end
          end
        else
          if actor.armor1_id != 0 and (Armor_Dur[actor.armor1_id] != nil or ($data_armors[actor.armor1_id].base_dur != 0 and $data_armors[actor.armor1_id].base_dur != nil))
            if region == 5 or region == 1
              item = $data_armors[actor.armor1_id]
              id = actor.armor1_id
              dura = item.durability - 1
              if dura == 0
                if item.durability == Armor_Dur[actor.armor1_id]
                  gain_item($data_armors[$data_armors_dur[id][0]],1) if DONT_DISCARD
                else
                  gain_item($data_armors[$data_armors_dur[item.base_dur][0]],1) if DONT_DISCARD
                end
                actor.armor1_id = 0
              elsif item.durability == Armor_Dur[actor.armor1_id]
                actor.armor1_id = $data_armors_dur[id][dura]
              else
                actor.armor1_id = $data_armors_dur[item.base_dur][dura]
              end
            end
          end
        end
        if actor.armor2_id != 0 and (Armor_Dur[actor.armor2_id] != nil or ($data_armors[actor.armor2_id].base_dur != 0 and $data_armors[actor.armor2_id].base_dur != nil))
          if region == 5 or region == 2
            item = $data_armors[actor.armor2_id]
            id = actor.armor2_id
            dura = item.durability - 1
            if dura == 0
              if item.durability == Armor_Dur[actor.armor2_id]
                gain_item($data_armors[$data_armors_dur[id][0]],1) if DONT_DISCARD
              else
                gain_item($data_armors[$data_armors_dur[item.base_dur][0]],1) if DONT_DISCARD
              end
              actor.armor2_id = 0
            elsif item.durability == Armor_Dur[actor.armor2_id]
              actor.armor2_id = $data_armors_dur[id][dura]
            else
              actor.armor2_id = $data_armors_dur[item.base_dur][dura]
            end
          end
        end
        if actor.armor3_id != 0 and (Armor_Dur[actor.armor3_id] != nil or ($data_armors[actor.armor3_id].base_dur != 0 and $data_armors[actor.armor3_id].base_dur != nil))
          if region == 5 or region == 3
            item = $data_armors[actor.armor3_id]
            id = actor.armor3_id
            dura = item.durability - 1
            if dura == 0
              if item.durability == Armor_Dur[actor.armor3_id]
                gain_item($data_armors[$data_armors_dur[id][0]],1) if DONT_DISCARD
              else
                gain_item($data_armors[$data_armors_dur[item.base_dur][0]],1) if DONT_DISCARD
              end
              actor.armor3_id = 0
            elsif item.durability == Armor_Dur[actor.armor3_id]
              actor.armor3_id = $data_armors_dur[id][dura]
            else
              actor.armor3_id = $data_armors_dur[item.base_dur][dura]
            end
          end
        end
        if actor.armor4_id != 0 and (Armor_Dur[actor.armor4_id] != nil or ($data_armors[actor.armor4_id].base_dur != 0 and $data_armors[actor.armor4_id].base_dur != nil))
          if region == 5 or region == 4
            item = $data_armors[actor.armor4_id]
            id = actor.armor4_id
            dura = item.durability - 1
            if dura == 0
              if item.durability == Armor_Dur[actor.armor4_id]
                gain_item($data_armors[$data_armors_dur[id][0]],1) if DONT_DISCARD
              else
                gain_item($data_armors[$data_armors_dur[item.base_dur][0]],1) if DONT_DISCARD
              end
              actor.armor4_id = 0
            elsif item.durability == Armor_Dur[actor.armor4_id]
              actor.armor4_id = $data_armors_dur[id][dura]
            else
              actor.armor4_id = $data_armors_dur[item.base_dur][dura]
            end
          end
        end
      end
    end
  end
 
  def break_all_durability
    for item in items
      if !item.nil?
        if item.is_a?(RPG::Weapon) and (Weapon_Dur[item.id] != nil or (item.base_dur != 0 and item.base_dur != nil))
          numb = item_number(item)
          if DONT_DISCARD
            if Weapon_Dur[item.id] != nil
              gain_item($data_weapons[$data_weapons_dur[item.id][0]],numb)
            else
              gain_item($data_weapons[$data_weapons_dur[item.base_dur][0]],numb)
            end
          end
          gain_item(item,-numb)
        elsif item.is_a?(RPG::Armor) and (Armor_Dur[item.id] != nil or (item.base_dur != 0 and item.base_dur != nil))
          if DONT_DISCARD
            if Armor_Dur[item.id] != nil
              gain_item($data_armors[$data_armors_dur[item.id][0]],numb)         
            else
              gain_item($data_armors[$data_armors_dur[item.base_dur][0]],numb)
            end
          end
          gain_item(item,-numb)
        end       
      end     
    end
    for actor in members
      if actor.weapon_id != 0 and (Weapon_Dur[actor.weapon_id] != nil or ($data_weapons[actor.weapon_id].base_dur != 0 and $data_weapons[actor.weapon_id].base_dur != nil))
        item = $data_weapons[actor.weapon_id]
        if item.durability == Weapon_Dur[actor.weapon_id]
          gain_item($data_weapons[$data_weapons_dur[item.id][0]],1) if DONT_DISCARD
        else
          gain_item($data_weapons[$data_weapons_dur[item.base_dur][0]],1) if DONT_DISCARD
        end
        actor.weapon_id = 0
      end
      if actor.two_swords_style
        if actor.armor1_id != 0 and (Weapon_Dur[actor.armor1_id] != nil or ($data_weapons[actor.armor1_id].base_dur != 0 and $data_weapons[actor.armor1_id].base_dur != nil))
          item = $data_weapons[actor.armor1_id]
          if item.durability == Weapon_Dur[actor.armor1_id]
            gain_item($data_weapons[$data_weapons_dur[item.id][0]],1) if DONT_DISCARD
          else
            gain_item($data_weapons[$data_weapons_dur[item.base_dur][0]],1) if DONT_DISCARD
          end
          actor.armor1_id = 0
        end
      else
        if actor.armor1_id != 0 and (Armor_Dur[actor.armor1_id] != nil or ($data_armors[actor.armor1_id].base_dur != 0 and $data_armors[actor.armor1_id].base_dur != nil))
          item = $data_armors[actor.armor1_id]
          if item.durability == Armor_Dur[actor.armor1_id]
            gain_item($data_armors[$data_armors_dur[item.id][0]],1) if DONT_DISCARD
          else
            gain_item($data_armors[$data_armors_dur[item.base_dur][0]],1) if DONT_DISCARD
          end
          actor.armor1_id = 0
        end
      end
      if actor.armor2_id != 0 and (Armor_Dur[actor.armor2_id] != nil or ($data_armors[actor.armor2_id].base_dur != 0 and $data_armors[actor.armor2_id].base_dur != nil))
        item = $data_armors[actor.armor2_id]
        if item.durability == Armor_Dur[actor.armor2_id]
          gain_item($data_armors[$data_armors_dur[item.id][0]],1) if DONT_DISCARD
        else
          gain_item($data_armors[$data_armors_dur[item.base_dur][0]],1) if DONT_DISCARD
        end
        actor.armor2_id = 0
      end
      if actor.armor3_id != 0 and (Armor_Dur[actor.armor3_id] != nil or ($data_armors[actor.armor3_id].base_dur != 0 and $data_armors[actor.armor3_id].base_dur != nil))
        item = $data_armors[actor.armor3_id]
        if item.durability == Armor_Dur[actor.armor3_id]
          gain_item($data_armors[$data_armors_dur[item.id][0]],1) if DONT_DISCARD
        else
          gain_item($data_armors[$data_armors_dur[item.base_dur][0]],1) if DONT_DISCARD
        end
        actor.armor3_id = 0
      end
      if actor.armor4_id != 0 and (Armor_Dur[actor.armor4_id] != nil or ($data_armors[actor.armor4_id].base_dur != 0 and $data_armors[actor.armor4_id].base_dur != nil))
        item = $data_armors[actor.armor4_id]
        if item.durability == Armor_Dur[actor.armor4_id]
          gain_item($data_armors[$data_armors_dur[item.id][0]],1) if DONT_DISCARD
        else
          gain_item($data_armors[$data_armors_dur[item.base_dur][0]],1) if DONT_DISCARD
        end
        actor.armor4_id = 0
      end         
    end
  end
 
  def decrease_all_durability   
    for item in items
      if !item.nil?
        if item.is_a?(RPG::Weapon) and (Weapon_Dur[item.id] != nil or (item.base_dur != 0 and item.base_dur != nil))
          numb = item_number(item)
          dura = item.durability - 1
          if Weapon_Dur[item.id] != nil
            gain_item($data_weapons[$data_weapons_dur[item.id][dura]],numb)         
          else
            gain_item($data_weapons[$data_weapons_dur[item.base_dur][dura]],numb)
          end
          gain_item(item,-numb)
        elsif item.is_a?(RPG::Armor) and (Armor_Dur[item.id] != nil or (item.base_dur != 0 and item.base_dur != nil))
          numb = item_number(item)
          dura = item.durability - 1
          if Armor_Dur[item.id] != nil
            gain_item($data_armors[$data_armors_dur[item.id][dura]],numb)         
          else
            gain_item($data_armors[$data_armors_dur[item.base_dur][dura]],numb)
          end     
          gain_item(item,-numb)
        end     
      end
    end
    decrease_durability
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
              if weapon != nil and weapon.base_dur != nil and weapon.base_dur == $data_weapons[@params[3]].id
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
              if armor != nil and armor.base_dur != nil and armor.base_dur == $data_armors[@params[3]].id
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
    @branch[@indent] = result    # Store determination results in hash
    if @branch[@indent] == true
      @branch.delete(@indent)
      return true
    end
    return command_skip
  end
end

class Window_Base < Window
  include Dhoom::Durability
  def draw_item_name(item, x, y, enabled = true)
    if item != nil
      if item.is_a?(RPG::Weapon) or item.is_a?(RPG::Armor)
        if item.durability != nil
          draw_icon(item.icon_index, x, y, enabled)
          self.contents.font.color = normal_color
          self.contents.font.color.alpha = enabled ? 255 : 128
          if item.durability == 0
            self.contents.font.color = BROKEN_ITEM_TEXT_COLOR
            self.contents.font.color.alpha = enabled ? 255 : 128
          end
          self.contents.draw_text(x + 24, y, 172, WLH, item.name)
        else
          draw_icon(item.icon_index, x, y, enabled)
          self.contents.font.color = normal_color
          self.contents.font.color.alpha = enabled ? 255 : 128
          self.contents.draw_text(x + 24, y, 172, WLH, item.name)
        end
      else
        draw_icon(item.icon_index, x, y, enabled)
        self.contents.font.color = normal_color
        self.contents.font.color.alpha = enabled ? 255 : 128
        self.contents.draw_text(x + 24, y, 172, WLH, item.name)
      end
    end
  end
end

class Scene_Title < Scene_Base
  include Dhoom::Durability
 
  alias dhoom_dura_load_database load_database 
  def load_database
    dhoom_dura_load_database
    for weapon in $data_weapons
      if Weapon_Dur[weapon.id] != nil
        weapon.create_durability
      end
    end
    for armor in $data_armors
      if Armor_Dur[armor.id] != nil
        armor.create_durability
      end
    end
  end
 
  alias dhoom_dura_load_bt_database load_bt_database
  def load_bt_database
    dhoom_dura_load_bt_database
    for weapon in $data_weapons
      if Weapon_Dur[weapon.id] != nil
        weapon.create_durability
      end
    end
    for armor in $data_armors
      if Armor_Dur[armor.id] != nil
        armor.create_durability
      end
    end
  end
end

class Scene_Battle < Scene_Base
 
  alias dhoom_battle_end battle_end 
  def battle_end(result)   
    $game_party.decrease_durability
    dhoom_battle_end(result)
  end
end

class Window_FixShopStatus < Window_Base
 
  include Dhoom::Durability

  def initialize(x, y)
    super(x, y, 240, 304)
    @item = nil
    refresh
  end

  def refresh
    self.contents.clear
    if @item != nil
      for actor in $game_party.members
        x = 4
        y = WLH * (actor.index * 2)
        draw_actor_parameter_change(actor, x, y)
      end
    end
  end

  def draw_actor_parameter_change(actor, x, y)
    return if @item.is_a?(RPG::Item)
    enabled = actor.equippable?(@item)
    self.contents.font.color = normal_color
    self.contents.font.color.alpha = enabled ? 255 : 128
    self.contents.draw_text(x, y, 200, WLH, actor.name)
    if @item.is_a?(RPG::Weapon)
      item1 = weaker_weapon(actor)
    elsif actor.two_swords_style and @item.kind == 0
      item1 = nil
    else
      item1 = actor.equips[1 + @item.kind]
    end
    if enabled
      if @item.is_a?(RPG::Weapon)
        atk1 = item1 == nil ? 0 : item1.atk
        atk2 = @item == nil ? 0 : @item.atk
        change = atk2 - atk1
      else
        def1 = item1 == nil ? 0 : item1.def
        def2 = @item == nil ? 0 : @item.def
        change = def2 - def1
      end
      self.contents.draw_text(x, y, 200, WLH, sprintf("%+d", change), 2)
    end
    draw_item_name(item1, x, y + WLH, enabled)
  end

  def weaker_weapon(actor)
    if actor.two_swords_style
      weapon1 = actor.weapons[0]
      weapon2 = actor.weapons[1]
      if weapon1 == nil or weapon2 == nil
        return nil
      elsif weapon1.atk < weapon2.atk
        return weapon1
      else
        return weapon2
      end
    else
      return actor.weapons[0]
    end
  end

  def item=(item)
    if @item != item
      @item = item
      refresh
    end
  end
end

class Window_FixShop < Window_Selectable
 
  include Dhoom::Durability
 
  def initialize(x, y)
    super(x, y, 304, 304)   
    refresh
    self.index = 0
  end
 
  def item
    return @shop_goods[self.index]
  end
 
  def refresh
    @shop_goods = []
    for item in $game_party.items
      if !item.is_a?(RPG::Item) and item.durability != nil and item.durability == 0
        @shop_goods.push(item)
      end
    end
    @item_max = @shop_goods.size
    create_contents
    for i in 0...@item_max
      draw_item(i)
    end
  end
 
  def draw_item(index)
    item = @shop_goods[index]
    number = $game_party.item_number(item)
    enabled = (item.fix_price <= $game_party.gold and number < 99)
    rect = item_rect(index)
    self.contents.clear_rect(rect)
    draw_item_name(item, rect.x, rect.y, enabled)
    rect.width -= 4
    self.contents.draw_text(rect, item.fix_price, 2)
  end
 
  def update_help
    @help_window.set_text(item == nil ? "" : item.description)
  end
end

class Scene_FixShop < Scene_Base
 
  include Dhoom::Durability
 
  def start
    super
    create_menu_background
    create_command_window
    @help_window = Window_Help.new
    @gold_window = Window_Gold.new(384, 56)
    @dummy_window = Window_Base.new(0, 112, 544, 304)
    @fix_window = Window_FixShop.new(0, 112)
    @fix_window.active = false
    @fix_window.visible = false
    @fix_window.help_window = @help_window   
    @status_window = Window_FixShopStatus.new(304, 112)
    @status_window.visible = false
    @confirm_window = Window_Command.new(96, ["Yes","No"], 1)
    @confirm_window.x = 224
    @confirm_window.y = 160
    @confirm_window.active = false
    @confirm_window.visible = false
  end

  def terminate
    super
    dispose_menu_background
    dispose_command_window
    @help_window.dispose
    @gold_window.dispose
    @dummy_window.dispose
    @fix_window.dispose
    @confirm_window.dispose
    @status_window.dispose
  end

  def update
    super
    update_menu_background
    @help_window.update
    @command_window.update
    @gold_window.update
    @dummy_window.update
    @fix_window.update
    @confirm_window.update
    @status_window.update
    if @command_window.active
      update_command_selection
    elsif @fix_window.active
      update_buy_selection
    elsif @confirm_window.active
      update_number_input
    end
  end

  def create_command_window
    s1 = Voc_Command1
    s2 = Voc_Command2
    @command_window = Window_Command.new(384, [s1, s2], 2)
    @command_window.y = 56
  end

  def dispose_command_window
    @command_window.dispose
  end

  def update_command_selection
    if Input.trigger?(Input::B)
      Sound.play_cancel
      $scene = Scene_Map.new
    elsif Input.trigger?(Input::C)
      case @command_window.index
      when 0  # Fix
        Sound.play_decision
        @command_window.active = false
        @dummy_window.visible = false
        @fix_window.active = true
        @fix_window.visible = true
        @fix_window.refresh
        @status_window.visible = true
      when 1  # Quit
        Sound.play_decision
        $scene = Scene_Map.new
      end
    end
  end

  def update_buy_selection
    @status_window.item = @fix_window.item
    if Input.trigger?(Input::B)
      Sound.play_cancel
      @command_window.active = true
      @dummy_window.visible = true
      @fix_window.active = false
      @fix_window.visible = false
      @status_window.visible = false
      @status_window.item = nil
      @help_window.set_text("")
      return
    end
    if Input.trigger?(Input::C)
      @item = @fix_window.item
      number = $game_party.item_number(@item)
      price =
      if @item == nil or @item.fix_price > $game_party.gold or number == 99
        Sound.play_buzzer
      else
        Sound.play_decision
        @fix_window.active = false
        @confirm_window.active = true
        @confirm_window.visible = true
        @help_window.set_text(Confirm_Text, 1)
      end
    end
  end

  def update_number_input
    if Input.trigger?(Input::B)
      cancel_confirm
    elsif Input.trigger?(Input::C)
      case @confirm_window.index
      when 0
        decide_confirm
      when 1
        cancel_confirm
      end
    end
  end

  def cancel_confirm
    Sound.play_cancel
    @confirm_window.active = false
    @confirm_window.visible = false
    @fix_window.active = true
    @fix_window.visible = true
  end

  def decide_confirm
    Sound.play_shop
    @confirm_window.active = false
    @confirm_window.visible = false
    $game_party.lose_gold(@item.fix_price)
    fix_durability
    @gold_window.refresh
    @fix_window.refresh
    @status_window.refresh
    @fix_window.active = true
    @fix_window.visible = true
  end
 
  def fix_durability
    if @item.is_a?(RPG::Weapon)     
      $game_party.gain_item($data_weapons[@item.base_dur],1)
    else
      $game_party.gain_item($data_armors[@item.base_dur],1)
    end
    $game_party.gain_item(@item, -1)
  end
end
