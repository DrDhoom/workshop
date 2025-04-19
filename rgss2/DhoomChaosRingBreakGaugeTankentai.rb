#===============================================================================
#-----------------------=�€� Break Gauge Chaos Ring �€�=----------------------------
#---------------------------=�€� by: DrDhoom �€�=-----------------------------------
# Version: 1.1a (Tankentai Ver.)
# Date Published: 04 - 03 - 2012
# Battle Addon
# RRR Community (Requested by Raisuki)
#-------------------------------------------------------------------------------
# Changelog:
# v1.1 04/03/2012
#  �€� Player Party or Enemy Troop not taking damage doesn't added bar, FIXED
# v1.1a 11/04/2012
#  �€� Fixed bug when using skill
#-------------------------------------------------------------------------------
# How to use:
#  - Insert this script above Main 
#===============================================================================

module Dhoom
  module BreakGaugeChaos
   #Calculation Setting
   
   #-Player-
   #1. The player attacks first at the start of the battle, gauge changes from "Even" to "Player"
   #2. The player's first strike is a critical hit, gauge changes from "Even" to "Player"
   #3. Player's first strike is a critical hit and defeats the enemy, gauge changes from "Even" to "Player"
   #4. Player defeats an enemy on any other turn
   #5. Player makes it through the enemy's turn without taking damage
   #6. Player is attacked by an enemy while the gauge is at "Player"
   #7. A party member is defeated by an enemy while the gauge is at "Player"

   #~Enemy-
   #1. The enemy attacks first at the start of the battle, gauge changes from "Even" to "Enemy"
   #2. The enemy's first strike is a critical hit, gauge changes from "Even" to "Enemy"
   #3. Enemy's first strike is a critical hit and defeats the enemy, gauge changes from "Even" to "Enemy"
   #4. Enemy defeats an party member on any other turn
   #5. Enemies makes it through the player's turn without taking damage
   #6. Enemy is attacked by an party member while the gauge is at "Enemy"
   #7. An enemy is defeated by an party member while the gauge is at "Enemy"

   #-Other-
   #1. All bars are depleted from either "Player" or "Enemy", added to the opposing side
   #2. A skill is used that specifically drains bars from the opposing favor but normal damage otherwise (E.G. Player uses skill during a time when the gauge is displayed as "Enemy"), added to the opposing favor
   
   #How much amount added to bar based on specified actions
   CALC_BAR_PLAYER = [4,5,7,1,1,-1,-4]
   CALC_BAR_ENEMY = [4,5,7,1,1,-1,-4]
   CALC_BAR_OTHER = [4,-2]
   
   #State ID to added to Player or Enemy states based on Gauge Side
   STAT_ID = 17
   
   #Display Setting
   CIRCLE_COOR = [6, 6]
   BREAK_COOR = [0,0]
   BREAK_ME = "Victory1"
  end
end

