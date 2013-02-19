class User
  include DataMapper::Resource

  property :id,         Serial
  property :username,   String,  :required => true, :length => 0..100
  property :expires_at, Time

  has n, :identities

  # Find a user that has an identity of the specified provider and uid.
  # If not found, returns a new (unsaved) temporary user.
  def self.for_identity(provider, uid)
    u = User.first_or_new(:identities => [:provider => provider, :uid => uid])
    unless u.saved?
      u.expires_at = Time.now + 1.day
      u.username = "Temporary Account"
    end
    u
  end
end
