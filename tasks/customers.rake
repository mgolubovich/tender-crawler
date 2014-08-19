# require 'capybara'
# require 'capybara/dsl'
# require 'capybara/webkit'
# require 'debugger'
# require 'csv'

# include Capybara::DSL
#   Capybara.default_driver = :webkit
#   Capybara.run_server = false
#   Capybara.default_wait_time = 5

# namespace :customers do
#   desc "Parsing customers"
#   task :zakupki, :first_id, :last_id do |t, args|
#     ids = (args[:first_id].to_i..args[:last_id].to_i)
#     ids.each do |id|
#       url = "http://zakupki.gov.ru/223/ppa/public/organization/organization.html?epz=true&agencyId=" + id.to_s
#       visit(url)
#       organization_type = all(:xpath, "//td[contains(text(), 'Полномочия организации')]/following-sibling::td[1]/label/i").first.text.strip
#       next unless organization_type == "Заказчик"
#       customer = Hash.new
#       customer[:name] = all(:xpath, "//td[contains(text(), 'Полное наименование организации')]/following-sibling::td").first.text.strip
#       customer[:short_name] = all(:xpath, "//td[contains(text(), 'Сокращенное наименование организации')]/following-sibling::td").first.text.strip
#       customer[:inn] = all(:xpath, "//td[contains(text(), 'ИНН')]/following-sibling::td").first.text.strip
#       customer[:address] = all(:xpath, "//td[contains(text(), 'Адрес (место нахождения)')]/following-sibling::td").first.text.strip
#       customer[:mail_address] = all(:xpath, "//td[contains(text(), 'Почтовый адрес')]/following-sibling::td").first.text.strip
#       customer[:email] = all(:xpath, "//td[contains(text(), 'Адрес электронной почты для системных уведомлений')]/following-sibling::td").first.text.strip
#       customer[:customer_name] = all(:xpath, "//td[contains(text(), 'Контактное лицо')]/following-sibling::td").first.text.strip
#       customer[:customer_telephone] = all(:xpath, "//td[contains(text(), 'Телефон')]/following-sibling::td").first.text.strip
#       customer[:customer_fax] = all(:xpath, "//td[contains(text(), 'Факс')]/following-sibling::td").first.text.strip
#       customer[:source] = "zakupki.gov.ru"
#       Customer.create(customer)
#       puts "[#{Time.now}] #{id}:#{customer[:name]} saved."
#     end
#   end
#   task :export, :source do |t, args|
#     CSV.open(args[:source].to_s + ".csv", "w", { :col_sep => ";" }) do |csv|
#       csv << ["ID", "Полное наименование организации", "Сокращенное наименование организации", "ИНН", "Адрес (место нахождения)", "Почтовый адрес", "Адрес электронной почты для системных уведомлений", "Контактное лицо", "Телефон", "Факс", "Источник"]
#       Customer.where(:source => args[:source].to_s).each do |c|
#         csv << c.attributes.values
#         puts "[#{Time.now}] Customer id ##{c._id} exported."
#       end
#     end
#   end
#   task :zakazrf, :first_id, :last_id do |t, args|
#     ids = (args[:first_id].to_i..args[:last_id].to_i)
#     ids.each do |id|
#       url = "http://zakazrf.ru/Customer/CustomerView.aspx?id=" + id.to_s
#       visit(url)
#       organization_type = all(:xpath, "//*[contains(text(), 'Роль организации при размещении заказа:')]/following::td[1]").first.text.strip #all(:css, "ctl00_Content_DbLabel1").first.text.strip
#       #debugger
#       next unless organization_type == "Заказчик"
#       customer = Hash.new
#       customer[:name] = all(:css, "#ctl00_Content_FullNameLabel").first.text.strip
#       customer[:short_name] = all(:css, "#ctl00_Content_NameLabel").first.text.strip
#       customer[:inn] = all(:css, "#ctl00_Content_INNLabel").first.text.strip
#       customer[:address] = all(:css, "#ctl00_Content_FullAddressLabel").first.text.strip
#       customer[:mail_address] = all(:css, "#ctl00_Content_FullPostAddressLabel").first.text.strip
#       customer[:email] = all(:css, "#ctl00_Content_EMail2Label").first.text.strip
#       customer[:customer_name] = ""
#       customer[:customer_telephone] = all(:css, "#ctl00_Content_PhoneLabel").first.text.strip
#       customer[:customer_fax] = ""
#       customer[:source] = "zakazrf.ru"
#       Customer.create(customer)
#       puts "[#{Time.now}] #{id}:#{customer[:name]} saved."
#     end
#   end

# end
