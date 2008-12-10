class Symbol
  
  # allow symbol chaining: :one.two.three
  def method_missing(m)
    [self.to_s, m.to_s].join('.').to_sym
  end
  
end