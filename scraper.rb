require 'rubygems'
require 'nokogiri'
require 'open-uri'

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

gpp = GitProfileParser.new(ARGV[0])
puts gpp.getProfile
puts "\nFollowers:\n"
gpp.getFollowers.each do |follower|
	o = GitProfileParser.new(follower[:handle])
	puts o.getProfile
end
#puts page.methods
#puts page.inspect
#puts page.class   # => Nokogiri::HTML::Document
