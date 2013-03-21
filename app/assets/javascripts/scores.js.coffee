class ScoreGraph
  render: (el) ->
    data = $(el).data('scores')

    width = 1000

    x = d3.scale.linear()
      .domain([1980,2015])
      .range([0,width])
      .clamp(true)

    z = d3.scale.sqrt()
      .domain([0,1])
      .range(['white','green'])

    svg = d3.select(el)
      .append('svg:svg')
      .attr('class', 'score')
      .attr('width', width)
      .attr('height', 30)

    svg.selectAll('circle')
      .data(data)
      .enter().append('circle')
      .attr('class','circle')
      .attr('cy',15)
      .attr('cx', (d) -> x(d.year))
      .attr('r', 14)
      .attr('stroke', 'black')
      .attr('fill', (d) -> z(d.score))

    svg.selectAll('year')
      .data(data)
      .enter().append('text')
      .attr('class','year')
      .attr('x', (d) -> x(d.year))
      .attr('dx', -8)
      .attr('y', 19)
      .text((d) -> d.year.toString().substr(-2))

jQuery -> 
  graph = new ScoreGraph
  graph.render(score) for score in  $('.score-data')
