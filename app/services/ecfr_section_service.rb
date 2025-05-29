require 'net/http'
require 'nokogiri'

class EcfrSectionService
  BASE_URL = 'https://www.ecfr.gov/api/versioner/v1'
  
  def self.fetch_section(title_number, part, section)
    new.fetch_section(title_number, part, section)
  end
  
  def fetch_section(title_number, part, section)
    # First, get the latest version date for this title
    titles_uri = URI("#{BASE_URL}/titles.json")
    titles_response = Net::HTTP.get_response(titles_uri)
    raise "Failed to fetch titles: #{titles_response.code}" unless titles_response.code == '200'
    
    titles_data = JSON.parse(titles_response.body)
    title_data = titles_data['titles'].find { |t| t['number'] == title_number }
    raise "Title #{title_number} not found" unless title_data
    
    latest_date = title_data['latest_issue_date']
    
    # Now fetch the section content
    # The eCFR API expects the section number to be in the format "part.section"
    section_number = "#{part}.#{section}"
    section_uri = URI("#{BASE_URL}/full/#{latest_date}/title-#{title_number}/#{section_number}/xml")
    section_response = Net::HTTP.get_response(section_uri)
    
    if section_response.code == '200'
      parse_section(section_response.body, title_number, part, section)
    else
      Rails.logger.error "eCFR API returned #{section_response.code}: #{section_response.message}"
      nil
    end
  rescue => e
    Rails.logger.error "Failed to fetch section from eCFR API: #{e.message}"
    nil
  end
  
  private
  
  def parse_section(xml_content, title_number, part, section)
    doc = Nokogiri::XML(xml_content)
    
    # Extract the section content
    section_node = doc.at_css('DIV8')
    return nil unless section_node
    
    # Create or update the section
    section_record = Section.find_or_initialize_by(
      title_number: title_number,
      part: part,
      section: section
    )
    
    section_record.assign_attributes(
      text: xml_content,
      word_count: count_words(section_node)
    )
    
    section_record.save!
    section_record
  end
  
  def count_words(node)
    node.text.split(/\s+/).count
  end
end 