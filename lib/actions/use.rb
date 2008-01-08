module Lilu
  class Use < Action
    def initialize(*args)
      super(*args)
      raise ArgumentError.new("Use action can not accept :all parameter") if element.is_a?(Hpricot::Elements)
      renderer.doc = element
    end
  end
end
