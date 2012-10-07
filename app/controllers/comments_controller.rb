class CommentsController < ApplicationController

  include CommentsHelper

  before_filter :signed_in_user_filter, only: [:create, :update]

  layout false, only: [:create, :update]

  def create
    story = Story.find(params[:story_id])
    @comment = story.comments.build(params[:comment])
    @comment.user = current_user

    @comment.save!

    respond_to { |t| t.js }
  end

  def update
    story = Story.find(params[:story_id])
    @comment = story.comments.find(params[:comment][:id])

    if comment_editable? @comment
      @comment.text = params[:comment][:text]
      @comment.save!
      respond_to { |t| t.js }
    end
  end

end
