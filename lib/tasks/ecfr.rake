namespace :ecfr do
  task sync_titles: :environment do
    EcfrApiService.sync_titles || exit(1)
  end
  
  task recently_amended: :environment do
    days = ENV['DAYS']&.to_i || 30
    EcfrTitle.recently_amended(days).order(:latest_amended_on)
            .each { |title| "#{title.number}: #{title.name} (#{title.latest_amended_on})" }
  end

  task sync_structure: :environment do
    EcfrTitle.find_each do |title|
      begin
        EcfrStructureService.import_title_structure(title.number)
      rescue => e
        e.message
      end
    end
  end

  task :sync_title_structure, [:title_number] => :environment do |t, args|
    title_number = args[:title_number]
    exit(1) unless title_number

    title = EcfrTitle.find_by(number: title_number)
    exit(1) unless title

    begin
      EcfrStructureService.import_title_structure(title.number)
    rescue => e
      e.message
      exit(1)
    end
  end

  task sync_all: :environment do
    require 'net/http'
    require 'json'
    require 'nokogiri'

    begin
      EcfrApiService.sync_titles
      
      EcfrTitle.find_each do |title|
        begin
          EcfrStructureService.import_title_structure(title.number)
        rescue => e
          e.message
          e.backtrace.join("\n")
        end
      end
    rescue => e
      e.message
      e.backtrace.join("\n")
    end
  end
end