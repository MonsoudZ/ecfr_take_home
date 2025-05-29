require 'net/http'
require 'json'

class EcfrApiService
  BASE_URL = 'https://www.ecfr.gov/api/versioner/v1'
  
  def self.sync_titles
    new.sync_titles
  end
  
  def sync_titles
    response = fetch_titles
    return false unless response
    
    data = JSON.parse(response)
    sync_time = Time.current
    
    ActiveRecord::Base.transaction do
      sync_title_data(data['titles'], sync_time)
      mark_outdated_titles(sync_time)
    end
    
    true
  rescue => e
    Rails.logger.error "Failed to sync eCFR titles: #{e.message}"
    false
  end
  
  private
  
  def fetch_titles
    uri = URI("#{BASE_URL}/titles.json")
    response = Net::HTTP.get_response(uri)
    response.code == '200' ? response.body : nil
  rescue => e
    Rails.logger.error "Failed to fetch from eCFR API: #{e.message}"
    nil
  end
  
  def sync_title_data(titles, sync_time)
    titles.each do |title_data|
      title = EcfrTitle.find_or_initialize_by(number: title_data['number'])
      title.assign_attributes(
        name: title_data['name'],
        latest_amended_on: parse_date(title_data['latest_amended_on']),
        latest_issue_date: parse_date(title_data['latest_issue_date']),
        up_to_date_as_of: parse_date(title_data['up_to_date_as_of']),
        reserved: title_data['reserved'],
        last_synced_at: sync_time
      )
      title.save!
    end
  end
  
  def mark_outdated_titles(sync_time)
    EcfrTitle.where.not(last_synced_at: sync_time)
            .update_all(last_synced_at: sync_time - 1.day)
  end
  
  def parse_date(date_string)
    return nil if date_string.nil? || date_string.empty?
    Date.parse(date_string)
  rescue Date::Error
    nil
  end
end
