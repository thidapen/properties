class PropertiesController < ApplicationController
  before_action :authenticate , only: [:exclusive]	
  def index
  	@properties = Property.all

	respond_to do |format|
		  	if province = params[:province]
		  		@properties = @properties.where(province: province)
		  		format.json { render json: @properties }
		    	format.xml {render xml: @properties}
		  	else
			    format.json 
			    format.xml {render xml: @properties}
			end
  	end
  end

  def show
  	property = Property.find(params[:id])
  	render json: property
  end

  def create	
	property = Property.new(property_params)

	if property.save	
		render json: property, status: 201, location: property	
		# after it save it not run else so we need to validates_presence_of :name, :province in class property in propetry.rb
	else 
		render json: property.errors, status: 422
	end	
  end

  def update
  	property = Property.find(params[:id])
#  here for implementation becouse 
  	if property.update(property_params)
		render json: property, status: 200	
	else
		render json: property.errors, status: 422
	end
  end

  def destroy
  	# delete by id so need to find by id first before delete
	property = Property.find(params[:id]) 
	property.destroy
    head 204
  end

  def exclusive
  	render json: {message: "Welcome to Devbootstrap"}
  end

  protected
	def authenticate
		authenticate_or_request_with_http_basic do |username, password|

			return (username == 'foo' && password == 'secret')
		end
	end

  private	
	def property_params	
		params.require(:property).permit(:name, :province)	
	end

end
