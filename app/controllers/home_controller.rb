class HomeController < ApplicationController
  def index
    Sample.perform_async
  end
end
