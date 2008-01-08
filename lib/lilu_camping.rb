if defined?(Camping) # Load Camping support if only Camping is loaded already
  module Lilu
    module Camping
      def self.for(app,path)
        app.module_eval do
          include Lilu::Camping
          @@templates = path
        end
      end

      def render(m,layout=true)
        @content_for_layout = render_lilu(m)
        render_lilu("layout") if layout
      end

      protected

      def render_lilu(m)
        Lilu::Renderer.new(IO.read("#{@@templates}/templates/#{m}.lilu"),IO.read("#{@@templates}/templates/#{m}.html"),binding).apply
      end
    end
  end
end
