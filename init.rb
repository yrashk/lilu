unless defined?(Rails) 
  require File.dirname(__FILE__) + '/lib/lilu'
else # if Rails is loaded, register Lilu

  require File.dirname(__FILE__) + '/lib/lilu_view'

  ActionView::Base.register_template_handler :lilu, Lilu::View
  ActionView::Base.register_template_handler :html, Lilu::View
  
  class ActionView::Base
    def render_template_with_passing_file_path(template_extension, template, file_path = nil, local_assigns = {}) #:nodoc:
      local_assigns["___FILE_PATH___"] = file_path
      render_template_without_passing_file_path(template_extension,template,file_path,local_assigns)
    end
  
    alias_method_chain :render_template, :passing_file_path
    
    
  end

end