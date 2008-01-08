require 'hpricot'

class Hpricot::Elem
  attr_accessor :cache_search
  alias :_search :search
  def search(expr,&block)
    if @_inner_html
      self.inner_html= @_inner_html 
      @_inner_html = nil
    end
    if cache_search
      @_search ||= {}
      @_search[expr] || @_search[expr] = _search(expr,&block)
    else
      _search(expr,&block)
    end
  end

  def _inner_html=(html)
    @_inner_html = html
  end
  

  alias :_output :output
  def output(out, opts={})
    if @_inner_html
      if empty? and ElementContent[@stag.name] == :EMPTY
        @stag.output(out, opts.merge(:style => :empty))
      else
        @stag.output(out, opts)
        out << @_inner_html
        if @etag
          @etag.output(out, opts)
        elsif !opts[:preserve]
          ETag.new(@stag.name).output(out,opts)
        end
      end
    else
      _output(out,opts)
    end
  end

end