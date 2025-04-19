#==============================================================================
# HUD Selection v.1.0 for Vampyr SBABS by DrDhoom
#------------------------------------------------------------------------------
#  Script untuk menambah menu option untuk mengganti HUD.
#------------------------------------------------------------------------------
#  Untuk menjalankan script ini membutuhkan Vampyr HUD v1.1
#------------------------------------------------------------------------------
#Pemasangan:
#  Taruh di atas Main dan dibawah script Vampyr.
#  Edit Scene_Menu untuk memasukkan script ini ke menu
#  Pada def create_command_window
#def create_command_window
#    s1 = Vocab::item
#    s2 = Vocab::skill
#    s3 = Vocab::equip
#    s4 = Vocab::status
#    s5 = Vocab::save
#    s6 = "HUD Selection"
#    s7 = Vocab::game_end
#    @command_window = Window_Command.new(160, [s1, s2, s3, s4, s5, s6, s7])
#
#  Lalu pada def update_command_selection edit jadi seperti ini
#      when 0      # Item
#        $scene = Scene_Item.new
#      when 1,2,3  # Skill, equipment, status
#        start_actor_selection
#      when 4      # Save
#        $scene = Scene_File.new(true, false, false)
#      when 5      #HUD Selection
#        $scene = Scene_HUD_Select.new
#      when 6      # End Game
#        $scene = Scene_End.new
#
#Kamu bisa mengganti HUD lewat event dengan call script seperti ini:
#    $HUD_Selection_Ammo = HUD_Ammo1    #ganti jadi HUD_Ammo1, HUD_Ammo2, ...5
#    $HUD_Selection_Skill = HUD_Skill1      #ganti jadi HUD_Skill1, HUD_Skill2, ...5
#    $HUD_Selection_Item = HUD_Item1    #ganti jadi HUD_Item1, HUD_Item2, ...5
#------------------------------------------------------------------------------
#Credit to DrDhoom
#------------------------------------------------------------------------------
#==============================================================================

module Dhoom_HUD_Selection
#Semua file graphic HUD taruh di "Graphics\System"
 
#Nama Opsi 
  HUD_Option1 = "Default"
  HUD_Option2 = "Green" 
  HUD_Option3 = "Black"
  HUD_Option4 = "Red"
  HUD_Option5 = "Purple"
 
#Nama File untuk Ammo 
  HUD_Ammo1 = "Ammos Base1"
  HUD_Ammo2 = "Ammos Base2"
  HUD_Ammo3 = "Ammos Base3"
  HUD_Ammo4 = "Ammos Base4"
  HUD_Ammo5 = "Ammos Base5"
 
#Nama File untuk Skill 
  HUD_Skill1 = "Skills Base1"
  HUD_Skill2 = "Skills Base2"
  HUD_Skill3 = "Skills Base3"
  HUD_Skill4 = "Skills Base4"
  HUD_Skill5 = "Skills Base5"
 
#Nama File untuk Item 
  HUD_Item1 = "Items Base1"
  HUD_Item2 = "Items Base2"
  HUD_Item3 = "Items Base3"
  HUD_Item4 = "Items Base4"
  HUD_Item5 = "Items Base5"
end
#==============================================================================
#End Configurations
#==============================================================================

