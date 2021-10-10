require './constants'
require 'yaml'
require 'json'

z = ENV['Z'].to_i
spacing = (BASE ** (Z_ONE_METER - z)).to_f
basename = ENV['BASENAME']
#src_path = "#{TMP_DIR}/#{basename}-#{z}.las"
src_path = "#{TMP_DIR}/#{basename}-#{MAXZOOM}.las"

pipeline = <<-EOS
pipeline: 
  - 
    filename: #{src_path}
    type: readers.las
    spatialreference: "EPSG:6676"
  -
    type: filters.reprojection
    out_srs: "EPSG:3857"
  -
    type: writers.text
    format: csv
    filename: STDOUT
EOS

print JSON.dump(YAML.load(pipeline))
