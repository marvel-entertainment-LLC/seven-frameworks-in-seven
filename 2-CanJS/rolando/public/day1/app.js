var answers = new can.Observe.List([
	{
		text:"API Documentation",
		url:"http://canjs.com/docs/index.html"
	},
	{
		text:"Forum",
		url:"https://forum.javascriptmvc.com/canjs"
	},
	{
		text:"TodoMVC",
		url:"http://todomvc.com/examples/canjs/"
	},
	{
		text:"jsfiddle Canjs jQuery Template",
		url:"http://jsfiddle.net/donejs/qYdwR/"
	},
	{
		text:"jsfiddle roshow fork",
		url:"http://jsfiddle.net/roshow/2kLLes7c/"
	}
]);
$("#result").html(can.view("/day1/base/answers", {
	answers: answers
}));