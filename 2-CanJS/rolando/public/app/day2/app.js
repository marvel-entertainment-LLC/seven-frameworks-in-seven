/***
 * Excerpted from "Seven Web Frameworks in Seven Weeks",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material, 
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose. 
 * Visit http://www.pragmaticprogrammer.com/titles/7web for more book information.
***/
var Bookmark = can.Model.extend({
  findAll: "GET /bookmarks",
  create: "POST /bookmarks",
  update: "PUT /bookmarks/{id}",
  destroy: "DELETE /bookmarks/{id}",
}, {
});
var Day2ListControl = BookmarkListControl.extend({
  view: "/app/day2/bookmark_list",

  init: function(element, options) {
    // save a reference to the eventHub observe
    this.eventHub = options.eventHub;
    // render the view on the element with the bookmarks as the model
    var view = options.view || this.view;
    element.html(view, this.getViewModel(options));
  },
  
  getViewModel: function(options) {
    return {bookmarks:options.bookmarks};
  },
  // retrieve the bookmark object from the <li> parent element
  getBookmark: function(el) {
    return el.closest("li").data("bookmark");
  },
  
  // handle the click on the delete button, destroy the bookmark
  ".delete click": function(el, evt) {
    this.getBookmark(el).destroy();
  },
  
  // handle the click on the edit button, trigger an editBookmark event
  ".edit click": function(el, evt) {
    can.trigger(this.eventHub, "editBookmark", this.getBookmark(el));
  },

  // Copy
  ".copy click": function(el, evt) {
    var bookmark = this.getBookmark(el);
    can.trigger(this.eventHub, "copyBookmark", {
      url: bookmark.attr('url'),
      title: bookmark.attr('title')
    });
  }

});
var Day2FormControl = BookmarkFormControl.extend({
  // Add properties here.
  BookmarkModel: Bookmark,
  view: "/app/day2/bookmark_form",

  init: function(element, options) {
    this.BookmarkModel.bind("created", function(evt, bookmark) { // (1)
      options.bookmarks.push(bookmark);
    });
    this.clearForm();
  },
  editBookmark: function(bookmark) { // (2)
    var view = this.options.view || this.view;
    this.element.html(view, bookmark);
    bookmark.bind("destroyed", this.clearForm.bind(this)); /* Have to bind to this otherwise it will run instead bookmark, making this = bookmark which has no clearForm. */
  },
  clearForm: function(data) { // (3)
    this.editBookmark(new this.BookmarkModel(data));
  },
  "{eventHub} editBookmark": function(eventHub, evt, bookmark) { // (4)
    this.editBookmark(bookmark);
  },
  "{eventHub} copyBookmark": function (eventHub, event, bookmarkData) {
    this.clearForm(bookmarkData);
  },
  ".save click": function(el, evt) {
    evt.preventDefault();
    var bookmark = el.data("bookmark");
    bookmark.attr(can.deparam(el.closest("form").serialize())); // (5)
    this.saveBookmark(bookmark);
  },
  ".clear click": function(el, evt) {
    evt.preventDefault();
    this.clearForm();
  }
});
var App_day2 = can.Construct.extend({
  init: function() {
    // Retrieve the bookmarks from the server
    Bookmark.findAll({}, function(bookmarks) {
      // Create the event hub observe
      var eventHub = new can.Observe({});
      // Create the options object with the event hub and the bookmarks
      var options = {eventHub:eventHub, bookmarks:bookmarks};

      // Create the control, attaching it to the element on the page
      // that has id="bookmark_list_container"
      new Day2ListControl("#bookmark_list_container", options);
	  
      // Create the bookmark form control (which we build in the
      // next section.)
      new Day2FormControl("#bookmark_form_container", options);
    });
  }
});
