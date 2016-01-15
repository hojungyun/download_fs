#!/usr/bin/env ruby

##############################################
# Script:           File downloader
# Author:           Hojung Yun
# Email:            hojung_yun@yahoo.co.kr
# Version:          1.0
# Ruby version:     1.9.3 and 2.0.0
# Date Published: 	April, 2014
##############################################

require 'hpricot'
require 'open-uri'
require 'parallel'
require 'optparse'
require 'logger'
require 'chronic_duration'

# set log file and log level
$log = Logger.new('log.txt')
$log.level = Logger::INFO

# set the version of script
VERSION = "1.0"

# set default value of arguments
options = {
    :download_dir => 'download',
    :concurrency => 5,
    :filetype => 'all',
    :debug => false
}

# option parser
opt_parser = OptionParser.new do |opt|
  opt.banner = "Usage:"
  opt.separator "     #{File.basename($0)} [<options>]"
  opt.separator ""
  opt.separator "Examples:"
  opt.separator "     #{File.basename($0)} -u http://example.com/temp"
  opt.separator "     #{File.basename($0)} -u http://example.com/temp/"
  opt.separator "     #{File.basename($0)} -u http://example.com/temp/list.htm"
  opt.separator "     #{File.basename($0)} -u http://example.com/temp -d download -c 3 -t pdf,txt"
  opt.separator ""
  opt.separator "Options"

  # mandatory arguments
  opt.on("-u", "--uri uri", "URI of file resource") do |uri|
    options[:uri] = uri
  end

  # optional arguments
  opt.on("-d", "--download_dir download_dir", "Local directory to save files in (download by default)") do |download_dir|
    options[:download_dir] = download_dir
  end
  opt.on("-c", "--concurrency concurrency", "Number of multiple requests to make (5 by default)") do |concurrency|
    options[:concurrency] = concurrency.to_i
  end
  opt.on("-t", "--filetype type1[,type2]", Array, "List of case-insensitive filetypes to download (all by default)") do |filetype|
    options[:filetype] = filetype
  end

  opt.on("-D", "--debug", "Debug mode") do
    options[:debug] = true
    $log.level = Logger::DEBUG
  end
  opt.on("-v", "--version", "Display script version") do
    puts VERSION
    exit
  end
  opt.on("-h", "--help", "Display help messages") do
    puts opt_parser
    exit
  end
end

begin
  opt_parser.parse!
  $log.debug "OPTIONS: #{options}"
  mandatory = [:uri]
  missing = mandatory.select { |param| options[param].nil? }
  if not missing.empty?
    puts "Missing options: #{missing.join(', ')}"
    puts opt_parser
    exit
  end
rescue OptionParser::InvalidOption, OptionParser::MissingArgument
  puts $!.to_s
  puts opt_parser
  exit
end

$log.info "-= SCRIPT STARTED =-"

# to measure total download time and number of downloaded files
overall_start_time = Time.now
download_count = 0

# add '/' to uri if absent or uri is not ended with .xxx
options[:uri] << '/' unless options[:uri] =~ /(\.\w+?$|\/$)/

# get all links
doc = Hpricot(open(options[:uri]))
download_links = doc.search("//a")

# create download directory if not exists
Dir.mkdir(options[:download_dir]) unless File.directory?(options[:download_dir])
Dir.chdir(options[:download_dir])

Parallel.map(download_links, :in_threads => options[:concurrency]) do |e|
  download_link = e['href']
  # add url if files listed in web server do not have full path
  if e['href'] !~ /^http/
    download_link = options[:uri] + download_link
    $log.debug "Download link: #{download_link}"
  end

  # get filename from link and check if it's valid
  fileName = e.inner_html
  if fileName !~ /\./
    $log.info "'#{fileName}' does not look like filename"
    next
  elsif options[:filetype] != 'all' && fileName !~ /\.#{options[:filetype]}/i
    $log.info "Type of #{fileName} is not selected"
    next
  end

  # start downloading file
  open(fileName, 'wb') do |file|
    begin
      file << open(download_link).read
    rescue OpenURI::HTTPError
      $log.info "#{download_link} is not found"
      next
    end
    puts "#{fileName} has been downloaded successfully"
    download_count += 1
  end
end

total_time = ChronicDuration::output((Time.now - overall_start_time).round(2), :format => :long)
puts "-" * 40
puts "Number of files downloaded: #{download_count}"
puts "Total downloading time: #{total_time}"
$log.info "-= SCRIPT FINISHED =-"

__END__

##########
# CentOS
##########

1. install rvm, ruby and rubygem

curl -sSL https://get.rvm.io | bash -s stable
source /etc/profile.d/rvm.sh

rvm reload
rvm list known | grep 2.0
rvm install 2.0.0
rvm list rubies
rvm use 2.0.0 --default

2. install gems

gem install hpricot
gem install parallel
gem install chronic_duration

3. usage
./download_fs.rb -u http://example.com/temp
./download_fs.rb -u http://example.com/temp/
./download_fs.rb -u http://example.com/temp -d download -c 3 -t pdf,txt

###########
# Windows
###########

1. download and install Ruby 1.9.3-p545 from:
http://rubyinstaller.org/downloads/

2. install gems
gem install hpricot --platform=mswin32
gem install parallel
gem install chronic_duration

3. usage
download_fs.rb -u http://example.com/temp
download_fs.rb -u http://example.com/temp/
download_fs.rb -u http://example.com/temp -d download -c 3 -t pdf,txt

