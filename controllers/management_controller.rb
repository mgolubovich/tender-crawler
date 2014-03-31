class ManagementController < ApplicationController
  get '' do
    haml :controls
  end
end