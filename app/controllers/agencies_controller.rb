class AgenciesController < ApplicationController
	before_action :authenticate_user!, except: [:show, :index]

	def index
		if params[:search]
			@agencies = Agency.search(params[:search])
		else
			@agencies = Agency.all
		end
		#Code hash send info of all agencies to the view to get converted to JSON
		@hash = Gmaps4rails.build_markers(@agencies) do |agency, marker|
	  	marker.lat agency.latitude
	  	marker.lng agency.longitude
		end
		@categories = Category.all
		#Pundit methods
		authorize @agencies
		authorize @categories
	end

	def show
		@agency = Agency.find(params[:id])
		#single agency info
		@hash = Gmaps4rails.build_markers(@agency) do |agency, marker|
  	marker.lat agency.latitude
		marker.lng agency.longitude
		marker.infowindow agency.name
		end
	end

	def new
		@agency = Agency.new
		authorize @agency
	end

	def create
		@agency = Agency.new(agency_params)
		if @agency.save
			flash[:notice] = (t'flash_notice.success')
			redirect_to @agency
		else
			render 'new'
		end
		authorize @agency
	end

	def show
		@agency = Agency.find(params[:id])
		#single agency info, adds the name marker to the map when creating the agency
		@hash = Gmaps4rails.build_markers(@agency) do |agency, marker|
  	marker.lat agency.latitude
  	marker.lng agency.longitude
		marker.infowindow agency.name
		end
		authorize @agency
	end

	def search
		@agencies = Agency.search(params)
	end

	def edit
		@agency = Agency.find(params[:id])
		authorize @agency
	end

	def update
		@agency = Agency.find(params[:id])
		if @agency.update_attributes(agency_params)
			flash[:notice] = (t'flash_notice.update')
			redirect_to @agency
		else
			render  'edit'
		end
		authorize @agency
	end

	def destroy
		@agency = Agency.find(params[:id])
		@agency.destroy
		flash[:notice] = t 'flash_notice.delete'
		redirect_to new_agency_url
		authorize @agency
	end


	private
	#probably dont need the socialmedia and categoria here. left just in case.
	def agency_params
		params.require(:agency).permit(:name, :address, :city, :state, :zipcode, :contact, :phone, :description, :categoria, category_ids: [], websites_attributes: [:id, :socialmedia, :destroy])
	end
end
