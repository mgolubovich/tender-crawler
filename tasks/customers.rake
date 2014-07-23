require 'debugger'
require 'capybara/dsl'
require 'capybara/webkit'

namespace :customers do
  desc "Parsing customers"
  task :zakupki, :last_id do |t, args|
    url = "http://zakupki.gov.ru/223/ppa/public/organization/organization.html?epz=true&agencyId=" + args.last_id
    data = Hash.new


  end
end
