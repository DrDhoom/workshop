module Dhoom
  module MoreChoice
    #How to use:
    # Create an array and then call setup_choice(Choice Array) 
    # in event script call.
    # Example:
    #   array = ["Choice 1", "Choice 2"]
    #   setup_choice(array)
    #
    # The choice window only be displayed if you call any message after 
    # the setup.
    
    #Variable ID to store choice index
    ChoiceVariableID = 1
  end
end

class Window_Choice < Window_Selectable
  def initialize(choices)
    super(0,0,32,32)
    self.contents = Bitmap.new(32, 32)
    self.back_opacity = 160
    @choices = choices
    self.x = 80
    self.y = 304-get_height
    self.width = get_width
    self.height = get_height
    @item_max = @choices.size
    @column_max = 1
    @index = 0
    self.contents = Bitmap.new(width - 32, @item_max * 32)
    refresh
  end
    
  def get_width
    w = 72
    @choices.each do |choice|
      t = self.contents.text_size(choice)
      w = t.width if w < t.width
    end
    return w+40
  end
  
  def get_height
    return @choices.size*32+32
  end
  
  def refresh
    self.contents.clear
    for i in 0...@item_max
      draw_item(i, normal_color)
    end
  end

  def draw_item(index, color)
    self.contents.font.color = color
    rect = Rect.new(4, 32 * index, self.contents.width-8, 32)
    self.contents.fill_rect(rect, Color.new(0, 0, 0, 0))
    self.contents.draw_text(rect, @choices[index])
  end
end

class Window_Message < Window_Selectable
  def refresh
    self.contents.clear
    self.contents.font.color = normal_color
    x = y = 0
    @cursor_width = 0
    # Indent if choice
    if $game_temp.choice_start == 0
      x = 8
    end
    # If waiting for a message to be displayed
    if $game_temp.message_text != nil
      text = $game_temp.message_text
      # Control text processing
      begin
        last_text = text.clone
        text.gsub!(/\\[Vv]\[([0-9]+)\]/) { $game_variables[$1.to_i] }
      end until text == last_text
      text.gsub!(/\\[Nn]\[([0-9]+)\]/) do
        $game_actors[$1.to_i] != nil ? $game_actors[$1.to_i].name : ""
      end
      # Change "\\\\" to "\000" for convenience
      text.gsub!(/\\\\/) { "\000" }
      # Change "\\C" to "\001" and "\\G" to "\002"
      text.gsub!(/\\[Cc]\[([0-9]+)\]/) { "\001[#{$1}]" }
      text.gsub!(/\\[Gg]/) { "\002" }
      # Get 1 text character in c (loop until unable to get text)
      while ((c = text.slice!(/./m)) != nil)
        # If \\
        if c == "\000"
          # Return to original text
          c = "\\"
        end
        # If \C[n]
        if c == "\001"
          # Change text color
          text.sub!(/\[([0-9]+)\]/, "")
          color = $1.to_i
          if color >= 0 and color <= 7
            self.contents.font.color = text_color(color)
          end
          # go to next text
          next
        end
        # If \G
        if c == "\002"
          # Make gold window
          if @gold_window == nil
            @gold_window = Window_Gold.new
            @gold_window.x = 560 - @gold_window.width
            if $game_temp.in_battle
              @gold_window.y = 192
            else
              @gold_window.y = self.y >= 128 ? 32 : 384
            end
            @gold_window.opacity = self.opacity
            @gold_window.back_opacity = self.back_opacity
          end
          # go to next text
          next
        end
        # If new line text
        if c == "\n"
          # Update cursor width if choice
          if y >= $game_temp.choice_start
            @cursor_width = [@cursor_width, x].max
          end
          # Add 1 to y
          y += 1
          x = 0
          # Indent if choice
          if y >= $game_temp.choice_start
            x = 8
          end
          # go to next text
          next
        end
        # Draw text
        self.contents.draw_text(4 + x, 32 * y, 40, 32, c)
        # Add x to drawn text width
        x += self.contents.text_size(c).width
      end
    end
    # If choice
    if $game_temp.choice_max > 0
      @choice_window = Window_Choice.new($game_temp.message_choice)
    end
    # If number input
    if $game_temp.num_input_variable_id > 0
      digits_max = $game_temp.num_input_digits_max
      number = $game_variables[$game_temp.num_input_variable_id]
      @input_number_window = Window_InputNumber.new(digits_max)
      @input_number_window.number = number
      @input_number_window.x = self.x + 8
      @input_number_window.y = self.y + $game_temp.num_input_start * 32
    end
  end
  
  alias dhoom_mrchoice_wndmsg_update update
  def update    
    if @choice_window != nil
      @choice_window.update
      if Input.trigger?(Input::C)
        $game_system.se_play($data_system.decision_se)
        $game_variables[Dhoom::MoreChoice::ChoiceVariableID] = @choice_window.index
        terminate_message
        return
      end      
    end  
    dhoom_mrchoice_wndmsg_update
  end
  
  alias dhoom_mrchoice_wndmsg_terminate_message terminate_message
  def terminate_message
    dhoom_mrchoice_wndmsg_terminate_message
    if @choice_window != nil
      @choice_window.dispose
      @choice_window = nil
    end
  end
end

class Game_Temp
  attr_accessor :message_choice
  alias dhoom_mrchoice_gmtemp_initialize initialize
  def initialize
    dhoom_mrchoice_gmtemp_initialize
    @message_choice = []
  end
end

class Interpreter
  def setup_choice(choices)
    $game_temp.message_choice = choices
    $game_temp.choice_max = 1
    $game_temp.choice_cancel_type = 0
  end
end
