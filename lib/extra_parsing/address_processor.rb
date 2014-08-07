# encoding: UTF-8
# Class used for processing address string
# and setting external city and region
class AddressProcessor
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
  @city_regions = ['Москва', 'Санкт-Петербург']

  def initialize(address = nil)
    @address = address
    @statistics = Statistics.last
  end

  def process
    @result = { external_region_id: nil, external_city_id: nil }

    # DEBUG: remove later
    puts @address

    @result = yandex_process if able_to_proceed?

    @result
  end

  private

  def check_word_count
    @address.split(' ').count >= AddressProcessor.min_word_count
  end

  def yandex_process
    result = { external_region_id: -1, external_city_id: -1 }

    region_name, city_name = yandex_json_parse

    # DEBUG: remove later
    puts region_name, city_name
    abort('exit')

    return result if region_name.to_s.empty?

    region = Region.where(name: region_name).first
    result[:external_region_id] = region.external_id

    return result if city_name.to_s.empty?

    city = City.where(region_id: region.external_id, name: city).first
    result[:external_city_id] = city.external_id unless city.nil?

    result
  end

  def yandex_json_parse
    params = yandex_params.map { |k, v| "#{k}=#{v}" }.join('&')
    uri = URI.escape(AddressProcessor.yandex_api_uri + params)

    response = JSON.parse(open(uri).read)
    @statistics.increment_yandex_counter

    geocode = response['response']['GeoObjectCollection']['featureMember']

    return [nil, nil] if geocode.empty?

    area = geocode[0].at(AddressProcessor.yandex_queries[:area_path], nil)
    subarea = geocode[0].at(AddressProcessor.yandex_queries[:subarea_path], nil)
    city = geocode[0].at(AddressProcessor.yandex_queries[:city_path], nil)

    area = subarea if AddressProcessor.city_regions.include?(subarea)

    [area, city]
  end

  def yandex_params
    {
      format: 'json',
      results: 1,
      geocode: address_for_uri
    }
  end

  def address_for_uri
    @address.gsub(/[ ]+/, ' ').gsub(/[ ]/, '+')
  end

  def able_to_proceed?
    @statistics.yandex_request_count <= AddressProcessor.request_limit && check_word_count
  end
end