class Scene_HUD_Select < Scene_Base
  include Dhoom_HUD_Selection
  def start
    super
    create_menu_background
    create_command_window
  end

  def post_start
    super
    open_command_window
  end

  def pre_terminate
    super
    close_command_window
  end

  def terminate
    super
    dispose_command_window
    dispose_menu_background
  end

  def return_scene
    $scene = Scene_Menu.new(6)
  end

  def update
    super
    update_menu_background
    @command_window.update
    if Input.trigger?(Input::B)
      Sound.play_cancel
      return_scene
    elsif Input.trigger?(Input::C)
      case @command_window.index
      when 0 
        command_first_hud
      when 1 
        command_second_hud
      when 2 
        command_third_hud
      when 3
        command_fourth_hud
      when 4
        command_fifth_hud
      end
    end
  end

  def update_menu_background
    super
    @menuback_sprite.tone.set(0, 0, 0, 128)
  end

  def create_command_window
    s1 = HUD_Option1
    s2 = HUD_Option2
    s3 = HUD_Option3
    s4 = HUD_Option4
    s5 = HUD_Option5
    @command_window = Window_Command.new(172, [s1, s2, s3, s4, s5])
    @command_window.x = (544 - @command_window.width) / 2
    @command_window.y = (416 - @command_window.height) / 2
    @command_window.openness = 0
  end

  def dispose_command_window
    @command_window.dispose
  end

  def open_command_window
    @command_window.open
    begin
      @command_window.update
      Graphics.update
    end until @command_window.openness == 255
  end

  def close_command_window
    @command_window.close
    begin
      @command_window.update
      Graphics.update
    end until @command_window.openness == 0
  end

  def command_first_hud
    Sound.play_decision
    $HUD_Selection_Ammo = HUD_Ammo1
    $HUD_Selection_Skill = HUD_Skill1
    $HUD_Selection_Item = HUD_Item1
    return_scene
  end

  def command_second_hud
    Sound.play_decision
    $HUD_Selection_Ammo = HUD_Ammo2
    $HUD_Selection_Skill = HUD_Skill2
    $HUD_Selection_Item = HUD_Item2
    return_scene
  end

  def command_third_hud
    Sound.play_decision
    $HUD_Selection_Ammo = HUD_Ammo3
    $HUD_Selection_Skill = HUD_Skill3
    $HUD_Selection_Item = HUD_Item3
    return_scene
  end
 
  def command_fourth_hud
    Sound.play_decision
    $HUD_Selection_Ammo = HUD_Ammo4
    $HUD_Selection_Skill = HUD_Skill4
    $HUD_Selection_Item = HUD_Item4
    return_scene
  end
 
  def command_fifth_hud
    Sound.play_decision
    $HUD_Selection_Ammo = HUD_Ammo5
    $HUD_Selection_Skill = HUD_Skill5
    $HUD_Selection_Item = HUD_Item5
    return_scene
  end
end

class Vampyr_HUD2 < Sprite
 
  def initialize(viewport)
    super(viewport)
    @bg = Cache.system($HUD_Selection_Ammo)
    self.y = Graphics.height-@bg.height-(Font_Size/2)-1
    self.bitmap = Bitmap.new(@bg.width, @bg.height+(Font_Size/2))
    self.bitmap.font.name = Font_Name
    self.bitmap.font.size = Font_Size
    refresh
  end
end

class Vampyr_HUD3 < Sprite
 
  def initialize(viewport)
    super(viewport)
    @bg = Cache.system($HUD_Selection_Skill)
    self.x = Graphics.width-@bg.width
    self.y = Graphics.height-@bg.height-(Font_Size/2)-1
    self.bitmap = Bitmap.new(@bg.width, @bg.height+(Font_Size/2))
    self.bitmap.font.name = Font_Name
    self.bitmap.font.size = Font_Size
    refresh
  end
end

class Vampyr_HUD4 < Sprite
 
  def initialize(viewport)
    super(viewport)
    @bg = Cache.system($HUD_Selection_Item)
    self.x, self.y = Graphics.width-@bg.width, 1
    self.bitmap = Bitmap.new(@bg.width, @bg.height+(Font_Size/2))
    self.bitmap.font.name = Font_Name
    self.bitmap.font.size = Font_Size
    refresh
  end
end

class Scene_Title < Scene_Base
  include Dhoom_HUD_Selection
  def start
  super
  load_database                   
  create_game_objects             
  check_continue                   
  create_title_graphic             
  create_command_window           
  play_title_music 
  $HUD_Selection_Ammo = HUD_Ammo1
  $HUD_Selection_Skill = HUD_Skill1
  $HUD_Selection_Item = HUD_Item1
  end
end
