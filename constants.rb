TMP_DIR = 'tmp'
LOT_DIR = 'lot'
LIST_PATH = 'mishima.txt'
MBTILES_PATH = "#{TMP_DIR}/tiles.mbtiles"
GDAL_DATA = '/usr/share/gdal'

BASE_URL = 'https://x.optgeo.org/kid-b/zxy'

Z_ONE_METER = 19 #18
BASE = 2 #3

MAXZOOM = 18
MINZOOM = 10
MINCOPYZOOM = 8

LAYER = 'voxel'

HOSTS = %w{m321 m343 m354}

SLACK = true
$notifier = nil
if SLACK
  require 'slack-notifier'
  $notifier = Slack::Notifier.new ENV['WEBHOOK_URL']
end

def hostname
  `hostname`.strip
end

def pomocode
  "[#{Time.now.to_i / 1800}@#{hostname}]"
end

def hostmatch(basename)
  n = basename[-4..-1].to_i
  n % HOSTS.size == HOSTS.index(hostname)
end
