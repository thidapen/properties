json.array!(@properties) do |property|	
	json.extract! property, :id, :name, :province	
	json.message I18n.t('property_message', province: property.province)	
end