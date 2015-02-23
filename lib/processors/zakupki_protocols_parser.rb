# encoding: UTF-8
# Utility class for parsing protocls from zakupki
class ZakupkiProtocolParser
  include Capybara::DSL

  class << self
    attr_accessor :protocol_link_template
    attr_accessor :printform_link_template
    attr_accessor :pbuttons_xpath
    attr_accessor :pform_xpath
    attr_accessor :print_onclick_xpath
  end

  @pform_xpath = '//th[contains(text(), "Результат")]/ancestor::tbody[1]//*[contains(text(), "ИНН")]/..'
  @pbuttons_xpath = "//td[@class='descriptTenderTd']/dl/dt/span"
  @print_onclick_xpath = "//div[@class='noticeBox']/ul/li[2]/a"
  # @pbuttons_xpath = '//p[contains(text(),"Протокол выбора победителя")]/../../../div[@class="drop"]/img'
  @printform_link_template = 'http://zakupki.gov.ru/223/purchase/public/print-form/show.html?pfid=$pfid'
  @protocol_link_template = 'http://zakupki.gov.ru/223/purchase/public/purchase/info/protocols.html?noticeId=$tender_id&epz=true'


  def initialize(tender_id, cartridge)
    @tender_id = tender_id
    @data = {}
    @nm = NavigationManager.new
    #@nm.load(cartridge.load_pm)
    @log = ParserLog.new.logger
  end

  def parse
    @log.info('parse protocols', tender_id: @tender_id)

    go_result = @nm.go(ZakupkiProtocolParser.protocol_link_template.gsub('$tender_id', @tender_id), false, false)
    unless go_result
      @log.error('cant visit tender')
      return nil
    end

    protocols_buttons = all(:css, 'span.noticeSign')

    if protocols_buttons.empty?
      screen = Capybara.page.driver.render_base64
      @log.error('empty protocols', tender_id: @tender_id, screen: screen)
      return nil
    else
      # @log.info('found protocol buttons ', buttons:protocols_buttons)
      protocols_buttons.each do |button|
        button.trigger('click')
        sleep(0.5)
      end
    end

    # @log.error('get dom after click', screen:screen)
    url = find(:xpath, ZakupkiProtocolParser.print_onclick_xpath)[:onclick]
    @log.info('found url', url: url)

    pfid = url.scan(/[0-9]{4,}/).count > 0 ? url.scan(/[0-9]{4,}/).first : nil

    @log.info('found protocol url ', url: url, pfid: pfid)

    if pfid
      @log.info('get protocol', tender_id: @tender_id, pfid: pfid)
      @nm.go(ZakupkiProtocolParser.printform_link_template.gsub('$pfid', pfid))
      result_rows = all(:xpath, ZakupkiProtocolParser.pform_xpath)

      result_rows.each do |r|
        inn = r.text.scan(/[\d]{10,}/).count > 0 ? r.text.scan(/[\d]{10,}/).first : nil
        puts r.text
        next unless inn

        @data[inn] = r.text.include?('Победитель') || result_rows.count == 1 ? true : false
        @log.info('found protocol', tender_id: @tender_id, pfid: pfid, inn: @data[inn])
      end
    end
    @log.info('protocols', inn: @data)
    @data
  rescue Capybara::ElementNotFound
    screen = Capybara.page.driver.render_base64
    @log.error('element not found', screen: screen)
  end
end