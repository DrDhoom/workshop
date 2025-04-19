#===============================================================================
#------------------------- -=• Music Player •=----------------------------------
#---------------------------=• by: DrDhoom •=-----------------------------------
# Version: 1.0
# Date Published: 13 - 06 - 2011
# RPGMakerID Community
#-------------------------------------------------------------------------------
# Introduction:
# Like the name, this script for choose and play BGM music.
#-------------------------------------------------------------------------------
# How to use:
#  - Insert this script above Main 
#===============================================================================

module DHOOM
  module MSPR 
   
    #return to scene when closed. EG: Scene_Menu, Scene_Title,etc
    RETURN_SCENE = Scene_Map
   
    #Window Properties------------------------------------------|
    WINDOW_PLAY_WIDTH = 320
    WINDOW_PLAY_ANIM = true #when true, the text will animation
    WINDOW_PLAY_OPACITY = 255
    NP_TEXT = "Now Playing: "
   
    WINDOW_MUSC_WIDTH = 320
    WINDOW_MUSC_HEIGHT = nil #This will be auto if nil
    WINDOW_MUSC_OPACITY = 255
   
    STOP_INPUT = Input::A #Button to stop BGM. See game properties (F1)
                          #for the button
                         
    BACKGROUND = "" #Leave empty if you don't want to change Background
                    #the background image must be in "Graphics/Pictures/" folder
    BACKGROUND_X = 0
    BACKGROUND_Y = 0
    BACKGROUND_OPACITY = 255
    #-----------------------------------------------------------|
   
    MUSICS = [] #<--- Don't delete this line
   
    #MUSICS[id] = ["bgm filename"]
    MUSICS[1] = ["Battle1","Theme1","Scene5"]
   
    MUSICS[2] = ["Battle3","Theme1","Scene4","Scene1","Battle3",
    "Battle3","Battle3","Battle3","Battle3","Battle3","Battle3",
    "Scene1","Scene1","Scene1","Scene1","Scene1","Scene1","Scene1"]
   
    #TO CALL THE SCENE:
    # Scene_MPlayer.new(MUSICS id)
   
  end
end

module RPG
  class BGM < AudioFile
    def self.player_play(name)
      if name.empty?
        Audio.bgm_stop
        @p_last = "None"
      else
        Audio.bgm_play("Audio/BGM/" + name)
        @p_last = name
      end
    end
    def self.p_last
      return @p_last if @p_last != nil
      return "None"
    end
  end
end

class Window_MPlayer < Window_Base
  include DHOOM::MSPR
  def initialize
    super(0,0,WINDOW_PLAY_WIDTH,56)
    self.contents = Bitmap.new(width - 32, height - 32)
    self.ox = 0
    refresh
  end
 
  def refresh
    self.contents.clear
    self.contents.draw_text(0, 0, 384, WLH, NP_TEXT + RPG::BGM.p_last)
    a = RPG::BGM.p_last.size
    if a <= 100
      @speed = 3
    elsif a <= 250
      @speed = 2.5
    elsif a <= 400
      @speed = 2
    else
      @speed = 1
    end
  end
 
  def update
    if WINDOW_PLAY_ANIM
      self.ox += @speed
      if self.ox >= 544
        self.ox = -544
      end
    end
  end
end


class Scene_MPlayer < Scene_Base
  include DHOOM::MSPR
  def initialize(music)
    @music = music
  end
 
  def start
    super
    if !BACKGROUND.empty?
      @bg = Sprite.new
      @bg.bitmap = Cache.picture(BACKGROUND)
      @bg.x = BACKGROUND_X
      @bg.y = BACKGROUND_Y
      @bg.opacity = BACKGROUND_OPACITY
    else
      create_menu_background
    end
    @music_window = Window_Command.new(WINDOW_MUSC_WIDTH, MUSICS[@music])
    @music_window.visible = true
    @music_window2 = Window_MPlayer.new
    @music_window.x = (544 - @music_window.width) / 2
    @music_window2.x = (544 - @music_window2.width) / 2
    @music_window.y = @music_window2.height
    if WINDOW_MUSC_HEIGHT != nil
      @music_window.height = WINDOW_MUSC_HEIGHT
    end
    a = 416 - @music_window.y
    if @music_window.height > a
      @music_window.height = a
    end
    if $last_mp_index != nil and $last_mp_index[@music] != nil
      @music_window.index = $last_mp_index[@music]
    end
    @music_window.opacity = WINDOW_MUSC_OPACITY
    @music_window2.opacity = WINDOW_PLAY_OPACITY   
  end
 
  def update
    super
    @music_window.update
    @music_window2.update
    if !@bg.nil? 
      @bg.update
    else
      update_menu_background
    end
    update_window
  end
 
  def update_window
    if Input.trigger?(Input::B)
      Sound.play_cancel
      $scene = RETURN_SCENE.new
    elsif Input.trigger?(Input::C)
      Sound.play_decision
      RPG::BGM.player_play(MUSICS[@music][@music_window.index])
      $last_mp_index = []
      $last_mp_index[@music] = @music_window.index
      @music_window2.refresh
    elsif Input.trigger?(STOP_INPUT)
      Sound.play_decision
      RPG::BGM.player_play("")
      @music_window2.refresh
    end
  end
 
  def terminate
    super
    @music_window.dispose
    @music_window2.dispose
    if !@bg.nil?
      @bg.dispose
    else
      dispose_menu_background
    end
  end
end
