class ScoreGraph {
  score(data, max_count) {
    if (data.count < data.approved) {
      return -data.approved / max_count;
    } else {
      return data.count / max_count;
    }
  }

  render(el) {
    var data = $(el).data('scores');
    if (!data) return;

    var width = 800;
    var current_year = new Date().getFullYear();
    var x = d3.scale.linear()
      .domain([1987, current_year])
      .range([0, width])
      .clamp(true);

    var max_count = d3.max(data, function(d) { return d.count; });

    data.forEach(function(d) {
      if (d.count > d.approved) {
        d.score = (d.approved - d.count) / max_count;
      } else {
        d.score = d.count / max_count;
      }
    });

    var z = d3.scale.sqrt()
      .domain([-1, 0, 1])
      .range(['blue', 'white', 'limegreen']);

    var svg = d3.select(el)
      .append('svg')
      .attr('class', 'score')
      .attr('width', width)
      .attr('height', 30);

    svg.selectAll('circle')
      .data(data)
      .enter()
      .append('circle')
      .attr('class', 'circle')
      .attr('cy', 15)
      .attr('cx', function(d) { return x(d.year); })
      .attr('r', 14)
      .attr('stroke', 'black')
      .attr('fill', function(d) { return z(d.score); });

    svg.selectAll('text.year')
      .data(data)
      .enter()
      .append('text')
      .attr('class', 'year')
      .attr('x', function(d) { return x(d.year); })
      .attr('dx', -7)
      .attr('y', 19)
      .text(function(d) { return d.year.toString().substr(-2); });

    var years = d3.range(1988, 2013);

    svg.selectAll('circle.dots')
      .data(years)
      .enter()
      .append('circle')
      .attr('class', 'dots')
      .attr('cy', 15)
      .attr('cx', function(d) { return x(d); })
      .attr('r', 2)
      .attr('fill', 'grey');
  }
}

$(document).ready(function() {
  var graph = new ScoreGraph();
  $('.score-data').each(function() {
    graph.render(this);
  });
});

