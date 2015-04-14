
var Bookmark = can.Model.extend({
    findAll: "GET /bookmarks",
    create: "POST /bookmarks",
    update: "PUT /bookmarks/{id}",
    destroy: "DELETE /bookmarks/{id}"
});

// Day 2
var BookmarkListControl = can.Control.extend({
    view: "/app/base/bookmark_list",

    init: function(element, options) {
        // save a ref to eventHub observe
        this.eventHub = options.eventHub;
        // render view of the elem with bookmarks as the model
        var view = options.view || this.view;
        element.html(view, this.getViewModel(options));
    },

    getViewModel: function(options) {
        return { bookmarks: options.bookmarks };
    },

    // retrieve the bookmark obj from li parent elem
    getBookmark: function(el) {
        return el.closest("li").data("bookmark");
    },

    // handle the delete button click
    ".delete click": function(el, evt) {
        this.getBookmark(el).destroy();
    },

    // handle edit button click
    ".edit click": function(el, evt) {
        can.trigger(this.eventHub, "editBookmark", this.getBookmark(el));
    }
});

var App_base = can.Construct.extend({
    init: function() {
        // retrive the bookmarks from server
        Bookmark.findAll({}, function(bookmarks) {
            // create the event hub observe
            var eventHub = new can.Observe({});
            // create the options obj with eventhub and bookmarks
            var options = {eventHub: eventHub, bookmarks: bookmarks};

            // create the control, attach it to the elem on page
            // that has id = "bookmark_list_container"
            new BookmarkListControl("#bookmark_list_container", options);

            // create the bookmark form control
            new BookmarkFormControl("#bookmark_form_container", options);
        });
    }
});