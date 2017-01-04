require 'pp'
require 'net/sftp'
require 'tempfile'
require 'nokogiri'
require 'rubygems'
require 'zip/zip'
require 'stringio'
require 'uri'

#desc "Set the environment variable RAILS_ENV='staging'."
#task :staging do
#  ENV["RAILS_ENV"] = 'staging'
#  Rake::Task[:environment].invoke
#end

namespace :spree do
  namespace :extensions do
    namespace :bronto do
      desc "upload orders"

      task :upload_orders => :environment do |t|
        start_time = Time.now
        report_str = [ "Uploading bronto order feeds: #{start_time.strftime( "%Y-%m-%d %H:%M:%S" )}"]
        success = true
        report_str << "Processing..."
        complete, report = upload_orders( start_time )
        report_str << report
        end_time = Time.now
        report_str << "Finished uploading bronto order feeds:  #{start_time.strftime( "%Y-%m-%d %H:%M:%S" )}"
        report_str << "Elapsed time: #{(end_time - start_time) rescue 'unknown'} seconds"
        puts report_str
      end

      def upload_orders  timestamp
        report = ""
        time = Time.now.to_s
        time = DateTime.parse(time).strftime("%Y%m%d_%H_%M")
        #sftp
        Spree::Store.all.each do |store|
          config=Spree::BrontoConfiguration.account["#{store.code}"]
          Net::SFTP.start(config["ftp_host"], config["ftp_username"], :password => config["ftp_password"],:port=>config["stfp_port"]) do |sftp|
            # open and write to a pseudo-IO for a remote file
            file_content=get_html_content("https://#{store.url}/feed/bronto_orders.csv?numofday=30")
            filename=  store.code+'_orders_'+time
puts filename
puts file_content

            sftp.file.open(filename, "w") do |f|
puts 'here1'
              report << "upload the #{store.code} orders to bronto"
puts 'here2'
              f.puts file_content
puts 'here3'
            end
          end
        end

        result = true

        [result, report]
      end



      def get_html_content(requested_url)
        url = URI.parse(requested_url)
        full_path = (url.query.blank?) ? url.path : "#{url.path}?#{url.query}"
        the_request = Net::HTTP::Get.new(full_path)

        the_response = Net::HTTP.start(url.host, url.port, :use_ssl => url.scheme == 'https') { |http|
          http.request(the_request)
        }

        raise "Response was not 200, response was #{the_response.code}" if the_response.code != "200"
        return the_response.body
      end

    end
  end
end

