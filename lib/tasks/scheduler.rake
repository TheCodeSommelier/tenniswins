require 'uri'
require 'net/http'

namespace :matches do
  desc 'Get the match names for today'
  task get_names: :environment do
    url = URI("https://api.sportradar.com/tennis/trial/v2/en/schedules/#{Date.today.strftime("%Y-%m-%d")}/schedule.json?api_key=#{ENV.fetch('SPORT_RADAR_API_KEY')}")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request["accept"] = 'application/json'

    response = http.request(request)
    response_data = JSON.parse(response.read_body)
    response_data["sport_events"].each do |event|
      unless event["tournament"]["name"].downcase.include?('doubles') || event["tournament"]["name"].downcase.include?('itf')
        match_name = event["competitors"].map { |competitor| competitor["name"] }.join(" vs ")
        Match.create(name: match_name, tournament: event["tournament"]["name"])
      end
    end
  end

  desc 'Remove matches that are not used'
  task remove_matches: :environment do
    matches_to_delete = Match.where('created_at < ?', Time.current)
                             .where(picks: { id: nil }, parlays: { id: nil })

    # matches_to_delete.destroy_all
    p "🔥 matches_to_delete #{matches_to_delete.to_a}"
  end
end
