var answers = new can.Observe.List([
	{
		text:"CanJS API Documentation",
		url:"http://canjs.com/docs/index.html"
	},
	{
		text:"CanJS Forum",
		url:"https://forum.javascriptmvc.com/canjs"
	},
	{
		text:"CanJS TodoMVC",
		url:"http://todomvc.com/examples/canjs/"
	}
]);
$("#result").html(can.view("/day1/base/answers", {
	answers: answers
}));