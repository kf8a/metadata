jQuery(document).ready(function() {
  
  var activeDot = 0;

  jQuery('.dot-graph').each(function() {
      var id = jQuery(this).attr('id');
      var current_div = this;
      jQuery.getJSON("/visualizations/" + id, function(json) {
        var dateFormat = pv.Format.date("%Y-%m-%d %H:%M:%S");
        json.forEach(function(d) {d.datetime = dateFormat.parse(d.datetime)});
        var h = 260;
        var w = 660;
        var margin = 40;
        var y = pv.Scale.linear(json, function(d) { return d.value}).range(0,h);
        var x = pv.Scale.linear(json, function(d){ return d.datetime}).range(0,w);
        var human_number = pv.Format.number().fractionDigits(0,2)
      
        var vis = new pv.Panel()
                        .canvas(current_div)
                        .margin(margin)
                        .width(w)
                        .height(h)
                        .event("mousemove", pv.Behavior.point());

        vis.add(pv.Rule)
          .data(y.ticks())
          .strokeStyle("#eee")
          .bottom(y)
          .anchor("left").add(pv.Label).text(y.tickFormat);

        vis.add(pv.Rule)
          .data(x.ticks())
          .strokeStyle("#eee")
          .left(x)
          .anchor("bottom").add(pv.Label).text(x.tickFormat);

        vis.add(pv.Label)
           .left(10 - margin)
           .top(h/2)
           .textAlign('center')
           .textAngle(-Math.PI / 2)
           .text(jQuery(current_div).data('ylabel'));
        
          /* .fillStyle( pv.rgb(121,173,210) ) */
        vis.add(pv.Dot)
          .data(json)
          .left(function(d) {return x(d.datetime) })
          .bottom(function(d) { return y(d.value) })
		      .fillStyle(function() {return activeDot == this.index ? pv.rgb(250,230,5) : pv.rgb(121,172,210,0.2)})
          .event("point", function() {activeDot = this.index; return vis})
          .add(pv.Label)
          .text(function(d) {return human_number(d.value)})
          .textAlign('center')
          .visible(function() {return  activeDot == this.index} );

        vis.root.render();
      });
    });

    jQuery('.area-graph').each(function() {
    var id = jQuery(this).attr('id');

    var current_div = this;
    jQuery.getJSON("/visualizations/" + id, function(json){
      var dateFormat = pv.Format.date("%Y-%m-%d %H:%M:%S");
      json.forEach(function(d) {d.datetime = dateFormat.parse(d.datetime)});
      var h = 260;
      var w = 360;
      var margin = 40;
      var y = pv.Scale.linear(json, function(d) { return d.value}).range(0,h);
      var x = pv.Scale.linear(json, function(d){ return d.datetime}).range(0,w);
      var vis = new pv.Panel()
      .canvas(current_div)
      .margin(margin)
      .width(w)
      .height(h);

      vis.add(pv.Rule)
        .data(y.ticks())
        .strokeStyle("#eee")
        .bottom(y)
        .anchor("left").add(pv.Label).text(y.tickFormat);

      vis.add(pv.Rule)
        .data(x.ticks())
        .strokeStyle("#eee")
        .left(x)
        .anchor("bottom").add(pv.Label).text(x.tickFormat);

        vis.add(pv.Label)
           .left(10 - margin)
           .top(h/2)
           .textAlign('center')
           .textAngle(-Math.PI / 2)
           .text(jQuery(current_div).data('ylabel'));

      vis.add(pv.Area)
        .data(json)
        .left(function(d) {return x(d.datetime) })
        .height(function(d) { return y(d.value) })
        .fillStyle("rgb(121,173,210)")
        .bottom(1);

      vis.root.render();
    });
  });

  jQuery('.bar-graph').each(function() {
    var id = jQuery(this).attr('id');

    var current_div = this;
    jQuery.getJSON("/visualizations/" + id, function(json){
      var dateFormat = pv.Format.date("%Y-%m-%d %H:%M:%S");
      json.forEach(function(d) {d.datetime = dateFormat.parse(d.datetime)});
      var h = 260,
          w = 360,
          y = pv.Scale.linear(json, function(d) { return d.value}).range(0,h),
          x = pv.Scale.linear(json, function(d){ return d.datetime}).range(0,w);
      var margin = 40;
      var vis = new pv.Panel()
      .canvas(current_div)
      .margin(margin)
      .width(w)
      .height(h);

      vis.add(pv.Rule)
        .data(y.ticks())
        .strokeStyle("#eee")
        .bottom(y)
        .anchor("left").add(pv.Label).text(y.tickFormat);

      vis.add(pv.Rule)
        .data(x.ticks())
        .strokeStyle("#eee")
        .left(x)
        .anchor("bottom").add(pv.Label).text(x.tickFormat);

        vis.add(pv.Label)
           .left(10 - margin)
           .top(h/2)
           .textAlign('center')
           .textAngle(-Math.PI / 2)
           .text(jQuery(current_div).data('ylabel'));

      vis.add(pv.Panel)
      .add(pv.Bar)
      .data(json)
        .left(function(d) {return x(d.datetime) })
        .height(function(d) { return y(d.value) })
        .width(3)
        .bottom(0);

      vis.root.render();
    });
  });


  jQuery('.bubble-graph').each(function() {
    var id = jQuery(this).attr('id');

    var current_div = this;
    jQuery.getJSON("/visualizations/" + id, function(data){

      var nested = pv.nest(data)
          .key(function(d) {return d.year})
          .entries();
          
      var categories = pv.nest(data)
        .key(function(d) {return d.category})
        .entries();

      var species = categories.map(function(d) {return d.key});

      var width      = 400;
      var height     = species.length * 14;

      var speciesScale = pv.Scale.ordinal(species.sort().reverse()).split(0, height);
      var yearScale = pv.Scale.linear(pv.min(data.map(function(d) {return d.year})),pv.max(data.map(function(d) {return d.year}))).range(0, width);
      var biomassScale = pv.Scale.linear(0, pv.max(data.map(function(d) {return d.value}))).range(0,500);
          
      var activeDot = 0;

      var human_number = pv.Format.number().fractionDigits(0,2)
          
      var vis = new pv.Panel()
                    .canvas(current_div)
                    .width(width)
                    .height(height)
                    .right(50)
                    .top(10)
                    .bottom(20)
                    .left(380)
                    .event("mousemove", pv.Behavior.point());
        
        vis.add(pv.Rule)
         .data(species)
         .bottom(speciesScale)
         .strokeStyle("#eee")
         .anchor("left")
         .add(pv.Label)
         .left(-20)
         .textAlign('right')
         .font('10pt normal');
        
        vis.add(pv.Rule)
          .data(yearScale.ticks())
          .strokeStyle("#eee")
          .left(yearScale)
          .anchor('top')
          .add(pv.Label);
        
        vis.add(pv.Rule)
          .data(yearScale.ticks())
          .strokeStyle("#eee")
          .left(yearScale)
          .anchor('bottom')
          .add(pv.Label);
          
        vis.add(pv.Dot)
          .data(data)
          .bottom(function(d) {return speciesScale(d.category)})
          .left(function(d) {return yearScale(d.year)})
          .size(function(d) {return biomassScale(d.value)} )
          .fillStyle(function() {return activeDot == this.index ? pv.rgb(250,230,5) : pv.rgb(250,230,5,0.2)})
          .strokeStyle(pv.rgb(0,0,255,0.2));
          
          vis.add(pv.Dot)
            .data(data)
            .bottom(function(d) {return speciesScale(d.category)})
            .left(function(d) {return yearScale(d.year)})
            .radius(function() {return activeDot == this.index ? 1 : 0.2} )
            .fillStyle('black')
            .event("point", function() {activeDot = this.index; return vis})
            .add(pv.Label)
            .text(function(d) {return d.year + ": " + human_number(d.value) + " g/m2"})
            .textAlign('center')
            .visible(function() {return activeDot == this.index});

       
          vis.render();
    });
  });
});
