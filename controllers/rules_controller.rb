class RulesController < ApplicationController

  get '/new/:selector_id' do
    @selector = Selector.find params[:selector_id]
    @cartridge_name = @selector.cartridge.name
    haml :'rules/new'
  end

  post '/new/:selector_id' do
    @selector = Selector.find params[:selector_id]
    rule = @selector.rules.new
    rule.regexp = params[:rule_regexp]
    rule.is_active = params[:rule_activity] == 'active' ? true : false
    rule.check_length = {:less => params[:rule_length_less].to_i, :more => params[:rule_length_more].to_i, :equal => params[:rule_equal].to_i}
    rule.check_emptiness = params[:rule_emptiness] == 'on' ? true : false
    rule.failed_status = params[:rule_status] == 'failed' ? :failed : :moderation
    rule.save
    redirect "/cartridges/edit/#{@selector.cartridge_id}"
  end

  get '/:selector_id/edit/:id' do
    @selector = Selector.find params[:selector_id]
    @cartridge_name = @selector.cartridge.name
    @rule = Rule.find params[:id]
    haml :'rules/edit'
  end

  post '/:selector_id/edit/:id' do
    rule = Rule.find params[:rule_id]
    rule.regexp = params[:rule_regexp]
    rule.is_active = params[:rule_activity] == 'active' ? true : false
    rule.check_length = {:less => params[:rule_length_less].to_i, :more => params[:rule_length_more].to_i, :equal => params[:rule_equal].to_i}
    rule.check_emptiness = params[:rule_emptiness] == 'on' ? true : false
    rule.failed_status = params[:rule_status] == 'failed' ? :failed : :moderation
    rule.save
    @cartridge_id = rule.selector.cartridge_id
    redirect "/cartridges/edit/#{@cartridge_id}"
  end

  get '/:id/destroy' do
    rule = Rule.find params[:id]
    @cartridge_id = rule.selector.cartridge_id
    @rule_selector = rule.selector_id
    rule.destroy
    redirect "/cartridges/edit/#{@cartridge_id}"
  end
end
