class StoriesController < ApplicationController

  before_filter :signed_in_user_filter

  def new
    return redirect_to moreinfo_url if current_user.job_title.blank? || current_user.company.blank?

    render "new"
  end

  layout false, only: :create

  def create
    @story = Story.new(params[:story])
    @story.save

    respond_to do |t|
      t.js
    end
  end

  def upload_photo
    # On this step we should already have created story, so here
    # we would just add StoryImage(-s) to this story and display it(them)
    # on the view.
    @story = Story.find(params[:story_id])
    params[:file_bean].each do |file_bean|
      @story.story_photos.build photo: file_bean
    end
    @story.save

    render 'uploaded_photos', layout: nil
  end

end
