
var bookmarks = [
    { url: "http://one.com", "title": "one"},
    { url: "http://two.com", "title": "two"}
];

var viewModel = {bookmarks: bookmarks};
var element = $("#target");

// render view by call can.view
element.html(can.view("/app/base/bookmark_list", viewModel));

// can.view is implictly called
element.html("/app/base/bookmark_list", viewModel);


// bookmarks is now a list of observes
var bookmark_list = new can.Observe.List([
    { url: "http://one.com", "title": "one"},
    { url: "http://two.com", "title": "two"}
]);

var viewModel = {bookmarks: bookmarks};
$("#target").html("/app/base/bookmark_list", viewModel);

bookmarks[0].attr("title", "Uno");
bookmarks.push({url:"http://three.com", title:"Three"});