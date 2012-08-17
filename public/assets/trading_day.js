$(function(){
    var pnlBullet = null,
        pnlLine = null;
    
    function profitAndLossBullet(){
      var width = 960,
          height = 60,
          margin = {top: 15, right: 40, bottom: 20, left: 80};

      var chart = bulletChart()
          .width(width - margin.right - margin.left)
          .height(height - margin.top - margin.bottom);

      d3.json(window.location + "/statistics.json", function(data) {
        var vis = d3.select("#bullet_chart").selectAll("svg")
            .data(data.statistics)
          .enter().append("svg")
            .attr("class", "bullet")
            .attr("width", width)
            .attr("height", height)
          .append("g")
            .attr("transform", "translate(" + margin.left + "," + margin.top + ")")
            .call(chart);

        setTitleAndFigure(vis);
  
        bindMeasuresHover(vis, data.statistics);
        $("#bullet_chart").trigger("bullet_chart.ready");
      });
     
      // Chart design based on the recommendations of Stephen Few. Implementation
      // based on the work of Clint Ivy, Jamie Love, and Jason Davies.
      // http://projects.instantcognition.com/protovis/bulletchart/
      function bulletChart() {
        var orient = "left",
            reverse = false,
            duration = 0,
            measures = bulletMeasures,
            width = 960,
            height = 60,
            tickFormat = null;

        // For each small multiple…
        function bullet(g) {
          g.each(function(d, i) {
            var key_values = measures.call(this, d, i),
                title = d.title,
                g = d3.select(this);
          
            g.property("data_index", i)
      
            var measurez = key_values.values.slice()
              .sort(function(a, b) {
                return ((Math.abs(a) < Math.abs(b)) ? - 1 : ((Math.abs(a) > Math.abs(b)) ? 1 : 0))
              })
              .reverse();
      
            var absMeasurez = []
      
            $.each(measurez, function(d, i){ absMeasurez.push(Math.abs(i)); })
      
            // Compute the new x-scale.
            var x1 = d3.scale.linear()
                .domain([0, Math.max.apply(Math, absMeasurez)])
                .range(reverse ? [width, 0] : [0, width]);
          

            // Retrieve the old x-scale, if this is an update.
            var x0 = this.__chart__ || d3.scale.linear()
                .domain([0, Infinity])
                .range(x1.range());

      
            // Stash the new scale.
            this.__chart__ = x1;

            // Derive width-scales from the x-scales.
            var w0 = bulletWidth(x0),
                w1 = bulletWidth(x1);
      

            // Update the measure rects.
            var measure = g.selectAll("rect.measure")
                .data(measurez)
      
            measure.enter().append("svg:rect")
                .attr("class", function(v, i) { return "measure " + title + " " + key_values.keys[key_values.values.indexOf(v)]; })
                .property("value", function(v, i){ return v;})
                .attr("width", w0)
                .attr("height", height / 3)
                .attr("x", reverse ? x0 : 0)
                .attr("y", height / 3)
              .transition()
                .duration(duration)
                .attr("width", w1)
                .attr("x", reverse ? x1 : 0);

            measure.transition()
                .attr("class", function(v, i) { return "measure " + title + " " + key_values.keys[key_values.values.indexOf(v)]; })
                .duration(duration)
                .attr("width", w1)
                .attr("height", height / 3)
                .attr("x", reverse ? x1 : 0)
                .attr("y", height / 3);
      
            // Compute the tick format.
            var format = tickFormat || x1.tickFormat(8);
      
      
            // Update the tick groups.
            var tick = g.selectAll("g.tick")
                .data(x1.ticks(8), function(d) {
                  return this.textContent || format(d);
                });
            
            // Initialize the ticks with the old scale, x0.
            var tickEnter = tick.enter().append("svg:g")
                .attr("class", "tick")
                .attr("transform", bulletTranslate(x0))
                .style("opacity", 1e-6);
            
            
            tickEnter.append("svg:line")
                .attr("y1", height)
                .attr("y2", height * 7 / 6);
            
            
            tickEnter.append("svg:text")
                .attr("text-anchor", "middle")
                .attr("dy", "1em")
                .attr("y", height * 7 / 6)
                .text(format);
            
            
            // Transition the entering ticks to the new scale, x1.
            tickEnter.transition()
                .duration(duration)
                .attr("transform", bulletTranslate(x1))
                .style("opacity", 1);
            
            
            // Transition the updating ticks to the new scale, x1.
            var tickUpdate = tick.transition()
                .duration(duration)
                .attr("transform", bulletTranslate(x1))
                .style("opacity", 1);
            
            
            tickUpdate.select("line")
                .attr("y1", height)
                .attr("y2", height * 7 / 6);
            
            tickUpdate.select("text")
                .attr("y", height * 7 / 6);
            
            // Transition the exiting ticks to the new scale, x1.
            tick.exit().transition()
                .duration(duration)
                .attr("transform", bulletTranslate(x1))
                .style("opacity", 1e-6)
                .remove();
          });
          d3.timer.flush();
        }

        // left, right, top, bottom
        bullet.orient = function(x) {
          if (!arguments.length) return orient;
          orient = x;
          reverse = orient == "right" || orient == "bottom";
          return bullet;
        };

        // ranges (bad, satisfactory, good)
        bullet.ranges = function(x) {
          if (!arguments.length) return ranges;
          ranges = x;
          return bullet;
        };

        // markers (previous, goal)
        bullet.markers = function(x) {
          if (!arguments.length) return markers;
          markers = x;
          return bullet;
        };

        // measures (actual, forecast)
        bullet.measures = function(x) {
          if (!arguments.length) return measures;
          measures = x;
          return bullet;
        };

        bullet.width = function(x) {
          if (!arguments.length) return width;
          width = x;
          return bullet;
        };

        bullet.height = function(x) {
          if (!arguments.length) return height;
          height = x;
          return bullet;
        };

        bullet.tickFormat = function(x) {
          if (!arguments.length) return tickFormat;
          tickFormat = x;
          return bullet;
        };

        bullet.duration = function(x) {
          if (!arguments.length) return duration;
          duration = x;
          return bullet;
        };
  
        function bulletMeasures(d) {
          var kv = {"keys": [], "values": []};
          $.each(d.breakdown, function(k, v) {
            kv.keys.push(k);
            kv.values.push(v);
          })
          return kv;
        }

        function bulletTranslate(x) {
          return function(d) { return "translate(" + x(d) + ",0)"; };
        }

        function bulletWidth(x) {
          var x0 = x(0);
          return function(d) { return Math.abs(x(d) - x0); };
        }
  
        return bullet;
      };
      
      function bindMeasuresHover(vis, data_array){
        vis.selectAll("rect").on("mouseover", function(d, i){
          var str = ((d3.select(this.parentNode).property("data_index") != 1) ? d + "$" : d);

          d3.select(this).transition()
            .duration(250)
            .attr("height", 13.3334)
            .attr("y", 5.1667);
    
          d3.select(this.parentNode).selectAll("text.title")
            .transition()
            .text(stringify_key(this.className.animVal.split(" ")[2]));
    
          d3.select(this.parentNode).selectAll("text.figure")
            .transition()
            .text(str);
        });
        vis.selectAll("rect").on("mouseout", function(d, i){
          var data = data_array[d3.select(this.parentNode).property("data_index")];
          d3.select(this).transition()
            .attr("height", 8.3334)
            .attr("y", 8.3334);
    
          d3.select(this.parentNode).selectAll("text.title")
            .transition()
            .text(stringify_key(this.className.animVal.split(" ")[1]));
    
    
          d3.select(this.parentNode).selectAll("text.figure")
            .transition()
            .text(data.figure + data.unit);
        });
      }

      function setTitleAndFigure(vis){
        var figure = vis.append("g")
            .attr("text-anchor", "end")
            .attr("transform", "translate(-15," + (height - margin.top - 6) / 2 + ")");
      
        figure.append("text")
            .attr("class", "figure")
            .text(function(d) { return d.figure + d.unit; });  
  
        var title = vis.append("g")
            .attr("text-anchor", "end")
            .attr("transform", "translate("+ (520 - (margin.right)) +",-2)");
  
        title.append("text")
            .attr("class", "title")
            .text(function(d) { return stringify_key(d.title); });
      }
      
      $(document).ready(function(){
        $(".stocks > .button").bind('click', function(e){
          if(!$(this).hasClass("pressed")){
            $(".button.pressed").toggleClass("pressed");
          }

          $(this).toggleClass("pressed");
    
          // fading the corresponding executions
          if($(this).hasClass("pressed")){
            $(".execution").not("." + $(this).text().toLowerCase().trim()).fadeOut(500); 
            $(".execution." + $(this).text().toLowerCase().trim() + ":hidden").fadeIn(500); 
          }
          else{ 
            $(".execution").fadeIn(500); 
          }
    
    
          var url = $(this).hasClass("pressed") ? 
            (window.location + "/" + $(this).text().trim() + "/statistics.json") : 
            (window.location + "/statistics.json")
    
          d3.json(url, function(data){
            chart.duration(500);
      
            //removing old text elements
            d3.select("#bullet_chart").selectAll("g[text-anchor]").remove();
      
            var vis = d3.select("#bullet_chart").selectAll("svg");
        
            vis.datum(function a(d, i){ d = data.statistics[i]; return d; })
              .select("g[transform]").call(chart);
        
            setTitleAndFigure(vis.select("g[transform]"));
            bindMeasuresHover(vis, data.statistics)

            $("#bullet_chart").trigger("bullet_chart.symbol_changed")
          });
        });
      });
    
      return chart;
    }
    
    function profitAndLossLine(){
      var width = 960,
          height = 380,
          margin = {top: 15, right: 40, bottom: 20, left: 80};
      
      var chart = lineChart()
        .width(width - margin.right - margin.left)
        .height(height - margin.top - margin.bottom);
      
      
      function lineChart(){
        var width = 960,
            height = 400,
            timeFormat = d3.time.format("%H:%M:%S"),
            printTimeFormat = d3.time.format("%H:%M"),
            duration = 500;

        
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
          
          paths = vis.selectAll("path").data([data]);
          paths.enter().append("svg:path")
            .attr("d", 
              d3.svg.line()
                .x(function(d, i) { return xScale(d.execution_time);})
                .y(function(d, i){ return yScale(d.profit_and_loss);})
                .interpolate('linear')
            )
            .attr('class', 'pnl_line');
          
          var ticks = vis.selectAll("g.tick_y")
          ticks.remove();
          
          ticks = vis.selectAll("g.tick_y").data(yScale.ticks(6));
          
          var ticksEnter = ticks.enter().append("svg:g")
            .attr('transform', function (d) { return "translate(0," + yScale(d)+")"; })
            .attr("class", "tick_y");
            
          ticksEnter.append("svg:line")
            .attr('y1', 0)
            .attr('y2', 0)
            .attr('x1', 0)
            .attr('x2', width);
          
          ticksEnter.append("svg:text")
            .text(function(d){ return d + "$"; })
            .attr('text-anchor', 'end')
            .attr('dy', 2)
            .attr('dx', -4)
          
            
          ticks = vis.selectAll("g.tick_x");
          ticks.remove();
          
          ticks = vis.selectAll("g.tick_x").data(xScale.ticks(15));

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
            

          var points = vis.selectAll(".point")
              .data(data);
              
          var pointsEnter = points.enter()
            .append("svg:circle")
              .attr("class", function(d, i){return "point " + d.side; })
              .attr("r", 4)
              .attr("cx", function(d, i){return xScale(d.execution_time); })
              .attr("cy", function(d, i){return yScale(d.profit_and_loss); })
            .on('mouseover', function(){ d3.select(this).attr('r', 8);})
            .on('mouseout',  function(){ d3.select(this).attr('r', 4);})
            .on('click', function(d, i){ console.log (d, i)});
          
          var pointsUpdate = points.transition()
            .duration(duration)
            .attr("cx", function(d, i){return xScale(d.execution_time); })
            .attr("cy", function(d, i){return yScale(d.profit_and_loss); });
            
          var pointsExit = points.exit().transition()
            .duration(duration)
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
              'execution_time' : timeFormat.parse($(this).find(".execution_time").first().text().trim()),
              'execution_profit_and_loss' : parseFloat($(this).find(".profit_and_loss").first().text().trim() || "0"),
              'profit_and_loss' : pnl,
              'side': $(this).find(".side").text().trim().toLowerCase()
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
    
    function stringify_key(k){
      return k.replace(/_/g, " ");
    }
    
    $("#bullet_chart").bind('bullet_chart.ready', function(){ pnlLine = profitAndLossLine(); });
    
    pnlBullet = profitAndLossBullet();
});
