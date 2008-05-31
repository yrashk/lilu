require 'ruby-prof'
require 'erb'
require 'benchmark'
require 'ostruct'
require File.dirname(__FILE__) + '/../lib/lilu'

describe Lilu::Document do

  before(:all) do
    @blogs = []
    10.times {|n| @blogs << OpenStruct.new(:oid => n, 
      :title => "Title #{n}", 
      :text => "Here is my record ##{n}",
      :slug => "record-#{n}",
      :tags => "erb, lilu, #{n}",
      :exerpt => "Exerpt ##{n}",
      :author => "Author of record ##{n}",
      :datetime => Time.now,
      :revision => 1,
      :ip_addr => "63.76.232.39"                                                    
      )}
      @blog = @blogs.first

    end

    it "should be at least same speed as ERB when populating data" do
      @erb_template = '
      <html>
      <head>
      <title>test</title>
      </head>
      <body>
      <ul id="blogs">
      <% @blogs.each do |blog| %>
        <li id="blog-<%= blog.oid %>">
        Title: <div><%= blog.title %></div>
        Text: <div><%= blog.text %></div>
        Slug: <div><%= blog.slug %></div>
        Tags: <div><%= blog.tags %></div>
        Exerpt: <div><%= blog.exerpt %></div>
        Author: <div><%= blog.author %></div>
        When: <div><%= blog.datetime %></div>
        Rev: <div><%= blog.revision %></div>
        IP: <div><%= blog.ip_addr %></div>
        </li>
        <% end %>
        </ul>
        </body>
        </html>'
        @lilu_template = "populate('#blogs/li').for(:each,@blogs) do |blog|
        mapping :id => \"blog-\#{blog.oid.to_s}\",
        at('#title')  => blog.title,
        at('#text')   => blog.text,
        at('#slug')   => blog.slug,
        at('#tags')   => blog.tags,
        at('#exerpt')   => blog.exerpt,
        at('#author')   => blog.author,
        at('#datetime')   => blog.datetime,
        at('#rev')   => blog.rev,
        at('#ip')   => blog.ip
      end"
      @html_template = '
      <html>
      <head>
      <title>test</title>
      </head>
      <body>
      <ul id="blogs">
      <li>
      Title: <div id="title">Some Title</div>
      Text: <div id="text">Some text</div>
      Slug: <div id="slug">Some slug</div>
      Tags: <div id="tags">tag1, tag2</div>
      Exerpt: <div id="exerpt">Exerpt</div>
      Author: <div id="author">Me</div>
      When: <div id="datetime">Nov 12, 1981</div>
      Rev: <div id="rev">1</div>
      IP: <div id="ip">127.0.0.1</div>
      </li>
      </ul>
      </body>
      </html>'
      Benchmark.bm do |x|
        x.report("populate: erb") {
          1.times do |n|
            @erb = ERB.new(@erb_template).result(binding)
          end
        }

        x.report("populate: lilu") {  
          1.times do |n|
            @Document = Lilu::Document.new(@lilu_template,@html_template, { "blogs" => @blogs }).render
          end
        }

        x.report("populate: lilu/prof") {  
          RubyProf.start
          1.times do |n|
            @Document = Lilu::Document.new(@lilu_template,@html_template, { "blogs" => @blogs }).render
          end
          result = RubyProf.stop
          printer = RubyProf::GraphHtmlPrinter.new(result)
          f = File.new('populate_result.html','w')
          printer.print(f, '1')        
          f.close
        }
      end
    end

    it "should be at least same speed as ERB when updating data" do
      @erb_template = '
      <html>
      <head>
      <title>test</title>
      </head>
      <body>
      <li id="blog-<%= @blog.oid %>">
      Title: <div><%= @blog.title %></div>
      Text: <div><%= @blog.text %></div>
      Slug: <div><%= @blog.slug %></div>
      Tags: <div><%= @blog.tags %></div>
      Exerpt: <div><%= @blog.exerpt %></div>
      Author: <div><%= @blog.author %></div>
      When: <div><%= @blog.datetime %></div>
      Rev: <div><%= @blog.revision %></div>
      IP: <div><%= @blog.ip_addr %></div>
      </li>
      </ul>
      </body>
      </html>'

      @lilu_template = "update('li').with\
      :id => \"blog-\#{@blog.oid}\",
      at('#title')  => @blog.title,
      at('#text')   => @blog.text,
      at('#slug')   => @blog.slug,
      at('#tags')   => @blog.tags,
      at('#exerpt')   => @blog.exerpt,
      at('#author')   => @blog.author,
      at('#datetime')   => @blog.datetime,
      at('#rev')   => @blog.rev,
      at('#ip')   => @blog.ip
    "
    @html_template = '
    <html>
    <head>
    <title>test</title>
    </head>
    <body>
    <li>
    Title: <div id="title">Some Title</div>
    Text: <div id="text">Some text</div>
    Slug: <div id="slug">Some slug</div>
    Tags: <div id="tags">tag1, tag2</div>
    Exerpt: <div id="exerpt">Exerpt</div>
    Author: <div id="author">Me</div>
    When: <div id="datetime">Nov 12, 1981</div>
    Rev: <div id="rev">1</div>
    IP: <div id="ip">127.0.0.1</div>
    </li>
    </body>
    </html>'
    Benchmark.bm do |x|
      x.report("update: erb") {
        100.times do |n|
          @erb = ERB.new(@erb_template).result(binding)
        end
      }

      x.report("update: lilu") {  
        100.times do |n|
          @Document = Lilu::Document.new(@lilu_template,@html_template, { "blog" => @blog }).render
        end
      }

      x.report("update: lilu/prof") {  
        RubyProf.start
        100.times do |n|
          @Document = Lilu::Document.new(@lilu_template,@html_template, { "blog" => @blog }).render
        end
        result = RubyProf.stop
        printer = RubyProf::GraphHtmlPrinter.new(result)
        f = File.new('update_result.html','w')
        printer.print(f, '1')        
        f.close
      }
    end

  end
end
