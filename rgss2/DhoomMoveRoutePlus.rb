#------------------------------------------------------------------------------
# Move Route Plus
# By: DrDhoom
#------------------------------------------------------------------------------
# To change event's priority call script at event move_route:
#      change_priority(n)
#      n represent the new priority:
#      0 = Below Character
#      1 = Same as Character
#      2 = Above Character
#
# To change event's move_type call script at event move_route:
#      change_move_type(n)
#      n represent the new priority:
#      0 = Fixed
#      1 = Random
#      2 = Approach
#      3 = Custom
# You must fill custom move route command if you change event type to custom.
# if not, the event will stay at it place...
#------------------------------------------------------------------------------
# Credit: DrDhoom if you like
#------------------------------------------------------------------------------
# Start

class Game_Character
  def change_priority(priority)
    @priority = priority
    priority_execute
  end
 
  def priority_execute
    case @priority
    when 0
      @priority_type = 0
    when 1
      @priority_type = 1
    when 2
      @priority_type = 2
    end
  end
 
  def change_move_type(type)
    @type = type
    move_type_execute
  end
 
  def move_type_execute
    case @type
    when 0
      @move_type = 0
    when 1
      @move_type = 1
    when 2
      @move_type = 2
    when 3
      @move_type = 3
    end
  end
end
 
# End