class Sprite_BreakGauge
 
  include Dhoom::BreakGaugeChaos
 
  attr_accessor :x
  attr_accessor :y
  attr_accessor :bar
  attr_accessor :way
 
  def initialize(x, y)
   @x = x
   @y = y   
   @bar = 0
   @way = 0
   @tmp_x = x
   @tmp_y = y
   @tmp_bar = 0
   @tmp_way = 0
   @next = 0
   create_graphics
  end
 
  def create_graphics
   @barspr = Sprite.new
   @circle = Sprite.new
   @circle.bitmap = Cache.system("chaos_circle")
   @text = Sprite.new
   @text.bitmap = Cache.system("chaos_even")
   @barspr.x = @x
   @barspr.y = @y
   @circle.x = @x
   @circle.y = @y
   @text.x = @x
   @text.y = @y
   @break = Sprite.new
   @break.bitmap = Cache.system("chaos_break")
   @break.opacity = 0   
   @break.ox = @break.width/2
   @break.oy = @break.height/2
   @break.x = BREAK_COOR[0]+@break.ox
   @break.y = BREAK_COOR[1]+@break.oy
  end
 
  def update
   return if break?
   if @bar > 8
     @bar = 8
   elsif @bar < -8
     @bar = -8
   end   
   if (@bar > 0 and @way == 2)
     @next = 1
   elsif (@bar < 0 and @way == 1)
     @next = 2
   end
   if @bar == 0
     if @way == 1
      @next = 2
      @me = RPG::ME.new(BREAK_ME, 100, 100)
      @me.play
     elsif @way == 2
      @next = 1 
      @me = RPG::ME.new(BREAK_ME, 100, 100)
      @me.play
     end
     @way = 0 
     @time1 = 240
     @time2 = 120    
   end
   update_graphics if something_changed?
  end
 
  def update_break   
   if @time1 > 0
     @break.opacity += 2
     @break.angle += 6 if @time1 > 120
     @time1 -= 1
   elsif @time2 > 0
     @break.opacity -= 3
     @time2 -= 1
   else
     if @next == 1
      @text.bitmap = Cache.system("chaos_even")
      @bar = CALC_BAR_OTHER[0]
      @way = 1
      @next = 0
     elsif @next == 2
      @text.bitmap = Cache.system("chaos_even")
      @bar = -(CALC_BAR_OTHER[0])
      @way = 2
      @next = 0
     end
     update
   end
  end
 
  def break?
   return true if @next != 0
   return false
  end
 
  def dispose
   @barspr.dispose
   @text.dispose
   @circle.dispose
  end
 
  def something_changed?
   return true if @x != @tmp_x || @y != @tmp_y || @bar != @tmp_bar || @way != @tmp_way
   return false
  end
 
  def update_graphics
   if @bar != 0
     @barspr.bitmap = Cache.system("chaos_"+@bar.to_s)
   else
     @barspr.bitmap = Bitmap.new(74,74)
   end
   case @way
   when 0
     @text.bitmap = Cache.system("chaos_even")
   when 1
     @text.bitmap = Cache.system("chaos_player")
   when 2
     @text.bitmap = Cache.system("chaos_enemy")
   end
   @barspr.x = @x
   @barspr.y = @y
   @circle.x = @x
   @circle.y = @y
   @text.x = @x
   @text.y = @y
   @tmp_x = @x
   @tmp_y = @y
   @tmp_bar = @bar
   @tmp_way = @way
  end
end

