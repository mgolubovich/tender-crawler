class SelectorsController < ApplicationController

 get '/edit/:id' do
   @selector = Selector.find params[:id]
   haml :'selectors/edit'
 end

 post '/edit' do
   selector = Selector.find params[:selector_id]
   selector.value_type = params[:selector_value]
   selector.link_template = params[:selector_link]
   selector.xpath = params[:selector_xpath]
   selector.css = params[:selector_css]
   selector.attr = params[:selector_attr]
   selector.offset = params[:selector_offset]
   selector.regexp = params[:selector_regexp]
   selector.date_format = params[:selector_date_format]
   selector.js_code = params[:selector_js_code]
   selector.is_active = params[:selector_activity] == 'active' ? true : false
   selector.save
   redirect :back
 end

 #get '/:id/new' do
 #  haml :'selectors/new'
 #end



end

