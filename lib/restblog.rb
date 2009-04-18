
require 'rubygems'
require 'pathname'

require 'sinatra/base'
require 'maruku'
require 'haml'
require 'grit'

class Restblog

  Version = "0.1.0"
  
  class << self
    attr_accessor :root, :content_dir, :repo

    def new(root)
      self.root = root
      self.content_dir = Pathname(root) + "content"
      self.repo = Grit::Repo.new(root)

      App
    end

    def version
      Version
    end

    def posts_dir
      @posts_dir ||= self.content_dir + 'posts'
    end

  end


  class Post
    attr_reader :filename

    class << self

      def all
        posts.map { |f| new(f) }
      end

      def posts
        Dir.glob(Pathname(Restblog.posts_dir) + '**/*.mkd')
      end

    end

    def initialize(filename)
      @filename = filename
    end

    def name
      File.basename(filename, '.mkd')
    end

    def title
      name.gsub(/_/, " ").split(" ").map{ |w| w.capitalize }.join(" ")
    end

    def data
      @data ||= File.open(filename, 'r') { |f| f.read }
    end

    def author
      first_commit.author
    end

    def authored_date
      first_commit.authored_date
    end

    def updated_date
      authored_date
    end


    private

    def first_commit
      @first_commit ||= begin
        id = `git log --pretty=oneline --date-order --reverse --max-count=1 -- Rakefile | awk '{print $1}'`
        Restblog.repo.commit(id)
      end
    end

  end

  class App < Sinatra::Base

    set :app_file, __FILE__
    set :views, 'layout'
    set :public, 'public'
    enable :static

    get "/" do
      redirect "/posts"
    end

    get "/posts" do
      @posts = Post.all
      haml :list
    end

    %w[ /posts/:name /posts/:name.:format ].each do |route|
    get route do

      case format
      when :json
        "JSON"
      when :mkd, :txt
        "markdown"
      else
        "html"
      end
    end
    end

    get "/stylesheets/style.css" do
      content_type 'text/css', :charset => 'utf-8'
      sass :style
    end

    helpers do
      def render_post(post)
        haml(:post, :layout => false, :locals => {:post => post})
      end

    end

    def title(title=nil)
      @title = title.to_s if title
      @title
    end

    def post_link(post)
      %Q{<a href="/posts/#{post.name}">#{post.title}</a>}
    end

    def author_link(author)
      %Q{<a href="mailto:#{author.email}">#{author.name}</a>}
    end

    def format
      if format = params[:format]
        format.to_sym
      else
        puts request.accept.inspect

      end
    end
  end

end
