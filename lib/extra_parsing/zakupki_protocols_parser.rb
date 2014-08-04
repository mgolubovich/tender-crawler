class ZakupkiProtocolParser
  
  include Capybara::DSL

  def initialize(tender_id)
    @tender_id = tender_id
    @protocol_link_template = 'http://zakupki.gov.ru/223/purchase/public/purchase/info/protocols.html?noticeId=$tender_id&epz=true'
    @printform_link_template = 'http://zakupki.gov.ru/223/purchase/public/print-form/show.html?pfid=$pfid'
    @data = {}
  end

  def parse
    visit @protocol_link_template.gsub('$tender_id', @tender_id)
    begin
      protocols_buttons = all(:xpath, "//p[contains(text(),'Протокол выбора победителя')]/../../../div[@class='drop']/img")
      # debugger
      unless protocols_buttons.empty?
        protocols_buttons.first.click
      else
        return nil
      end
      
      url = find(:css, '.lastLi a')[:onclick]
      pfid = url.scan(/[0-9]{4,}/).count > 0 ? url.scan(/[0-9]{4,}/).first : nil

      if pfid
        visit @printform_link_template.gsub('$pfid', pfid)
        result_rows = all(:xpath, "//th[contains(text(), 'Результат')]/ancestor::tbody[1]//*[contains(text(), 'ИНН')]/..")
        
        result_rows.each do |r|
          inn = r.text.scan(/[\d]{10,}/).count > 0 ? r.text.scan(/[\d]{10,}/).first : nil
          next unless inn
          @data[inn] = r.text.include?('Победитель') ? true : false
        end
      end
    rescue Capybara::ElementNotFound
      nil
    end
    @data
  end

end