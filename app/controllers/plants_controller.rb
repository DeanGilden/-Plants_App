class PlantsController < ApplicationController
  before_action :set_plant, only: [ :show, :edit, :update, :destroy ]
  skip_before_action :authenticate_user!, only: [:index]

  def index
    if params[:query].present?
      @plants = Plant.search_by_name_and_description("#{params[:query]}")
    else
      @plants = Plant.all
    end
  end

  def new
    @plant = Plant.new
  end

  def create
    @plant = Plant.new(plant_params)
    @plant.user = current_user
    if @plant.save
      redirect_to plant_path(@plant)
    else
      render :new
    end
  end

  def show
    marker = Plant.where(id: params[:id])
    @markers = marker.geocoded.map do |plant|
      {
        lat: plant.latitude,
        lng: plant.longitude,
        info_window: render_to_string(partial: "info_window", locals: { plant: plant }),
        image_url: helpers.asset_url('plant-icon.png')
      }
    end
  end

  def destroy
    @plant.destroy
    redirect_to plants_path
  end

  private

  def set_plant
    @plant = Plant.find(params[:id])
  end

  def plant_params
    params.require(:plant).permit(:name, :image, :description, :photo)
  end
end
