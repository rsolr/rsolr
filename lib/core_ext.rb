#class Symbol
  
  # allow symbol chaining: :one.two.three
  # This breaks Rails, probably lots of other things too :(
  #def method_missing(m)
  #  [self.to_s, m.to_s].join('.').to_sym
  #end
  
#end

class Hash
  
  def to_mash
    self.is_a?(Mash) ? self : Mash.new(self)
  end
  
end