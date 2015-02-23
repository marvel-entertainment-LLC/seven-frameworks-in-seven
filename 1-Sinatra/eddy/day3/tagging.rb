
require "data_mapper"

class Tagging
    include DataMapper::Resource

    belongs_to  :tag,   :key => true
    belongs_to  :bookmark, :key => true
end
