class AddressProcessor
  MIN_WORD_COUNT = 2
  YANDEX_API_URI = "http://geocode-maps.yandex.ru/1.x/?"
  LIMIT_YANDEX_COUNTER = 22000
  AREA_PATH = "GeoObject.metaDataProperty.GeocoderMetaData.AddressDetails.Country.AdministrativeArea.AdministrativeAreaName"
  SUBAREA_PATH = "GeoObject.metaDataProperty.GeocoderMetaData.AddressDetails.Country.AdministrativeArea.SubAdministrativeArea.SubAdministrativeAreaName"
  CITY_PATH = "GeoObject.metaDataProperty.GeocoderMetaData.AddressDetails.Country.AdministrativeArea.SubAdministrativeArea.Locality.LocalityName"

  def initialize(address = nil)
    @address ||= ''
    @statistics = Statistics.last
  end

  def process(address)
    @address = address
    @result = {:external_region_id => nil, :external_city_id => nil}

    puts @address

    yandex_process if @statistics.yandex_request_count <= LIMIT_YANDEX_COUNTER && check_word_count

    @result
  end

  private

  def check_word_count
    @address.split(' ').count >= MIN_WORD_COUNT
  end

  def yandex_process
    @result[:external_region_id] = -1
    @result[:external_city_id] = -1

    region_name, city_name = yandex_json_parse

    puts region_name, city_name
    abort("exit")
    unless region_name.empty?
      region = Region.where(:name => region_name).first
      @result[:external_region_id] = region.external_id
    end

    unless city_name.empty?
      city = City.where(:region_id => region.external_id, :name => city).first
      @result[:external_city_id] = city.external_id unless city.nil?
    end
  end

  def yandex_json_parse
    require 'open-uri'

    cities = ["Москва", "Санкт-Петербург"]
    area, city = nil

    geocode = JSON.parse(open(URI.escape(YANDEX_API_URI + get_yandex_params.map{|k,v| "#{k}=#{v}"}.join('&'))).read)
    geocode = geocode["response"]["GeoObjectCollection"]["featureMember"]

    @statistics.increment_yandex_counter

    unless geocode.empty?
      area = AREA_PATH.split(".").inject(geocode[0]) { |hash, key| hash[key] }
      subarea = SUBAREA_PATH.split(".").inject(geocode[0]) { |hash, key| hash[key] }
      city = CITY_PATH.split(".").inject(geocode[0]) { |hash, key| hash[key] }

      area = subarea if cities.include?(subarea)
    end

    [area, city]
  end

  def get_yandex_params
    {
      :format => 'json',
      :results => 1,
      :geocode => get_address_for_uri
    }
  end

  def get_address_for_uri
    @address.gsub(/[ ]+/, ' ').gsub(/[ ]/, '+')
  end
end