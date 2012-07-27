class Page
  include MongoMapper::Document

  key :name, String
  key :content, String
  key :salt, String

  before_create :create_salt

  def link_to_self
    "/#{@salt}/#{@name}"
  end

  private

  def create_salt
    @salt = '%.3i' % (rand * 999)
  end
end
