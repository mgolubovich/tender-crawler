class RulesController < ApplicationController

  get '/new/:selector_id' do
    @selector = Selector.find params[:selector_id]
    @source_name = @selector.source.name
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
    redirect "/sources/edit/#{@selector.source_id}"
  end

  get '/:selector_id/edit/:id' do
    @selector = Selector.find params[:selector_id]
    @source_name = @selector.source.name
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
    @source_id = rule.selector.source_id
    redirect "/sources/edit/#{@source_id}"
  end

  get '/:id/destroy' do
    rule = Rule.find params[:id]
    @source_id = rule.selector.source_id
    @rule_selector = rule.selector_id
    rule.destroy
    redirect "/sources/edit/#{@source_id}"
  end
end
