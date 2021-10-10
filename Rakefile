require './constants'

task :style do
  sh "ruby style.rb > docs/style.json"
end

task :optimize do
  sh "node ~/vt-optimizer/index.js -m #{MBTILES_PATH}"
end

task :deploy do
  files = Dir.glob("#{LOT_DIR}/*.mbtiles")
  files.select! {|path| !File.exist?("#{path}-journal")}
  sh <<-EOS
tile-join --force --output=#{MBTILES_PATH} \
--minimum-zoom=#{MINCOPYZOOM} --maximum-zoom=#{MAXZOOM} \
--no-tile-size-limit \
#{files.join(' ')}
  EOS
  sh <<-EOS
tile-join --force --output-to-directory=docs/zxy \
--minimum-zoom=#{MINCOPYZOOM} --maximum-zoom=#{MAXZOOM} \
--no-tile-size-limit --no-tile-compression \
#{MBTILES_PATH}
  EOS
  #sh "rm -v #{MBTILES_PATH}"
end

task :clean do
  sh "rm #{TMP_DIR}/*" unless Dir.glob("#{TMP_DIR}/*").size == 0
  sh "rm #{LOT_DIR}/*" unless Dir.glob("#{LOT_DIR}/*").size == 0
end

task :default do
  $notifier.ping "🐧#{pomocode} started"
  File.foreach(LIST_PATH) {|url|
    url = url.strip
    basename = File.basename(url.split('/')[-1], '.zip')
    next unless hostmatch(basename)
    tmp_path = "#{TMP_DIR}/#{basename}"
    dst_path = "#{LOT_DIR}/#{basename}.mbtiles"
    if File.exist?(dst_path) && !File.exist?("#{dst_path}-journal")
      $stderr.print "skip #{basename} because #{dst_path} is there.\n"
      next
    end
    cmd = "(\n"
    cmd += "curl -o #{tmp_path}.zip #{url} ; "
    cmd += "unar -f -o #{TMP_DIR} #{tmp_path}.zip 1>&2 ; \n"
    cmd += <<-EOS
Z=#{MAXZOOM} BASENAME=#{basename} ruby resample_pipeline.rb | \
pdal pipeline --stdin ;
    EOS
    MAXZOOM.downto(MINZOOM) {|z|
      cmd += <<-EOS
Z=#{z} BASENAME=#{basename} GDAL_DATA=#{GDAL_DATA} ruby text_pipeline.rb | \
pdal pipeline --stdin | \
Z=#{z} ruby togeojson.rb ;
      EOS
    }
    tippecanoe = <<-EOS
tippecanoe \
--projection=EPSG:3857 \
--minimum-zoom=#{MINCOPYZOOM} \
--maximum-zoom=#{MAXZOOM} \
--force \
--output=#{dst_path} \
--no-tile-size-limit \
--no-feature-limit 
    EOS
    #tippecanoe = "cat > a.txt"
    cmd += <<-EOS
) | \n#{tippecanoe.strip} ;
    EOS
    sh cmd
    sh "rm -v #{TMP_DIR}/#{basename}*"
    $notifier.ping "💫#{pomocode} #{basename} #{File.size(dst_path)}"
  }
  $notifier.ping "✨#{pomocode} finished"
end
