class Redis
  def cache(key, expire = nil)
    value = get(key)
    return JSON.parse(value) if value
    return nil unless block_given?
    value = yield(self)
    return nil unless value
    set(key, value.to_json)
    expire(key, expire) if expire.to_i > 0
    value
  end
end
