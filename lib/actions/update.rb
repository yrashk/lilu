module Lilu
  class Update < Action

    def with(arg=nil,&block)
      return element.collect {|e| self.element = e ; renderer.scope.instance_eval { action.with(arg,&block) } } if element.is_a?(Hpricot::Elements)
      case arg
      when Hash
        arg.each_pair do |path,value|
          break if value.nil?
          value = value.to_proc(element) if value.kind_of?(ElementRelative)
          value = value.call if value.is_a?(Proc)
          case path
          when OptionalElementAt
            elem = element.at(path.path)
            if elem
              saved_element = element
              self.element = elem
              res = with(value,&block)
              self.element = saved_element
              res
            end
          when ElementAt
            elem = element.at(path.path)
            raise ElementNotFound.new(path.path) unless elem
            saved_element = element
            self.element = elem
            res = with(value,&block)
            self.element = saved_element
            res
          when Replacing
            Replace.new(path.element,renderer).with value.to_s
          when ElementText
            element._inner_html = value.to_s
          else
            case value
            when Nullify
              element.remove_attribute(path)
            when Append
              element[path] = element[path].to_s + value.attr_name
            else
              element[path] = value.to_s
            end
          end
        end
      when Proc
        with arg.call
      when ElementRelative
        with arg.to_proc(element).call
      when nil
        if block_given?
          with renderer.scope.instance_eval(&block) 
        else
          element._inner_html = ""
        end
      else  
        element._inner_html = arg.to_s
      end
    end
  end
end
