class DevController < ApplicationController
  get '/tenders' do
    @cities = {}
    City.all.each { |city| @cities[city.city_code] = {:name => city.name, :region_code => city.region_code} }

    @regions = {}
    Region.all.each { |region| @regions[region.region_code] = region.name}

    @tenders = Tender.or({:region_code.gt => 0}, {:city_code.gt => 0})
    @tenders = @tenders.paginate(page: params[:page], per_page: 100)

    haml :"dev/tenders"
  end
end