module Lilu
  class Remove < Action
    def initialize(*args)
      super(*args)
      return element.remove if element.is_a?(Hpricot::Elements)
      Hpricot::Elements[element].remove
    end
  end
end
