
require 'rubygems'
require 'pathname'

require 'sinatra/base'
require 'maruku'
require 'haml'
require 'grit'

module Restblog

  Version = "0.1.0"

  class << self
    attr_accessor :root, :content_dir, :repo
  end

  def self.new(root)
    self.root = root
    self.content_dir = Pathname(root) + "content"
    self.repo = Grit::Repo.new(root)

    App
  end

  def self.posts_dir
    content_dir + '/posts'
  end

  def self.version
    Version
  end

  class Post

    class << self

      def all
        posts.map { |f| new(f) }
      end

      def posts
        Dir.glob(Pathname(Restblog.posts_dir) + '**/*.mkd')
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

    get "/stylesheets/style.css" do
      content_type 'text/css', :charset => 'utf-8'
      sass :style
    end

    def title(title=nil)
      @title = title.to_s if title
      @title
    end
  end

end