class Scene_Battle < Scene_Base
 
  include Dhoom::BreakGaugeChaos
 
  alias dhoom_battle_update_break update
  alias dhoom_battle_crt_inf_viewport create_info_viewport
  alias dhoom_battle_disp_inf_viewport dispose_info_viewport
  alias dhoom_battle_turn_end turn_end
 
  def update   
   super   
   if @break_gauge.break?
     @break_gauge.update_break
     update_basic(true)
     update_info_viewport
     return
   else
     @break_gauge.update
   end
   for actor in $game_party.members
     if @break_gauge.way == 1
      actor.add_state(STAT_ID)
     else
      actor.remove_state(STAT_ID)
     end
   end
   for enemy in $game_troop.members
     if @break_gauge.way == 2
      enemy.add_state(STAT_ID)
     else
      enemy.remove_state(STAT_ID)
     end
   end
   dhoom_battle_update_break
  end
 
  def create_info_viewport
   dhoom_battle_crt_inf_viewport
   @break_gauge = Sprite_BreakGauge.new(CIRCLE_COOR[0], CIRCLE_COOR[1])
   @turn = 1
   @no_dmg_player = 0
   @no_dmg_enemy = 0
   @first_strike = true
  end
   
  def dispose_info_viewport
   dhoom_battle_disp_inf_viewport
   @break_gauge.dispose
  end
   
  def turn_end
   @turn += 1
   check_battler
   if @no_dmg_player >= @troop_size
     @break_gauge.bar += CALC_BAR_PLAYER[4]
   end
   if @no_dmg_enemy >= @party_size
     @break_gauge.bar -= CALC_BAR_ENEMY[4]
   end
   @no_dmg_player = 0
   @no_dmg_enemy = 0
   dhoom_battle_turn_end
  end
 
  def check_battler
   @troop_size = 0
   @party_size = 0
   for actor in $game_party.members
     if !actor.dead?
      @party_size += 1
     end
   end
   for enemy in $game_troop.members
     if !enemy.dead?
      @troop_size += 1
     end
   end
  end 

  def execute_action_attack
   targets = @active_battler.action.make_targets
   if @active_battler.actor?
     if @active_battler.weapon_id == 0
      action = @active_battler.non_weapon       
      immortaling
     else 
      action = $data_weapons[@active_battler.weapon_id].base_action      
      if $data_weapons[@active_battler.weapon_id].state_set.include?(1)
        for member in $game_party.members + $game_troop.members
         next if member.immortal
         next if member.dead?
         member.dying = true
        end
      else
        immortaling
      end
     end 
   else
     if @active_battler.weapon == 0
      action = @active_battler.base_action
      immortaling
     else
      action = $data_weapons[@active_battler.weapon].base_action
      if $data_weapons[@active_battler.weapon].state_set.include?(1)
        for member in $game_party.members + $game_troop.members
         next if member.immortal
         next if member.dead?
         member.dying = true
        end
      else
        immortaling
      end
     end 
   end
   target_decision
   @spriteset.set_action(@active_battler.actor?, @active_battler.index, action)
   playing_action
   for target in targets    
     if target.actor?
      if target.hp_damage == 0 || target.missed || target.evaded
        @no_dmg_player += 1
      end
     else
      if target.hp_damage == 0 || target.missed || target.evaded
        @no_dmg_enemy += 1
      end
     end
     return if target.missed
     return if target.evaded
     return if target.hp_damage == 0
     if @first_strike
      if @active_battler.actor?
        @break_gauge.way = 1
        @first_strike = false      
        if target.critical and target.dead?
         @break_gauge.bar += CALC_BAR_PLAYER[2]
        elsif target.critical
         @break_gauge.bar += CALC_BAR_PLAYER[1]
        else
         @break_gauge.bar += CALC_BAR_PLAYER[0]
        end
      else
        @break_gauge.way = 2
        @first_strike = false
        if target.critical and target.dead?
         @break_gauge.bar -= CALC_BAR_PLAYER[2]
        elsif target.critical
         @break_gauge.bar -= CALC_BAR_PLAYER[1]
        else
         @break_gauge.bar -= CALC_BAR_PLAYER[0]
        end
      end
     else
      if @active_battler.actor?
        if target.dead?
         if @break_gauge.way == 1
           @break_gauge.bar += CALC_BAR_PLAYER[3]
         elsif @break_gauge.way == 2
           @break_gauge.bar -= CALC_BAR_ENEMY[6]
         end
        else
         if @break_gauge.way == 2
           @break_gauge.bar -= CALC_BAR_PLAYER[5]
         end
        end
      else
        if target.dead?
         if @break_gauge.way == 2
           @break_gauge.bar -= CALC_BAR_ENEMY[3]
         elsif @break_gauge.way == 1
           @break_gauge.bar += CALC_BAR_PLAYER[6]
         end
        else
         if @break_gauge.way == 1
           @break_gauge.bar += CALC_BAR_ENEMY[5]
         end
        end
      end
     end
   end   
  end
 
  def execute_action_skill
   skill = @active_battler.action.skill
   return unless @active_battler.action.valid? # 3.3d, Force action bug fix   
   if skill.plus_state_set.include?(1)
     for member in $game_party.members + $game_troop.members
      next if member.immortal
      next if member.dead?
      member.dying = true
     end
   else    
     immortaling
   end   
   target_decision(skill)   
   @spriteset.set_action(@active_battler.actor?, @active_battler.index, skill.base_action)   
   pop_help(skill)   
   playing_action
   @active_battler.mp -= @active_battler.calc_mp_cost(skill)
   @status_window.refresh   
   $game_temp.common_event_id = skill.common_event_id
   targets = @active_battler.action.make_targets
   for target in targets
     return if target.missed
     return if target.evaded
   end
   if @active_battler.actor? and @break_gauge.way == 2
     @break_gauge.bar += CALC_BAR_OTHER[1]
   elsif @break_gauge.way == 1
     @break_gauge.bar -= CALC_BAR_OTHER[1]
   end   
  end    
end
