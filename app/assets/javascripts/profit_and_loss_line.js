function profitAndLossLine(){
  var width = 960,
      height = 280,
      margin = {top: 15, right: 40, bottom: 20, left: 80};
      
  var chart = lineChart()
    .width(width - margin.right - margin.left)
    .height(height - margin.top - margin.bottom);
      
      
  function lineChart(){
    var width = 960,
        height = 300,
        timeFormat = d3.time.format("%H:%M:%S"),
        printTimeFormat = d3.time.format("%H:%M"),
        duration = 500,
        tickFormat = null;

        
    var vis = d3.select('#line_chart')
               .append('svg:svg')
                 .attr('width', width)
                 .attr('height', height)
               .append("svg:g")
                 .attr("transform", "translate(50, 20)");
        
    function line(){
      var pnl = 0.0, 
          max = 0.0, 
          min = 0.0;
      var firstExecutionTime = data[0].execution_time,
          lastExecutionTime = data[data.length - 1].execution_time;
          
      pnl = 0.0;
      $(data).each(function(i){
        pnl += this.execution_profit_and_loss;
        if(pnl > max) max = pnl;
        if(pnl < min) min = pnl;
      });
          
      var yScale = d3.scale.linear().domain([(min * 1.1), (max * 1.1)]).range([height, 0]);
      var xScale = d3.time.scale().domain([firstExecutionTime, lastExecutionTime]).range([0, width])
          
      var paths = vis.selectAll("path");
      paths.remove();
          
      var l = d3.svg.line()
        .x(function(d, i) { return xScale(d.execution_time);})
        .y(function(d, i){ return yScale(d.profit_and_loss);})
        .interpolate('linear');
          
          
      paths = vis.selectAll("path").data([data]);
          
      var pathsEnter = paths.enter().append("svg:path")
        .attr("d", l)
        .attr('class', 'pnl_line');
          
      vis.selectAll("g.tick_y").remove()
          
      var format = tickFormat || yScale.tickFormat(6);
          
      var ticks = vis.selectAll("g.tick_y")
        .data(yScale.ticks(6), function(d) {
              return (this.textContent || (format(d) + "$"));
        });
          
      var ticksEnter = ticks.enter().append("svg:g")
        .attr('transform', function (d) { return "translate(0," + yScale(d)+")"; })
        .attr("class", "tick_y");
            
      ticksEnter.append("svg:line")
        .attr('y1', 0)
        .attr('y2', 0)
        .attr('x1', 0)
        .attr('x2', width);
          
      ticksEnter.append("svg:text")
        .text(format)
        .attr('text-anchor', 'end')
        .attr('dy', 2)
        .attr('dx', -4)
          
      var ticksUpdate = ticks
        .transition()
        .duration(duration)
        .attr("transform", function (d) { return "translate(0," + yScale(d)+")"; })
        .selectAll("text")
          .text(format);
          
      var ticksExit = ticks.exit()
        .transition()
        .duration(duration)
        .attr("transform", function (d) { return "translate(0,0)"; })
        .style("opacity", 1e-6)
        .remove();
          
          
      format = tickFormat || xScale.tickFormat(15);
          
      ticks = vis.selectAll("g.tick_x")
        .data(xScale.ticks(10), function(d) { 
              return this.textContent || printTimeFormat(d);
        });
          
          
      var ticksEnter = ticks.enter().append("svg:g")
        .attr('transform', function(d) { return "translate("+ xScale(d) + ", 0)"; })
        .attr('class', 'tick_x');
            
      ticksEnter.append("svg:line")
        .attr('y1', height + 15)
        .attr('y2', height + 5)
        .attr('x1', 0)
        .attr('x2', 0);
            
      ticksEnter.append("svg:text")
        .text(function(d){return printTimeFormat(d);})
        .attr('text-anchor', 'end')
        .attr('dy', height + 25)
        .attr('dx', 13);
          
          
      var ticksUpdate = ticks
        .transition()
        .duration(duration)
        .attr("transform", function (d) { return "translate("+ xScale(d) +",0)"; })
        .selectAll("text")
          .text(format);
          
      var ticksExit = ticks.exit()
        .transition()
        .duration(duration)
        .attr("transform", function (d) { return "translate(0,0)"; })
        .style("opacity", 1e-6)
        .remove();
          
      var points = vis.selectAll("g.point").data(data, function(d){ return d.id; });
          
      var pointsEnter = points.enter()
        .append("svg:g")
        .attr("transform", function(d){return "translate("+xScale(d.execution_time)+","+yScale(d.profit_and_loss)+")"})
        .attr('class', 'point');
            
        pointsEnter.append("svg:circle")
          .attr("class", function(d, i){return "point "+ d.side; })
          .attr("r", 4)
        .on('mouseover', function(){
          $(this).parent().find("text").show();
          d3.select(this).attr('r', 8);
        })
        .on('mouseout',  function(){
          $(this).parent().find("text").hide();
          d3.select(this).attr('r', 4);
        });
            
        pointsEnter.append("text")
          .attr('dx', -15)
          .attr('dy', -5)
          .attr('text-anchor', 'end')
          .attr('class', 'execution_modal')
          .text(function(d){
            return printTimeFormat(d.execution_time) + " "
              + d.symbol.toUpperCase() + " $" + d.execution_profit_and_loss;
          });
          
      var pointsUpdate = points;
          
      pointsUpdate.transition()
        .duration(duration)
        .attr("transform", function(d){return "translate("
          + xScale(d.execution_time)+","+yScale(d.profit_and_loss)+")"});
          
      var pointsExit = points.exit().transition()
        .style("opacity", 1e-6)
        .remove();
    }
        
    line.width = function(x) {
      if (!arguments.length) return width;
      width = x;
      return line;
    };
        
    line.height = function(x) {
      if (!arguments.length) return height;
      height = x;
      return line;
    };
        
    line.stockSelected = function(){
      var symbol = $(".stocks").find(".pressed").text().trim().toLowerCase(),
          opts = {};
          
      if(symbol != "") opts = {'symbol' : symbol};
          
      data = buildDataFromHTML(opts)
      vis.call(chart); 
    };
        
    line.tickFormat = function(x) {
      if (!arguments.length) return tickFormat;
      tickFormat = x;
      return bullet;
    };
        
    function buildDataFromHTML(opts){
      var d = [],
          pnl = 0.0,
          selector = ".execution";
          
      if(arguments.length){
        if(opts.hasOwnProperty('symbol')) selector += "." + opts.symbol;
        if(opts.hasOwnProperty('time_of_day')) selector += "." + opts.time_of_day;
      }
          
      $(selector).each(function(i){
        pnl += parseFloat($(this).find(".profit_and_loss").first().text().trim() || "0");
        d.push({
          'id' : $(this).find(".execution_id").val(),
          'execution_time' : timeFormat.parse($(this).find(".execution_time").first().text().trim()),
          'execution_profit_and_loss' : parseFloat($(this).find(".profit_and_loss").first().text().trim() || "0"),
          'profit_and_loss' : pnl,
          'side': $(this).find(".side").text().trim().toLowerCase(),
          'symbol': $(this).find(".symbol").text().trim().toLowerCase()
        });
      });
      return d;
    }
        
    var data = buildDataFromHTML();
        
    return line;
  }
      
  chart.call(chart);
      
  $("#bullet_chart").bind("bullet_chart.symbol_changed", function(e){
    chart.stockSelected();
  });
      
  return chart;
}
