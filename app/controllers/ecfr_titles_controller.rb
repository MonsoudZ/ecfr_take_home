class EcfrTitlesController < ApplicationController
  def index
    @titles = EcfrTitle.order(:number)
  end
  
  def show
    @title = EcfrTitle.find_by(number: params[:id]) || EcfrTitle.find(params[:id])
  end
  
end