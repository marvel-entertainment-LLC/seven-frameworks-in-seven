var app = angular.module("basicApp", []);

app.service("greeter", function(){
    this.name = '';
    this.greeting = function(){
        return (this.name)
            ? ("Hello, "+ this.name + "!") : "";
    };
});

app.controller("basicController", function($scope,greeter){
    $scope.greeter = greeter;
});