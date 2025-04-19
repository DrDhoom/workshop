#===============================================================================
#-------------------------=• Skills Separator •=---------------------------------
#---------------------------=• by: DrDhoom •=-----------------------------------
# Version: 1.0
# Date Published: 26 - 05 - 2011
# RPGMakerID Community
#-------------------------------------------------------------------------------
# Introduction:
# ...
#-------------------------------------------------------------------------------
# How to use:
#  - Insert this script above Main
#===============================================================================

module Dhoom
  module SKSP
 
    COLUMN_NAME = [] #<--- Don't delete this line
    COLUMN_HELP = [] #<--- Don't delete this line
    COLUMN_SKILL = [] #<--- Don't delete this line
    COLUMN_SKILLSET = [] #<--- Don't delete this line
 
    #COLUMN_NAME/HELP[actor id] = [""]
    COLUMN_NAME[1] = ["Skillset A", "Skillset B", "Skillset C", "Skillset D"]
    COLUMN_HELP[1] = ["Skillset number 1", "Skillset number 2", "Skillset number 3", "Skillset number 4"]
    COLUMN_NAME[2] = ["Fire", "Wind", "Earth", "Water", "Ice"]
    COLUMN_HELP[2] = ["Skillset number 1", "Skillset number 2", "Skillset number 3", "Skillset number 4", "Skillset number 5"]
 
    #Skill for displaying in skillset
    COLUMN_SKILL[0] = [1,2,3,4,5]
    COLUMN_SKILL[1] = [6,7,8]
    COLUMN_SKILL[2] = [9,10,11]
    COLUMN_SKILL[3] = [12,13,33]
    COLUMN_SKILL[4] = [13,23,33,43,53]
    COLUMN_SKILL[5] = [6,7,8]
    COLUMN_SKILL[6] = [9,10,11]
    COLUMN_SKILL[7] = [12,13,33]
    COLUMN_SKILL[8] = [12,13,33] 
 
    COLUMN_SKILLSET[1] = [0,1,2,3]
    COLUMN_SKILLSET[2] = [4,5,6,7,8]
     
  end
end

class Window_Skill2 < Window_Selectable
  include Dhoom::SKSP
  def initialize(x, y, width, height, actor, set)
    super(x, y, width, height)
    @actor = actor
    @set = set
    @column_max = 2
    self.index = 0
    refresh
  end
 
  def set(set)
    @set = set
  end
 
  def skill
    return @data[self.index]
  end
 
  def refresh
    @data = []
    for skill in @actor.skills
      @data.push(skill) if COLUMN_SKILL[COLUMN_SKILLSET[@actor.id][@set]].include?(skill.id)
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
    skill = @data[index]
    if skill != nil
      rect.width -= 4
      enabled = @actor.skill_can_use?(skill)
      draw_item_name(skill, rect.x, rect.y, enabled)
      self.contents.draw_text(rect, @actor.calc_mp_cost(skill), 2)
    end
  end
 
  def update_help
    @help_window.set_text(skill == nil ? "" : skill.description)
  end
end


class Scene_Skill < Scene_Base
  include Dhoom::SKSP
 
  alias dhoom_sksp_skill_update update
  alias dhoom_sksp_skill_start start
  alias dhoom_sksp_skill_terminate terminate
 
  def post_start
    super
    open_command_window
  end
 
  def start
    super
    dhoom_sksp_skill_start
    @skill_window = Window_Skill2.new(0, 112, 544, 304, @actor, 0)
    @skill_window.viewport = @viewport
    @skill_window.help_window = @help_window
    @skill_window.active = false
    @help_window.set_text(COLUMN_HELP[@actor.id][0])
    create_command_window
  end
 
  def create_command_window
    @command_window = Window_Command.new(172, COLUMN_NAME[@actor.id])
    @command_window.x = (544 - @command_window.width) / 2
    @command_window.y = (416 - @command_window.height) / 2
    @command_window.openness = 0
    @command_window.active = true
  end
 
  def update
    super
    dhoom_sksp_skill_update
    @command_window.update
    if @command_window.active and @skill_window.active == false
      update_command_window
    elsif @target_window.active
      update_target_selection
    elsif @skill_window.active
      update_skill_selection
    end
  end
 
  def terminate
    super
    dhoom_sksp_skill_terminate
    @command_window.dispose
  end
 
  def update_command_window
    unless @command_activated
      @command_activated = true
      return
    end
    if Input.trigger?(Input::B)   
      Sound.play_cancel
      close_command_window
      return_scene
    elsif Input.trigger?(Input::R)
      Sound.play_cursor
      next_actor
    elsif Input.trigger?(Input::L)
      Sound.play_cursor
      prev_actor
    elsif Input.trigger?(Input::C)
      @set = @command_window.index
      @skill_window.set(@set)
      @skill_window.refresh
      Sound.play_decision
      close_command_window
      @command_window.active = false
      @skill_window.active = true
    elsif Input.trigger?(Input::UP)
      @set = @command_window.index
      @skill_window.set(@set)
      @skill_window.refresh
      @help_window.set_text(COLUMN_HELP[@actor.id][@set])
    elsif Input.trigger?(Input::DOWN)
      @set = @command_window.index
      @skill_window.set(@set)
      @skill_window.refresh
      @help_window.set_text(COLUMN_HELP[@actor.id][@set])
    end
  end
 
  def update_skill_selection
    if Input.trigger?(Input::B)
      Sound.play_cancel     
      open_command_window
      @skill_window.active = false     
      @command_window.active = true
    elsif Input.trigger?(Input::C)
      @skill = @skill_window.skill
      if @skill != nil
        @actor.last_skill_id = @skill.id
      end
      if @actor.skill_can_use?(@skill)
        Sound.play_decision
        determine_skill
      else
        Sound.play_buzzer
      end
    end
  end
 
  def open_command_window
    @command_window.open
    begin
      @command_window.update
      Graphics.update
    end until @command_window.openness == 255
  end
 
  def close_command_window
    @command_activated = false
    @command_window.close
    begin
      @command_window.update
      Graphics.update
    end until @command_window.openness == 0
  end
