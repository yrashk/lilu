module Lilu
  class Replace < Lilu::Action
    def with(new_element=nil,&block)
      return element.collect {|e| self.element = e ; renderer.scope.instance_eval { action.with(new_element) } } if element.is_a?(Hpricot::Elements)
      case new_element
      when String
        element.swap new_element
      when Hpricot::Elem
        Hpricot::Elements[new_element].remove
        element.parent.insert_after(new_element,element)
        Hpricot::Elements[element].remove
      when ElementRelative
        with(new_element.to_proc(element))  
      when Proc
        with(new_element.call.to_s)
      when nil
        if block_given?
          with renderer.scope.instance_eval(&block)
        else
          element.swap ""
        end
      else
        element.swap new_element.to_s
      end
    end
  end
end
