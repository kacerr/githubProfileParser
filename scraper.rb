require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'mysql2'

class GitProfileParser
	attr_accessor :userHandle

	def initialize(userHandle)
		self.userHandle = userHandle
	end

	def getFollowers
		followersUrl = "https://github.com/#{self.userHandle}/followers"
		page = Nokogiri::HTML(open(followersUrl))
		followers = Array.new
		followListItems = page.css(".follow-list-item")
		followListItems.each do |item|
			#puts item
			url = item.css("a").attr("href").value
			title = item.css("div").css("h3").css("span").attr("title").value
			handle = url.to_s.gsub(/\//, '')
			followers << {
				:handle => handle,
				:title => title,
				:url => url
			}
		end
		return followers
	end

	def getProfile
		profileUrl = "https://github.com/#{self.userHandle}"
		page = Nokogiri::HTML(open(profileUrl))
		profileInfo = page.css("div[itemtype='http://schema.org/Person']")
		worksFor = profileInfo.css("[itemprop='worksFor']").text
		homeLocation = profileInfo.css("[itemprop='homeLocation']").text
		email = profileInfo.css("a.email").text
		url = profileInfo.css("[itemprop='url']").text
		return {
			:handle => self.userHandle,
			:worksFor => worksFor,
			:homeLocation => homeLocation,
			:email => email,
			:url => url
		}

	end

end

if ARGV[0]==nil
	puts "Give me handle, please" 
	exit 
end

if ARGV[1]=="prepare"
	db = Mysql2::Client.new(:host => "localhost", :username => "root", :database => "githubScraper")
	query = "INSERT INTO `working_queue` (handle, status) VALUES ('#{ARGV[0]}', 0)"
	puts db.query(query)
	exit
end

if ARGV[1]=="process"
	db = Mysql2::Client.new(:host => "localhost", :username => "root", :database => "githubScraper")
	# select 1st unprocessed element from database and process it
	result = db.query 'select * from `working_queue` WHERE status=0 limit 1'
	result.each do |row|
		gpp = GitProfileParser.new(row["handle"])
		profile = gpp.getProfile
		puts profile
		# also save it to the database
		query = "INSERT INTO `contacts` (handle, works_for, home_location, email, url, created_at) VALUES (
			'#{profile[:handle]}', 
			'#{profile[:works_for]}', 
			'#{profile[:home_location]}', 
			'#{profile[:email]}', 
			'#{profile[:url]}', 
			'#{DateTime.now.strftime("%Y/%m/%d %H:%M").to_s}' 
		)"
		begin
			db.query(query)
		rescue Exception => e  
			puts e.message 
		end

		#puts "\nFollowers:\n"
		gpp.getFollowers.each do |follower|
			#o = GitProfileParser.new(follower[:handle])
			#puts o.getProfile
			query = "INSERT INTO `working_queue` (handle, status) VALUES ('#{follower[:handle]}', 0)"
			begin
				db.query(query)
			rescue Exception => e  
				puts e.message 
			end
		end

		# mark processed handle
		query = "UPDATE working_queue SET status=1 WHERE handle='#{row["handle"]}'"
		db.query query

	end
	exit
end


gpp = GitProfileParser.new(ARGV[0])
puts gpp.getProfile
puts "\nFollowers:\n"
gpp.getFollowers.each do |follower|
	o = GitProfileParser.new(follower[:handle])
	puts o.getProfile
end
