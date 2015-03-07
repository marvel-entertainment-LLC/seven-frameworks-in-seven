
# Assigment : bookmark list in order of creation date
def get_bookmarks_by_date
  Bookmark.all(:order => [ :id.desc ])
end
get "/bookmarksbydate" do #could use a better route
  content_type :json
  get_bookmarks_by_date.to_json
end