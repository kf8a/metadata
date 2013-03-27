class ScoreGraph

  score: (data, max_count) ->
    if d.count < d.approved
      - d.approved/max_count
    else
      d.count/max_count

  render: (el) ->
    data = $(el).data('scores')
    return unless data?

    width = 800

    x = d3.scale.linear()
      .domain([1987,2014])
      .range([0,width])
      .clamp(true)

    max_count = d3.max(data, (d) -> d.count )

    data.forEach( (d) ->
      if d.count > d.approved
        d.score =  (d.approved - d.count)/max_count
      else
        d.score = d.count/max_count)

    z = d3.scale.sqrt()
      .domain([-1, 0,1])
      .range(['blue','white','limegreen'])

    svg = d3.select(el)
      .append('svg:svg')
      .attr('class', 'score')
      .attr('width', width)
      .attr('height', 30)


    svg.selectAll('circle')
      .data(data)
      .enter()
      .append('circle')
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
      .attr('dx', -7)
      .attr('y', 19)
      .text((d) -> d.year.toString().substr(-2))

    years = d3.range(1988,2013)

    svg.selectAll('dots')
      .data(years)
      .enter()
      .append('circle')
      .attr('class','dots')
      .attr('cy',15)
      .attr('cx', (d) -> x(d))
      .attr('r', 2)
      .attr('fill', 'grey')

jQuery -> 
  graph = new ScoreGraph
  graph.render(score) for score in  $('.score-data')
