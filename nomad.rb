# Nomad: A model inspired by Monads
# Allan Bowhill (2016)
#
# Description: Minimalist IO objects linked into an executable chain. 
# Purpose: None, amusement. 
#
# rules:
#
# 1. Each Nomad has one function.
# 2. Each Nomad has one input and one output
# 3. Nomads are linked into a chain of inputs to outputs
# 4. The first Nomad in the chain gets a value assigned to input
# 5. The last Nomad in the chain has the chain's output value

# NOTE: Each Nomad recieves a function pointer passed-in during instantiation.
# If no function pointer is provided, the object becomes invisible in the 
# execution chain -- a passthrough object -- passing-through the output
# of the previous object in the chain to the next.

class Nomad

   attr_accessor :inp, :out, :attached_nomad, :function

   def initialize
      # optimization of proc based on:
      # http://mudge.name/2011/01/26/passing-blocks-in-ruby-without-block.html

      if block_given?
        @function = Proc.new
      else
        @function = Proc.new {|x| x} # passthru if no block provided
      end

      @inp = 0
      @out = 0
      @attached_nomad = nil
   end

   def run
     @out = function.call(inp)
   end

   # syntax to link one Nomad's input  to anothers output, like C++ std::cin
   def <<(a_nomad)
     @attached_nomad = a_nomad
   end

   # Nomad chain's outputs are evaluated depth-first
   def eval
      if (attached_nomad)
         @inp = attached_nomad.eval
      end
      run
      out
   end

   def assign(value)
      @inp = value
   end

end


def main
  # input object at one end of pipeline is assgned a value
  adder = Nomad.new {|a| a + 1 }
  adder.assign(20)
 
  divider = Nomad.new {|x| x / 3 } 
  
  # a passthru object has no function assigned 
  passthru = Nomad.new
 
  multiplier = Nomad.new {|a| a * 100 }

  # link objects into IO pipeline
  multiplier << divider << passthru << adder

  # each object can be eval'd independently as an output
  puts "Multiplier #{multiplier.eval}"
  puts "Divider #{divider.eval}"
  puts "Passthru #{passthru.eval}"
  puts "Adder #{adder.eval}"
end

main