end

class Scene_Battle < Scene_Base
  include Dhoom::SKSP
  alias dhoom_sksp_battle_update update
  if $imported != nil and $imported["TankentaiSideview"]
    alias dhoom_sksp_end_selection end_target_selection
  else
    alias dhoom_sksp_enemy_selection end_target_enemy_selection
    alias dhoom_sksp_actor_selection end_target_actor_selection
  end
 
  def update
    super
    update_basic(true)
    update_info_viewport               
    if $game_message.visible
      @info_viewport.visible = false
      @message_window.visible = true
    end
    unless $game_message.visible       
      return if judge_win_loss         
      update_scene_change
      if @target_enemy_window != nil
        update_target_enemy_selection 
      elsif @target_actor_window != nil
        update_target_actor_selection 
      elsif @skill_window != nil and @skill_window.active
        update_skill_selection       
      elsif @command_window != nil and @command_window.active
        update_command_window
      elsif @item_window != nil
        update_item_selection         
      elsif @party_command_window.active
        update_party_command_selection 
      elsif @actor_command_window.active
        update_actor_command_selection 
      else
        process_battle_event         
        process_action               
        process_battle_event         
      end
    end
  end
 
  def start_skill_selection
    @help_window = Window_Help.new
    @skill_window = Window_Skill2.new(0, 56, 544, 232, @active_battler, 0)
    @skill_window.active = false
    @help_window.set_text(COLUMN_HELP[@active_battler.id][0]) 
    @actor_command_window.active = false
    create_command_window
    open_command_window
    @command_window.active = true
    @last_window = true
  end
 
  def update_skill_selection
    @skill_window.active = true
    @skill_window.update
    @help_window.update
    if Input.trigger?(Input::B)
      Sound.play_cancel
      open_command_window
      @skill_window.active = false
      @set = @command_window.index
      @help_window.set_text(COLUMN_HELP[@active_battler.id][@set])
      @command_window.active = true
    elsif Input.trigger?(Input::C)
      @skill = @skill_window.skill
      if @skill != nil
        @active_battler.last_skill_id = @skill.id
      end
      if @active_battler.skill_can_use?(@skill)
        Sound.play_decision
        determine_skill
      else
        Sound.play_buzzer
      end
    end
  end
 
  def update_command_window
    @command_window.update
    @help_window.update
    @skill_window.update
    unless @command_activated
      @command_activated = true
      return
    end
    if Input.trigger?(Input::B)   
      Sound.play_cancel
      close_command_window
      @skill_window.dispose
      @skill_window = nil
      @help_window.dispose
      @help_window = nil
      @command_window.dispose
      @command_window = nil
      @last_window = false
      @actor_command_window.active = true
    elsif Input.trigger?(Input::C)
      @set = @command_window.index
      @skill_window.set(@set)
      @skill_window.refresh
      Sound.play_decision
      close_command_window
      @command_window.active = false
      @skill_window.active = true
    elsif Input.trigger?(Input::UP)
      @set = @command_window.index
      @skill_window.set(@set)
      @skill_window.refresh
      @help_window.set_text(COLUMN_HELP[@active_battler.id][@set])
    elsif Input.trigger?(Input::DOWN)
      @set = @command_window.index
      @skill_window.set(@set)
      @skill_window.refresh
      @help_window.set_text(COLUMN_HELP[@active_battler.id][@set])
    end
  end
 
  if $imported != nil and $imported["TankentaiSideview(Kaduki)"]
    def end_target_selection
      dhoom_sksp_end_selection
      if @last_window
        @skill_window.active = true if @skill_window != nil
      end
    end
  else
    def end_target_enemy_selection
      dhoom_sksp_enemy_selection
      if @last_window
        @skill_window.active = true if @skill_window != nil
      end
    end
 
    def end_target_actor_selection
      dhoom_sksp_actor_selection
      if @last_window
        @skill_window.active = true if @skill_window != nil
      end   
    end
  end
 
  def create_command_window
    @command_window = Window_Command.new(172, COLUMN_NAME[@active_battler.id])
    @command_window.x = (544 - @command_window.width) / 2
    @command_window.y = (416 - @command_window.height) / 2
    @command_window.openness = 0
    @command_window.active = true
  end
 
  def open_command_window
    @command_window.open
    begin
      @command_window.update
      Graphics.update
    end until @command_window.openness == 255
  end
 
  def close_command_window
    @command_activated = false
    @command_window.close
    begin
      @command_window.update
      Graphics.update
    end until @command_window.openness == 0
  end
end
