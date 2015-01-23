class Property < ActiveRecord::Base
	validates_presence_of :name, :province
end
