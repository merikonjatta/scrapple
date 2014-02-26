class User
  include DataMapper::Resource

  property :id,              Serial
  property :username,        String, :length => 100
  property :password_digest, String, :length => 255
  attr_accessor :password_confirmation

  has n, :identities

  # Find a user that has an identity of the specified provider and uid.
  # If not found, returns a new (unsaved) temporary user.
  def self.for_identity(provider, uid)
    u = User.first_or_new(:identities => [:provider => provider, :uid => uid])
    unless u.saved?
      u.username = "Temporary Account"
    end
    u
  end
end
