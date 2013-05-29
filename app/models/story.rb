class Story < ActiveRecord::Base
  attr_accessible :title, :published, :story_photos_attributes, :tag_list

  attr_accessor :current_user

  acts_as_taggable

  belongs_to :user

  has_many :story_photos, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :views, dependent: :destroy
  accepts_nested_attributes_for :story_photos

  validates_presence_of :title
  validates :user, presence: true

  self.per_page = 10

  default_scope where(:published => true)
  scope :unpublished, where(:published => false)
  scope :recent, ->(tags=nil) {
    stories = Story.scoped
    stories = tagged_with(tags) if tags
    stories.order("created_at DESC")
  }
  scope :from_users_followed_by, lambda { |user| followed_by(user) }

  def initialize(attributes = nil, options = {})
    super attributes, options
    self.published = false
  end

  def before_save
    self.published = false if self.story_photos.blank?
  end

  def has_photos
    self.story_photos.any?
  end

  def date_nice_text
    Story.date_to_nice_text created_at
  end

  def self.date_to_text(time)
    I18n.localize time, format: "%d-%m-%Y"
  end

  def self.date_to_nice_text(time)
    I18n.localize time, format: "%b %d, %Y"
  end

  def self.top(lim=nil, tags=nil)
    if tags
      # I had to use two selects because for some reason JOINING tags doesn't work with additional agg_count column.
      stories = Story.scoped.tagged_with(tags)
      Story.select("*, (likes_count * 10) + views_count as agg_count").
          where("stories.id in (#{stories.collect { |story| story.id }.join(",")})",).
          order("agg_count DESC").limit(lim) if stories.any?
    else
      Story.select("*, (likes_count * 10) + views_count as count").order("count DESC").limit(lim)
    end
  end

  def is_liked_by_user(user=nil)
    user ||= current_user
    return unless user
    self.likes.pluck(:user_id).include?(user.id)
  end

  private

  # Returns an SQL condition for users followed by the given user.
  # We include the user's own id as well.
  def self.followed_by(user)
    followed_user_ids = %(SELECT followed_id FROM relationships
                            WHERE follower_id = :user_id)
    where("user_id IN (#{followed_user_ids}) OR user_id = :user_id",
          {user_id: user})
  end

end
