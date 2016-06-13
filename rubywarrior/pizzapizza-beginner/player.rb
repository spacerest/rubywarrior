class Player

  def initialize
    @health
    @previous_health = 0
    @facing = 0
    @compass = [:forward,:right,:backward,:left]
    @hit_wall = false
    @memory = Hash[:forward=>Array.new(3),:right=>Array.new(3),:backward=>Array.new(3),:left=>Array.new(3)]
  end

  def play_turn(warrior)
      @health = warrior.health
      @action = false
      @priority = 0 #wizard: 4, archer: 3, thick sludge: 2, sludge: 1, captive/nothing

      def danger
	@previous_health - @health
      end

      def is_safe?
	@previous_health <= @health		
      end

      def turn
	@compass[@facing] == :forward ? @facing = 2 : @facing = 0
      end

      def back_away(warrior)
	  warrior.walk!(@compass[@facing - 2])
      end

      def scan(warrior)
	@memory.each { |direction, array|
	  array.each_index { |space|
	      case warrior.look(direction)[space].to_s.upcase
	      when "NOTHING"
		@memory[direction][space] = 0
	      when "CAPTIVE"
		@memory[direction][space] = -1
	      when "SLUDGE"
		@memory[direction][space] = 2
	      when "THICK SLUDGE"
		@memory[direction][space] = 3
	      when "ARCHER"
		@memory[direction][space] = 4
	      when "WIZARD"
		@memory[direction][space] = 5
	      else
		@memory[direction][space] = 0 
	      end
	  }
	}
      end

      def prioritize(warrior)
	@priority = 0
	@memory.each { |direction, array|
	  if array.any? { |i| i == -1 }
	    @priority = -1
	    @facing = @compass.index(direction)
	    break
	  end
	  array.each { |i|
	    if i != nil && i > @priority && i != 0
	      @facing = @compass.index(direction)
	      @priority = i
	    elsif @priority == 0 && i < 0  
	      @facing = @compass.index(direction)
	      @priority = i 
	    elsif @priority == 0 && @hit_wall 
	      @facing = 2
	    elsif @priority == 0
	      @facing = 0
	    end
	  }
	}
	
      end
      
      def action(warrior)
	    if warrior.feel(@compass[@facing]).captive?
              warrior.rescue!(@compass[@facing])
	    elsif @health < 5 && self.is_safe? 
              warrior.rest! 
	    elsif @health < 5 
	      self.back_away(warrior)
	    elsif warrior.feel(@compass[@facing]).empty? && @priority > 0
	      warrior.shoot!(@compass[@facing])
	    elsif warrior.feel(@compass[@facing]).wall? && !@hit_wall
	      self.turn
	      @hit_wall = true
	      warrior.walk!(@compass[@facing])
	    else
	      warrior.walk!(@compass[@facing])
            end
      end
       
	  self.scan(warrior)
	  self.prioritize(warrior)
	  self.action(warrior)

           @previous_health = warrior.health 
      end

end
