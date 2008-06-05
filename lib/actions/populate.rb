module Lilu
  class Populate < Action
    def method_missing(sym,*args)
      send :for, sym, *args
    end

    def for(method,data,&block)
      renderer.scope.reset_evenness!
      return element.collect {|e| self.element = e ; renderer.scope.instance_eval { action.for(method,data,&block) } } if element.is_a?(Hpricot::Elements)
      
      element.cache_search = true
      update_action = Update.new(element,renderer)
      parent = element.parent
      element_html = element.to_html
      data.send(method) do |*objects| 
        update_action.element = element
        update_action.with( block ? block.call(*objects) : objects )

        parent.insert_before(Hpricot.make(element.to_html),element) 
        element = Hpricot.make(element_html)
      end
      renderer.action = self 

      Hpricot::Elements[element].remove
    end
  end
end
