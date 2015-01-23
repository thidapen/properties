require 'spec_helper'
require 'rails_helper'

describe PropertiesController do
	# need to render_views for see the result in console
	render_views
	
	# @request.env["HTTP-ACCEPT"] = Mime :: XML
	before do
		@request.env['HTTP_ACCEPT'] = Mime::JSON
		Property.create!(name: "House in Battambang", province: "Battambang")
		Property.create!(name: "Villa in Kandal", province: "Kandal")
	end

	it "Get all properties" do
		get :index	
		# expect response that get for index to success
		expect(response).to have_http_status(:success)
		expect(response.body).not_to be_empty
	end

	it "GET properties filtered by province" do
		# for get index filtered by province
		get :index, province: "Battambang"
		# pass the value by JSON 
		properties = JSON.parse(response.body, symbolize_names: true)
		# collect province to put in Hash 
		provinces = properties.collect{|p| p[:province]}
		# expect only one province that match or have for Battambang
		expect(provinces.uniq).to match_array(["Battambang"])
	end

	describe "SHOW property" do
		it "should return the property by id" do
			property = Property.create!(name: "House in Battambang", province: "Battambang")
			get :show, id: property.id
			fetched = JSON.parse(response.body, symbolize_names: true)	
			# when thorght the id  by json it equal to id property or not
			expect(fetched[:id]).to eq(property.id) 

		end
	end
	describe "Content Negotiation" do
		context "for JSON content" do
			before do
				@request.env["HTTP_ACCEPT"] = Mime::JSON
			end
			it 'returns properties in JSON' do
				get :index
				expect(response.header["Content-Type"]).to include Mime::JSON
		 	end
		  end
		context "for XML content" do
			before do
				@request.env["HTTP_ACCEPT"] = Mime::XML
			end
			it 'returns properties in XML' do
				get :index
				expect(response.header["Content-Type"]).to include Mime::XML
			end
		end
	end
	describe "Language Negotiation" do
		context "For English Language" do
			before do
				@request.env["HTTP_ACCEPT_LANGUAGE"] = 'en'
			end
			it 'returns properties in English Language' do
				get :index
				properties = JSON.parse(response.body, symbolize_names: true)
				expect(properties[0][:message]).to eq "Beautiful property in #{properties[0][:province]}"		
		 	end
		  end
		context "For Khmer language" do
			before do
				@request.env["HTTP_ACCEPT_LANGUAGE"] = 'km'
			end
			it 'returns properties in Khmer language' do
				get :index
				properties = JSON.parse(response.body, symbolize_names: true)
				# assert_equal "Cuidado com #{zombies[0][:name]}!", zombies[0][:message]	
				expect(properties[0][:message]).to eq "ទ្រព្យសម្បត្ដិដ៏ស្រស់ស្អាតនៅ #{properties[0][:province]}"
			end
		end
	end
	describe "Post properties" do
		context "With valid attribute" do
			it "should create a new property" do
				post :create, property: {name: "A new property"}
				property = JSON.parse(response.body, symbolize_names: true)
				expect(response).to have_http_status(:created)
				expect(response.location).to eq(property_url(property[:id]))
			end
		end
		context "With invalid attribute" do
			it "should return status 422 with errors" do
				post :create, property: {name: nil}
				property = JSON.parse(response.body, symbolize_names: true)
				expect(response.status).to eq(422)			
			end
		end
	end
	describe "Patch properties" do
		before do
			@property = Property.create(name: "A new property", province: "Kandal")
		end

		context "With valid attribute" do
			it "should update an exiting property" do
				patch :update, id: @property.id, property: {name: "Something else"}
				expect(@property.reload.name).to eq("Something else")
			end
		end

		context "With invalid attribute" do
			it "should return 422 status" do
				
				patch :update, id: @property.id, property: { name: nil }
				expect(response).to have_http_status(422)
			end
		end
	end
	describe "DELETE /properties/1" do
		it "delete existing property" do
			expect{
			delete :destroy, :id => 1
			}.to change(Property, :count).by(-1)
		end
	end

	describe "Authorization" do
		context "without correct credentials" do
			it "should return starts : Unorthorized" do
				get :exclusive
				expect(response).to have_http_status(401)
			end
		end

		context "with valid credentials" do
			
 			let(:encoded_credentials) { ActionController::HttpAuthentication::Basic.encode_credentials('foo', 'secret') }
			before do
				@request.env['HTTP_AUTHORIZATION'] = encoded_credentials
			end
			it "should return status :ok", :focus => true  do
				get :exclusive
				expect(response).to have_http_status(:ok)
				fetch = JSON.parse(response.body, symbolize_names: true)
				expect(fetch[:message]).to eq("Welcome to Devbootstrap") 
			end
		end
	end

end
