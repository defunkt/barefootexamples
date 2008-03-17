class PostController < ApplicationController
  before_filter :set_top_posts

  def index
    @posts = Post.find(:all)
  end

  def set_top_posts
    @top_posts = Post.find_top_posts
  end
end