$(function(){
    var pnlBullet = null,
        pnlLine = null;
    
    $("#bullet_chart").bind('bullet_chart.ready', function(){ pnlLine = profitAndLossLine(); });
    
    pnlBullet = profitAndLossBullet();

    $(document).ready(function(){
      $(".stocks > .button").bind('click', function(e){
        if(!$(this).hasClass("pressed")){
          $(".button.pressed").toggleClass("pressed");
        }

        $(this).toggleClass("pressed");
    
        var url = $(this).hasClass("pressed") ? 
          (window.location + "/" + $(this).text().trim() + "/statistics.json") : 
          (window.location + "/statistics.json")
        
        d3.json(url, function(data){
          pnlBullet.chart().duration(500);
      
          //removing old text elements
          d3.select("#bullet_chart").selectAll("g[text-anchor]").remove();
      
          var vis = d3.select("#bullet_chart").selectAll("svg");
        
          vis.datum(function a(d, i){ d = data.statistics[i]; return d; })
            .select("g[transform]").call(pnlBullet.chart());
          
          pnlBullet.titlesFunction()(vis.select("g[transform]"));
          pnlBullet.measuresHoverFunction()(vis, data.statistics)

          $("#bullet_chart").trigger("bullet_chart.symbol_changed")
        });
      });
    });
    
});
