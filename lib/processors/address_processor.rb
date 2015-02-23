# encoding: UTF-8
# Class used for processing address string
# and setting external city and region
class AddressProcessor
  require 'open-uri'
  class << self
    attr_accessor :min_word_count
    attr_accessor :yandex_api_uri
    attr_accessor :request_limit
    attr_accessor :query_fpath
    attr_accessor :yandex_queries
    attr_accessor :city_regions
  end

  @min_word_count = 2
  @yandex_api_uri = 'http://geocode-maps.yandex.ru/1.x/?'
  @request_limit = 22_000
  @query_fpath = 'config/dictionaries/yandex_response_queries.yml'
  @yandex_queries = YAML.load_file(@query_fpath).symbolize_keys!

  def initialize(address = nil)
    @address = address[0..150]
    @statistics = Statistics.last

    @yandex_requests_counter = 0
    @max_yandex_requests = 5
  end

  def process
    @result = { region_code: nil, city_code: nil }
    able_to_proceed? ? yandex_process : @result = { region_code: -1, city_code: -1 }
    @result
  end

  private

  def check_word_count
    @address.to_s.split(' ').count >= AddressProcessor.min_word_count
  end

  def yandex_process
    area_name, subarea_name, city_name = yandex_json_parse

    return { region_code: -1, city_code: -1 } if area_name.to_s.empty?

    region = Region.or({ name: area_name.mb_chars.downcase },
                       { alt_name: area_name.mb_chars.downcase }).first
    region = Region.or({ name: subarea_name.mb_chars.downcase },
                       { alt_name: subarea_name.mb_chars.downcase }).first if region.nil? && !subarea_name.to_s.empty?

    unless region.nil?
      @result[:region_code] = region.region_code
      return 0 if city_name.to_s.empty?

      city = City.where(region_code: region.region_code,
                        name: city_name.mb_chars.downcase).first
      @result[:city_code] = city.city_code unless city.nil?
    end
  end

  def yandex_json_parse
    params = yandex_params.map { |k, v| "#{k}=#{v}" }.join('&')
    uri = URI.escape(AddressProcessor.yandex_api_uri + params)
    json = yandex_request_process(uri)

    return nil if json.nil?

    @result = { region_code: -1, city_code: -1 }
    response = JSON.parse(json)
    @statistics.increment_yandex_counter

    geocode = response['response']['GeoObjectCollection']['featureMember']

    return nil if geocode.to_s.empty? || geocode.count == 0

    area = geocode[0].at(AddressProcessor.yandex_queries[:area_path], nil)
    subarea = geocode[0].at(AddressProcessor.yandex_queries[:subarea_path], nil)
    city = geocode[0].at(AddressProcessor.yandex_queries[:city_path], nil)

    [area, subarea, city]
  end

  def yandex_params
    {
      format: 'json',
      results: 1,
      geocode: address_for_uri
    }
  end

  def address_for_uri
    @address.gsub(/[ ]+/, ' ').gsub(/[ ]/, '+').gsub(/[;]/, '')
  end

  def able_to_proceed?
    @statistics.yandex_request_count <= AddressProcessor.request_limit && check_word_count
  end

  def yandex_request_process(uri)
    open(uri).read
  rescue
    @yandex_requests_counter += 1
    sleep 1
    @yandex_requests_counter <= @max_yandex_requests ? yandex_request_process(uri) : nil
  end
end
