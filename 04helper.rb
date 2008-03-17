class PostController < ApplicationController
end

module PostsHelper
  def current_posts
    @current_posts ||= Post.find(:all)
  end
  
  def top_posts
    @top_posts ||= Post.find_top_posts
  end
end