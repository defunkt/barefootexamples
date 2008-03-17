class RandomUser 
  acts_as_cached

  # Grab X random users in network Y
  def self.grab_from_network(id, options = {})
    sex = options[:sex] || ''
    key = regional_key(id, sex)
    ids = fetch_cache(key) || []

    limit = options[:limit] || 10
    (0...limit).to_a.map { ids.rand }
  end
end    