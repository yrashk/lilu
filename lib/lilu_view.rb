require File.dirname(__FILE__) + '/lilu'
module Lilu
  class View
    def initialize(view)
      @view = view
    end
    def render(template, local_assigns = {})
      file_path = local_assigns["___FILE_PATH___"]
      @view.instance_eval do
        local_assigns.merge!("content_for_layout" => @content_for_layout,"___view" => self)
      end
      
      template_extname = File.extname(file_path)
      begin
        html_file_path = file_path.gsub(template_extname,'.html') 
        html_template = IO.read(html_file_path)        
      rescue 
        erb_template = IO.read(file_path.gsub(template_extname,'.erb.html')) rescue IO.read(file_path.gsub(template_extname,'.erb')) rescue IO.read(file_path.gsub(template_extname,'.rhtml'))
        html_template = @view.render(:type => :erb, :inline => erb_template, :locals => local_assigns)
      end

      #let the error from the erb.html file bubble up
      html_template = @view.render(:type => :erb, :inline => html_template, :locals => local_assigns) if html_file_path.include?(".erb.") 

      if html_file_path.include?(".erb.")
      lilu_file_path = file_path.gsub(".erb"+template_extname,'.lilu')
      else
      lilu_file_path = file_path.gsub(template_extname,'.lilu')
      end
      lilu_template = IO.read(lilu_file_path) rescue lilu_template = ''
      @view.instance_eval do
        Lilu::Document.new(lilu_template,html_template,@assigns.merge(local_assigns)).render
      end
    end
  end
end
