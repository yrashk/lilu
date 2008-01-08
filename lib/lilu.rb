require 'rubygems'
require 'active_support'

require File.dirname(__FILE__) + '/hpricot_ext'


module Lilu

  module Version ; MAJOR, MINOR, TINY = 0, 2, 0 ; end

  class Action
    attr_accessor :element
    attr_reader :renderer
    def initialize(element,renderer)
      @element, @renderer = element, renderer
      renderer.action = self
    end

    cattr_reader :registered_actions
    def self.inherited(action)
      @@registered_actions ||= []
      @@registered_actions << action
    end
  end

  # Load actions
  Dir[File.dirname(__FILE__) + '/actions/*.rb'].each {|action| require action }

  # Helpers

  class Append
    
    attr_reader :attr_name
    
    def initialize(attr_name)
      @attr_name = attr_name
    end
      
  end
  class Replacing
    attr_reader :element
    def initialize(doc,element)
      case element
      when String
        @element = doc.at(element)
      when Hpricot::Elem, Hpricot::Elements
        @element = element
      end
    end
  end

  class ElementRelative
  end

  class SelfEmbeddedPartial < ElementRelative 
    def initialize(renderer,name,opts={})
      @renderer, @name, @opts = renderer, name, opts
    end
    def to_proc(element)
      lambda do
        additional_opts = @opts.clone
        additional_opts.merge!({ :partial => @name, :locals => { :___embedded_html___ => element.inner_html }.merge(@opts[:locals]||{}) })
        @renderer.view.instance_eval { render(additional_opts) }
      end
    end
  end
  
  class ElementAt < ElementRelative
    attr_reader :path

    class Attribute < ElementRelative

      def initialize(path,attr)
        @path, @attr = path, attr
      end

      def to_proc(element)
        lambda { element.at(@path)[@attr] }
      end
    end

    class Text < ElementRelative

      def initialize(path)
        @path = path
      end

      def to_proc(element)
        lambda { element.at(@path).inner_html }
      end

    end

    def initialize(path)
      @path = path
    end

    def to_proc(element)
      lambda { element.at(path) }
    end

    def [](attr)
      Attribute.new(path,attr)
    end

    def text
      Text.new(path)
    end
  end
  
  class OptionalElementAt < ElementAt
  end


  class ElementText ; include Singleton ; end
  class Nullify ; include Singleton ; end
  #

  class ElementNotFound < Exception
    def initialize(element)
      super("Element #{element} was not found")
    end
  end

  class Document
    attr_accessor :action, :doc
    attr_reader :instructions, :html_source, :scope, :view, :controller

    module Scope

      attr_accessor :renderer

      def self.register_action(action,method_name=nil)
        method_name ||= action.to_s.demodulize.tableize.singularize
        module_eval <<-EOL
        def #{method_name}(*path)
          renderer.doc = Hpricot(renderer.html_source) unless renderer.doc
          elem = find_elements(*path)
          path.pop if path.first == :all
          raise ElementNotFound.new(path) unless elem
          #{action}.new(elem,@renderer)
        end
        EOL
      end

      def self.register_actions(klass=Action)
        klass.registered_actions.each { |action| register_action(action) }
      end


      register_actions

      def evaluate(*args,&block)
        eval(*args) do |*name|
          name = name.first || 'layout'
          instance_variable_get("@content_for_#{name}")
        end
      end

      def action
        @renderer.action
      end

      def mockup_server_environment?
        @___mockup_layout___
      end

      def method_missing(sym,*args)
        return instance_variable_get("@#{sym}") if args.empty? and instance_variables.member?("@#{sym}")
        return @renderer.view.send(sym,*args) if @renderer.view and @renderer.view.respond_to?(sym)
        return @renderer.controller.send(sym, *args) if @renderer.controller and @renderer.controller.respond_to?(sym)
        super
      end


      # Helper for partials
      def partial(name,opts={})
        renderer.view.instance_eval { render({:partial => name}.merge(opts)) }
          # renderer.controller.instance_eval { render({:partial => name}.merge(opts)) }
      end
      
      # Helper for embedded partials
      def embedded_partial(path,name,opts={})
        additional_opts = opts
        additional_opts.merge!({ :partial => name, :locals => { :___embedded_html___ => element_at(path).inner_html }.merge(opts[:locals]||{}) })
        renderer.view.instance_eval { render(additional_opts) }
      end
      
      def self_embedded_partial(name,opts={})
        SelfEmbeddedPartial.new(renderer,name,opts)
      end
        
      # Helper for element_at
      def element_at(path) ; @renderer.doc.at(path) ; end

      # Helper for Replacing
      def replacing(element) ; Replacing.new(renderer.doc,element) ; end

      # Helper for ElementAt
      def at(element) ; ElementAt.new(element) ; end
      
      # Helper for OptionalElementAt      
      def optionally_at(element) ; OptionalElementAt.new(element) ; end
      

      # Helper for ElementText
      def text ; ElementText.instance ; end
      
      def append(attr_name) ; Append.new(attr_name) ; end

      def mapping(opts={}) ; opts ; end

      def element ; @renderer.action.element ; end
      
      def nullify ; Nullify.instance ; end

      def skip_predefined_behavior
        renderer.instance_variable_set(:@skip_predefined_behavior, true)
      end

      def reset_evenness!
        renderer.instance_variable_set(:@evenness,0)
      end

      def evenness
        returning (result=renderer.instance_variable_get(:@evenness)+1) do
          renderer.instance_variable_set(:@evenness,result)
        end
      end

      private 

      def find_elements(*path)
        path_first, path_second = path[0], path[1]
        case path_first
        when Hpricot::Elem, Hpricot::Elements
          path_first
        when :all
          raise InvalidArgument.new("if :all is specified, second argument with path should be specified as well") unless path_second
          @renderer.doc.search(path_second)
        else
          @renderer.doc.at(path_first)
        end
      end

      def inject_local_assignments(local_assignments)
        case local_assignments
        when Hash
          local_assignments.each_pair {|ivar,val| instance_variable_set(ivar.to_s.starts_with?('@') ? ivar : "@#{ivar}", val) }
        when Binding
          eval("instance_variables",local_assignments).each {|ivar| instance_variable_set(ivar, eval("instance_variable_get('#{ivar}')",local_assignments)) }
        else
          local_assignments.instance_variables.each {|ivar| instance_variable_set(ivar.to_s.starts_with?('@') ? ivar : "@#{ivar}", local_assignments.instance_variable_get(ivar)) }
        end
      end


    end


    def initialize(instructions,html_source,local_assignments={})
      @instructions = instructions
      @instrs = instructions.clone
      @instrs << "\nremove(:all,'.-for-removal-') unless @renderer.instance_variable_get(:@skip_predefined_behavior)" 
      @html_source = html_source
      @view = local_assignments["___view"] if local_assignments.is_a?(Hash)
      @view = @view.clone if @view
      if @view
        @controller = @view.instance_variable_get(:@controller) 
        @view.extend(Scope)
        @scope = @view
      else
        @scope = Object.new
        @scope.extend(Scope)
      end
      @scope.renderer = self
      @scope.send(:inject_local_assignments,local_assignments)
    end


    def render
      @scope.evaluate(@instrs) 
      @doc.to_html
    end

    # Deprecated
    # TODO: remove
    def apply
      puts "#{self.class.name}#apply is deprecated, use #render instead"
      render
    end


    protected


  end

  # Deprecated
  # TODO: remove
  Renderer = Document

end
