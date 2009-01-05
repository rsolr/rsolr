class Symbol
  
  # allow symbol chaining: :one.two.three
  def method_missing(m)
    [self.to_s, m.to_s].join('.').to_sym
  end
  
end

class Hash
  
  def to_mash
    self.is_a?(Mash) ? self : Mash.new(self)
  end
  
end