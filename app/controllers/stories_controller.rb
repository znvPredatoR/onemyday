class StoriesController < ApplicationController

  before_filter :signed_in_user_filter, except: [:show, :search, :explore]
  layout false, only: [:create, :destroy]

  def index
    @stories = Story.all

    render "list_stories", stories: @stories
  end

  def search
    @query = params[:q]
    @stories = Story.where("title like '%#@query%'")
  end

  def explore
    filter_type = params[:ft].blank? ? StoriesHelper::EXPLORE_FILTER_RECENT : params[:ft].to_i

    if filter_type == StoriesHelper::EXPLORE_FILTER_POPULAR
      @stories = Story.top(nil, params[:t])
    elsif filter_type == StoriesHelper::EXPLORE_FILTER_RECENT
      @stories = Story.recent(params[:t])
    end

    respond_to do |format|
      format.js { render layout: false }
      format.html { render file: 'stories/explore' }
    end
  end

  def new
    return redirect_to moreinfo_url if current_user.job_title.blank? || current_user.company.blank?

    render "new"
  end

  def show
    @story = Story.unscoped.find(params[:id])

    @story.views.build(date: DateTime.now).save!
  end

  def create
    @story = @current_user.stories.build(params[:story])
    @story.save

    respond_to { |t| t.js }
  end

  def upload_photo
    if params[:create_story]
      @story = @current_user.stories.build(params[:story])
    else
      @story = @current_user.stories.unscoped.find(params[:story_id])
    end

    params[:file_bean].each do |file_bean|
      @story.story_photos.build photo: file_bean
    end
    @story.save!

    @story_photos = @story.story_photos

    render 'uploaded_photos', layout: nil
  end

  def publish
    @story = @current_user.stories.unscoped.find(params[:story][:id])

    if @story.has_photos && @story.update_attributes(params[:story])
      redirect_to @story
    else
      render "new"
    end
  end

  def like
    Story.find(params[:story_id]).likes.build(user_id: current_user.id).save!
    render nothing: true
  end

  def unlike
    Story.find(params[:story_id]).likes.find_by_user_id(current_user.id).destroy
    render nothing: true
  end

  def destroy
    @story = Story.unscoped.find(params[:id])

    raise AccessDenied unless is_current_user @story.user

    @story.destroy

    respond_to do |format|
      format.js
      format.html { redirect_to current_user }
    end
  end

  def edit
    @story = Story.unscoped.find(params[:id])

    raise AccessDenied unless is_current_user @story.user
  end

end
