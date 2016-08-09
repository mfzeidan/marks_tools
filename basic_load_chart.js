$.ajax({
    type: 'GET',
    url: 'your php file',
    //dataType: JSON,
    success: function (data) {
        //alert(data);
        var jsonData = JSON.parse(JSON.stringify(data));
        //do something with chart here
        graphFunc(jsonData)
    },
    error: function (xhr, status, thrown) {
        console.log("jdlabla " + xhr + " " + status + " " + thrown);
    }
});

function ChartBasics() {

    var margin = {
            top: 30,
            right: 5,
            bottom: 20,
            left: 50
        },
        width = 500 - margin.left - margin.right,
        height = 250 - margin.top - margin.bottom,

        return {
            margin: margin,
            width: width,
            height: height
        };
}
////change the x and y to whatever values you're loading in
var	valueline = d3.svg.line()
	.x(function(d) { return x(d.xaxisvalue); })
	.y(function(d) { return y(d.yaxisvalue); });
////
function graphFunc(data){
     var basics = ChartBasics();

    var margin = basics.margin,
        width = basics.width,
        height = basics.height,
        colorBar = basics.colorBar,
        barPadding = basics.barPadding;

    var xScale = d3.scale.linear()
        .domain([0, data.length])
        .range([0, width]);

    var yScale = d3.scale.linear()
        .domain([0, d3.max(data, function (d) {
            return d.measure;
        })])
        .range([height, 0]);

    //Create SVG element

    var svg = d3.select("body")
        .append("svg")
        .attr("width", width + margin.left + margin.right)
        .attr("height", height + margin.top + margin.bottom)
        .attr("id", "Chart");

    var plot = svg
        .append("g")
        .attr("transform", "translate(" + margin.left + "," + margin.top + ")");
    .append("path")
		.attr("class", "line")
		.attr("d", valueline(data));

	// Add the X Axis
	plot.append("g")
		.attr("class", "x axis")
		.attr("transform", "translate(0," + height + ")")
		.call(xScale);

	// Add the Y Axis
	plot.append("g")
		.attr("class", "y axis")
		.call(yScale);
}