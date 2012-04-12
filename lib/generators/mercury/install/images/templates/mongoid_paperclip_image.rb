class Mercury::Image
  include Mongoid::Document
  include Mongoid::Paperclip

  has_mongoid_attached_file :image

  validates_presence_of :image

  # upgrade to paperclip 3.0:app/models/mercury/image.rb
  # has_attached_file :image, :styles => { :medium => "300x300>", :thumb => "100x100>" },
  #       :path => ":rails_root/public/system/:attachment/:id/:style/:filename",
  #       :url => "/system/:attachment/:id/:style/:filename"

  delegate :url, :to => :image

  def serializable_hash(options = nil)
    options ||= {}
    options[:methods] ||= []
    options[:methods] << :url
    super(options)
  end
end
