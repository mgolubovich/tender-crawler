# encoding: UTF-8
# Utility class for parsing protocls from zakupki
class ZakupkiProtocolParser
  include Capybara::DSL

  class << self
    attr_accessor :protocol_link_template
    attr_accessor :printform_link_template
    attr_accessor :pbuttons_xpath
    attr_accessor :pform_xpath
  end

  @protocol_link_template = 'http://zakupki.gov.ru/223/purchase/public/purchase/info/protocols.html?noticeId=$tender_id&epz=true'
  @printform_link_template = 'http://zakupki.gov.ru/223/purchase/public/print-form/show.html?pfid=$pfid'
  @pbuttons_xpath = '//p[contains(text(),"Протокол выбора победителя")]/../../../div[@class="drop"]/img'
  @pform_xpath = '//th[contains(text(), "Результат")]/ancestor::tbody[1]//*[contains(text(), "ИНН")]/..'

  def initialize(tender_id)
    @tender_id = tender_id
    @data = {}
  end

  def parse
    visit ZakupkiProtocolParser.protocol_link_template.gsub('$tender_id', @tender_id)
    protocols_buttons = all(:xpath, "")
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
      result_rows = all(:xpath, ZakupkiProtocolParser.pform_xpath)

      result_rows.each do |r|
        inn = r.text.scan(/[\d]{10,}/).count > 0 ? r.text.scan(/[\d]{10,}/).first : nil
        next unless inn
        @data[inn] = r.text.include?('Победитель') ? true : false
      end
    end
    rescue Capybara::ElementNotFound
      nil
    @data
  end

end