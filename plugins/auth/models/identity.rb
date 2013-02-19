class Identity
	include DataMapper::Resource

	property :id,        Serial, :required => true
	property :provider,  String, :required => true, :length => 0..100, :unique => [:provider, :uid]
	property :uid,       String, :required => true, :length => 0..100, :unique => [:provider, :uid]
	property :nickname,  String, :length => 100
	property :image_url, String, :length => 255
	property :email,     String, :length => 100

	belongs_to :user
end
