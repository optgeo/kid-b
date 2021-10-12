require './constants'

task :style do
  sh "ruby style.rb > docs/style.json"
end

task :optimize do
  files = (MINZOOM..MAXZOOM).map {|v| "#{TMP_DIR}/deploy-#{v}.mbtiles"}
  sh <<-EOS
tile-join --force --output=#{MBTILES_PATH} --no-tile-size-limit \
#{files.join(' ')} ; \
node ~/vt-optimizer/index.js -m #{MBTILES_PATH}
  EOS
end

task :deploy do
  $notifier.ping "🎆deploy started"
  tmp_dir = "#{TMP_DIR}/zxy"
  MAXZOOM.downto(MINZOOM) {|z|
    mbtiles_path = "#{TMP_DIR}/deploy-#{z}.mbtiles"
    files = Dir.glob("#{LOT_DIR}/*-#{z}.mbtiles")
    files.select! {|path| !File.exist?("#{path}-journal")}
    sh <<-EOS
tile-join --force --output=#{mbtiles_path} \
--no-tile-size-limit \
#{files.join(' ')}
    EOS
    sh <<-EOS
tile-join --force --output-to-directory=#{tmp_dir} \
--no-tile-size-limit --no-tile-compression \
#{mbtiles_path}
    EOS
    z.downto(z == MINZOOM ? MINCOPYZOOM : z) {|zc|
      sh <<-EOS
rm -r docs/zxy/#{zc}; \
mv #{tmp_dir}/#{zc} docs/zxy
      EOS
    }
    $notifier.ping "🎆deployed #{z}"
  }
  #sh "rm -v #{MBTILES_PATH}"
  $notifier.ping "🎆deploy finished"
end

task :clean do
  sh "rm -r #{TMP_DIR}/zxy" if File.exist?("#{TMP_DIR}/zxy")
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
    cmd = <<-EOS
curl -o #{tmp_path}.zip #{url} ; \
unar -f -o #{TMP_DIR} #{tmp_path}.zip 1>&2 ; \
GDAL_DATA=#{GDAL_DATA} BASENAME=#{basename} ruby reproject_pipeline.rb | \
pdal pipeline --stdin ;
    EOS
    MAXZOOM.downto(MINZOOM) {|z|
      dst_path = "#{LOT_DIR}/#{basename}-#{z}.mbtiles"
      if SKIP && File.exist?(dst_path) && !File.exist?("#{dst_path}-journal")
        $stderr.print "skip #{dst_path} because it is there.\n"
        next
      end
      cmd += <<-EOS
Z=#{z} BASENAME=#{basename} ruby resample_text_pipeline.rb | \
pdal pipeline --stdin | \
Z=#{z} ruby togeojson.rb | \
tippecanoe \
--maximum-zoom=#{MAXZOOM} \
--minimum-zoom=#{MINCOPYZOOM} \
--projection=EPSG:3857 \
--force \
--output=#{dst_path} \
--no-tile-size-limit \
--no-feature-limit ;
      EOS
    }
    cmd += <<-EOS
rm -v #{TMP_DIR}/#{basename}*
    EOS
    sh cmd
    $notifier.ping "💫#{pomocode} #{basename}"
  }
  $notifier.ping "✨#{pomocode} finished"
end
