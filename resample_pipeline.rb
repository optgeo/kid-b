require './constants'
require 'yaml'
require 'json'

z = ENV['Z'].to_i
spacing = (BASE ** (Z_ONE_METER - z)).to_f
basename = ENV['BASENAME']
src_path = "#{TMP_DIR}/#{basename}-#{z + 1}.las"
src_path = "#{TMP_DIR}/#{basename}.las" unless File.exist?(src_path)
dst_path = "#{TMP_DIR}/#{basename}-#{z}.las"
$stderr.print "#{spacing}m for #{dst_path} from #{src_path}\n"

    #spatialreference: "EPSG:6676"
pipeline = <<-EOS
pipeline: 
  - 
    filename: #{src_path}
    type: readers.las
  -
    type: filters.voxelcenternearestneighbor
    cell: #{spacing}
  -
    type: writers.las
    filename: #{dst_path}
EOS

print JSON.dump(YAML.load(pipeline))
