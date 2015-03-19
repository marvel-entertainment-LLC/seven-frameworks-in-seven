/***
 * Excerpted from "Seven Web Frameworks in Seven Weeks",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material, 
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose. 
 * Visit http://www.pragmaticprogrammer.com/titles/7web for more book information.
***/

var Day3BookmarkFormControl = TaggedBookmarkFormControl.extend({
  'input keyup': function (el) {
    var bookmark = $('button.save').data('bookmark');
    bookmark.attr(can.deparam(el.serialize()));
  }
});
var App_day3 = can.Construct.extend({
  init: function() {
    var filterObject = new can.Observe({
      filterTag: ""
    });
    var filterFunction = function(bookmark) {
      var tagList = bookmark.attr("tagList");
      var filterTag = filterObject.attr("filterTag");
      var noFilter = (!filterTag) || (filterTag.length == 0);
      var tagListContainsFilterTag = tagList && tagList.indexOf(filterTag) > -1;
      return noFilter || tagListContainsFilterTag;
    };

    TaggedBookmark.findAll({}, function(bookmarks) {

      bookmarks.comparator = 'title';
      console.log(bookmarks);
      // bookmarks = bookmarks.sort();

      var eventHub = new can.Observe({});
      var options = {eventHub:eventHub, bookmarks:bookmarks,
        filterObject:filterObject};

      var filtered = bookmarks.filter(filterFunction);

      var formView = "/app/tagfilter/bookmark_form";
      var formOptions = can.extend({}, options, {view:formView});

      var filteredOptions = can.extend({}, options, {bookmarks:filtered,
        view: "/app/day3/bookmark_list"});

      new BookmarkListControl("#bookmark_list_container", filteredOptions);
      new Day3BookmarkFormControl("#bookmark_form_container", formOptions);
      new TagListControl("#tag_list_container",
        can.extend(options, {view:"/app/day3/tag_list.ejs"}));
      new TagFilterControl("#filter_container",
        can.extend(options, {view:"/app/routing/tag_filter"}));
      new RoutingControl(document.body, options);
    });
  }
});
