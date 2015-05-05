/***
 * Excerpted from "Seven Web Frameworks in Seven Weeks",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material, 
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose. 
 * Visit http://www.pragmaticprogrammer.com/titles/7web for more book information.
***/
(function(app) {
  app.factory("TaggedBookmarks", function($resource) {
    return $resource("/bookmarks/:tag");
  });
  app.factory("bookmarks", function(TaggedBookmarks) {
    return TaggedBookmarks.query();
  });

  // app.factory("bookmarks", function() {
  //   return [];
  // });


  app.controller("Day1FormController", function($http, $scope, bookmarks) {
    $scope.tags = {};

    //$scope.bookmarks = bookmarks;
    //$scope.tags = 'none';
    $scope.bookmarksByTags = function() {
      var tag = $scope.tags.list;
      console.log('tag.list = ' + tag);
      var data = TaggedBookmarks.get({tag: x}, function(){
        console.log('data success!');
      });
      // $http.get('/bookmarks/'+ tag).success(function(data){
      //   console.log(data);
      //   bookmarks = data;
      // });

    }
    
    $scope.bookmarksByTags = function() {
      
    }
    $scope.showScope = function(){
      console.log($scope);
    }
  });

  // app.controller("Day1ListController", function($scope) {
  //   console.log('Day1ListController called');
  // });

  
})(angular.module("App_day1", ["ngResource"]));
