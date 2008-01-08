unless defined?(Rails) 
  require File.dirname(__FILE__) + '/lib/lilu'
else # if Rails is loaded, register Lilu

  require File.dirname(__FILE__) + '/lib/lilu_view'

  [:lilu,'erb.html'.to_sym,:html,'html.erb'.to_sym,'rhtml'].each {|ext| ActionView::Base.register_template_handler ext, Lilu::View }
  
  

  class ActionView::Base

    def delegate_render(handler, template, local_assigns, file_path = nil) 
      _handler = handler.new(self) 
      unless file_path 
        _handler.render(template, local_assigns) 
      else 
        _handler.render(template, local_assigns, file_path) 
      end    
    end

    def render_template(template_extension, template, file_path = nil, local_assigns = {}) #:nodoc:
      if handler = @@template_handlers[template_extension] and !DEFAULT_TEMPLATE_HANDLER_PREFERENCE.collect(&:to_s).member?(template_extension)
        template ||= read_template_file(file_path, template_extension) # Make sure that a lazyily-read template is loaded.
        delegate_render(handler, template, local_assigns, file_path)
      else
        compile_and_render_template(template_extension, template, file_path, local_assigns)
      end
    end

  end


end