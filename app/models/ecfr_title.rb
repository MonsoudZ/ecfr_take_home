class EcfrTitle < ApplicationRecord
  validates :number, presence: true, uniqueness: true
  validates :name, presence: true
  
  scope :active, -> { where(reserved: false) }
  scope :reserved, -> { where(reserved: true) }
  scope :recently_amended, ->(days = 30) { where('latest_amended_on > ?', days.days.ago) }
  
  def recently_amended?(days = 30)
    latest_amended_on && latest_amended_on > days.days.ago
  end
  
  def self.sync_from_api
    EcfrApiService.sync_titles
  end
end