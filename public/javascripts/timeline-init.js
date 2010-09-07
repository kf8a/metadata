var tl;
jQuery(document).ready(function() {
	var eventSource = new Timeline.DefaultEventSource();

	var bandInfos = [
	Timeline.createBandInfo({
		eventSource:    eventSource,
		date:           Date(),
		width:          "70%", 
		intervalUnit:   Timeline.DateTime.MONTH, 
		intervalPixels: 100
		}),
		Timeline.createBandInfo({
			overview: 			true, 
			eventSource:    eventSource,
			date:           Date(),
			width:          "30%", 
			intervalUnit:   Timeline.DateTime.YEAR, 
			intervalPixels: 200
		})

		];

		bandInfos[1].syncWith = 0;
		bandInfos[1].highlight = true;

		tl = Timeline.create(jQuery('#data-timeline')[0], bandInfos);
		tl.loadJSON('events/16', function(json, url) {eventSource.loadJSON(json, url)});
	});
