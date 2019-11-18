class Note < ApplicationRecord
  belongs_to :user
  has_many :viewers
  has_many :readers, through: :viewers, source: :user

  before_save :ensure_owner_can_read

  def visible_to
    readers.map do |reader|
      reader.name
    end.join(",")
  end

  def visible_to=(comma_string)
    self.readers = comma_string.split(",").map do |name|
      User.find_by(name: name.strip)
    end.compact
  end

  private

  def ensure_owner_can_read
    if user && !readers.include?(user)
      readers << user
    end
  end

end
