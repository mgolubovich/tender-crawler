class ApiController < ApplicationController
  get '/default-tender-values-list' do
      json = {}
      Tender.default_values_fields_list.each { |field| json[field] = Tender.human_attribute_name(field) }
      json.to_json
  end
end