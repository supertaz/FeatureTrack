# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_FeatureTrack_session',
  :secret      => 'da7b9aadca6dc257926fda0275fbd1a0c98601661e7e9ec2772d9237982a1b95998b02ef33089782942a9e2d2bb6f0bb7e30e37365ca80c25a2b39aedbbc7327'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
