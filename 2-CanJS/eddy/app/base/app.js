
var Bookmark = can.Model.extend({
    findAll: "GET /bookmarks",
    create: "POST /bookmarks",
    update: "PUT /bookmarks/{id}",
    destroy: "DELETE /bookmarks/{id}"
});