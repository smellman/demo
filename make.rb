require 'json'

def lines
  s = ''
  [
    %w{AN010 #000 1}, # railway
    %w{AN500 #e7b2a8 2}, # raliway network link
    %w{AP030 #ccc 1}, # road
    %w{AP050 #ccc 1}, # trail
    %w{AP500 #ccc 1}, # road network link
    %w{AQ040 #f00 2}, # bridge
    %w{AQ070 #5494a8 1}, # ferry route
    %w{AQ130 #f00 2}, # tunnel
    %w{BA010 #5494a8 1}, # coastline
    %w{BH140 #54a498 1}, # river
    %w{BH210 #5494a8 1}, # inland shoreline
    %w{BH502 #5494a8 1}, # watercourse
    %w{BI020 #aaf 2}, # dam
    %w{BI030 #aaf 2}, # lock
    %w{FA000 #f00 1}, # administrative boundary
    %w{XX500 #00f 1} # sea limit
  ].each {|r|
  s += <<-EOS
  map.addLayer({
    'id': '#{r[0]}',
    'type': 'line', 'source': 'globalmaps-vt', 'source-layer': '#{r[0]}',
    'layout': {'line-join': 'round', 'line-cap': 'round'},
    'paint': {
      'line-color': #{r[1] ? '\'' + r[1] + '\'' : 'randomColor()'},
      'line-width': #{r[2] ? r[2] : 1}
    }
  });
  EOS
  }
  s
end

def points
  s = ''
  [
    %w{AL020}, # builtup area
    %w{AL105}, # settlement
    %w{AN060}, # railroad yard
    %w{AP020}, # interchange
    %w{AQ062}, # crossing
    %w{AQ063}, # road intersection
    %w{AQ080}, # ferry site
    %w{AQ090}, # entrance / exit
    %w{AQ125}, # station
    %w{AQ135}, # vehicle stopping area
    %w{BH170}, # spring
    %w{BH503}, # hydrographic network node
    %w{BI029}, # dam
    %w{BI030}, # lock
    %w{GB005}, # airport
    %w{ZD040} # named location
  ].each {|r|
  s += <<-EOS
  map.addLayer({
    'id': '#{r[0]}-pt', 'type': 'symbol',
    'source': 'globalmaps-vt', 'source-layer': '#{r[0]}',
    'paint': {
      'text-color': #{r[1] ? '\'' + r[1] + '\'' : 'randomColor()'}
    },
    'layout': {
      'text-field': '*',
    }
  });
  EOS
  }
  s
end

def polygons
  s = ''
  [
    %w{AL020 #f00 0.3}, # builtup area
    %w{BA020 #e3f3f7 0.5}, # foreshore
    %w{BA030}, # island
    %w{BA040 #e3f3f7 0.8}, # water
    %w{BH000 #5494a8 0.8}, # inland water
    %w{BH080 #e3f3f7 0.8}, # lake / pond
    %w{BH130 #e3f3f7 0.8}, # reservoir
    %w{BJ030 #ccf 0.5}, # glacier
    %w{BJ100 #ccf 0.5}, # snow field
    %w{FA001 #fffcdb 0.1}, # administrative area
    %w{XX501 #ff0 0.8}, # landmask area
  ].each {|r|
  s += <<-EOS
  map.addLayer({
    'id': '#{r[0]}-pg', 'type': 'fill',
    'source': 'globalmaps-vt', 'source-layer': '#{r[0]}',
    'paint': {
      'fill-color': #{r[1] ? '\'' + r[1] + '\'' : 'randomColor()'},
      'fill-opacity': #{r[2] ? r[2] : 0.8}
    }
  });
  EOS
  }
  s
end

def mapboxgl(country, version)
  dst_path = "mapboxgl/#{country}#{version}.html"
  metadata = JSON::parse(File.read("../gm#{country}#{version}vt/metadata.json"))
  center = metadata['center']
  tiles_path = "https://globalmaps-vt.github.io/gm#{country}#{version}vt" +
    "/{z}/{x}/{y}.mvt"
  File.open(dst_path, 'w') {|w|
    w.print <<-EOS
<!DOCTYPE html>
<html>
<head>
<meta charset='utf-8' />
<title></title>
<meta name='viewport' content='initial-scale=1,maximum-scale=1,user-scalable=no' />
<script src='https://api.tiles.mapbox.com/mapbox-gl-js/v0.26.0/mapbox-gl.js'></script>
<link href='https://api.tiles.mapbox.com/mapbox-gl-js/v0.26.0/mapbox-gl.css' rel='stylesheet' />
<link href='https://www.mapbox.com/base/latest/base.css' rel='stylesheet' />
<style>
body { margin:0; padding:0; }
#map { position:absolute; top:0; bottom:0; width:100%; }
</style>
</head>
<body>
<div id='map'></div>
<script>
map = new mapboxgl.Map({
  container: 'map',
  // osm
  //style: 'https://gist.githubusercontent.com/smellman/d3cbc19d134d5283df73/raw/24aa928ac76056ab0e887d6a65484c1806765260/osm_mapbox_gl_example.json',
  //style: 'https://gist.githubusercontent.com/smellman/d3cbc19d134d5283df73/raw/a4bb13b44c36e9225f95c545cdedbe7513200d70/osm_mapbox_gl_example.json',
  // ort
  style: 'https://gist.githubusercontent.com/smellman/3f2956f096e7cc630c435e59b61bc910/raw/a44cbe910c1de3c7be6cb4c7fa8fb347ca41edc0/mapbox-gl-gsi-ort.json',
  //style: 'https://gist.githubusercontent.com/smellman/3f2956f096e7cc630c435e59b61bc910/raw/6339e4b3b93364829912f77863df958f00fa8ebb/mapbox-gl-gsi-ort.json',
  //style: 'https://gist.githubusercontent.com/smellman/3f2956f096e7cc630c435e59b61bc910/raw/38e4f41ed4ef295d48cd1d643a4fefdc3f3549b4/mapbox-gl-gsi-ort.json',
  center: [#{center[0]},  #{center[1]}], zoom: #{center[2]}, hash: true, maxZoom: 12
});
colors = [
  'FC49A3', 'CC66FF', '66CCFF', '66FFCC',
  '00FF00', 'FFCC66', 'FF6666', 'FF0000',
  'FF8000', 'FFFF66', '00FFFF'
];
function randomColor() {
  return '#' + colors[parseInt(Math.random() * colors.length)];
}
map.on('load', function () {
  map.addSource('globalmaps-vt', {
    tiles: ['#{tiles_path}'],
    type: 'vector', maxzoom: 8
  });
#{lines}
#{points}
#{polygons}
});
map.on('click', function(e) {
  var features = map.queryRenderedFeatures(e.point, {
    //layers: ['FA001-pg']
  });
  if (!features.length) return;
  var s = features.length + ' features.<br/>';
  for(var i in features) {
    var f_code = features[i].properties.f_code;
    s += f_code;
    if(f_code == 'FA001') {
      s += ' ' + features[i].properties.nam + ' ' + features[i].properties.laa;
    }
    s += '<br/>';
  }
  var feature = features[0];
  var popup = new mapboxgl.Popup()
    .setLngLat(map.unproject(e.point))
    .setHTML(s)
    .addTo(map);
});
</script>
</body>
</html>
    EOS
  }
end

def tangram(country, version)
end

Dir.glob('../*vt') {|path|
  next unless /^gm(.*?)(\d\d)vt$/.match File.basename(path)
  (country, version) = [$1, $2]
  mapboxgl(country, version)
  tangram(country, version)
}
