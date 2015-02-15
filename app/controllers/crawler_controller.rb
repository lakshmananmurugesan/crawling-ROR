class CrawlerController < ApplicationController
  
  #Declarations
  require 'nokogiri'
  require 'open-uri'
  @@counter = 1
  @@scrapedUrls = []
  $resultView = ""
  
  def new 
  end
  
  #Method to get input from user
  def index
    @inputWebsite = params[:crawl]
    createCrawler(@inputWebsite)
  end
  
  #Method to crawl the site
  def createCrawler(inputWebsite)
    begin
    doc = Nokogiri::HTML(open(inputWebsite))
    puts "website->"+inputWebsite
    @urls = doc.xpath('//a/@href')
    @urls.each do |item|
      if item.to_s.start_with?('/')
          item= inputWebsite.to_s+item
          puts "item->"+item
      end
      if ((!item.to_s.include?"mailto:") && (!item.to_s.include?"support.freshdesk.com") && (item.to_s.include?"freshdesk.com"))
        crawling(item)
      end
    end
    puts "length before:"+@@scrapedUrls.length.to_s
    @@scrapedUrls = @@scrapedUrls.uniq
    puts "length before:"+@@scrapedUrls.length.to_s
    @@scrapedUrls.each do |linkPath|
    checkStatusCode(linkPath)
    end
    puts "completed.." 
    rescue => error
      puts "Index Error: " + error.message
      puts error.backtrace
    end
  end
  
  #Method for internal crawling of a page
  def crawling(url)
    begin
    docs = Nokogiri::HTML(open(url))
    @urlsCrawl = docs.xpath('//a/@href')
    @urlsCrawl.each do |item|
      if item.to_s.start_with?('/')
          item= url.to_s+item
      end
      if ((!item.to_s.include?"mailto:") && (item.to_s.include?"freshdesk.com"))
            @@scrapedUrls.push(item.to_s)
      end
    end
    rescue => error
      puts "Parsing Error: " + error.message
      puts error.backtrace
    end
  end
  
 #Method to show up http status code
 def checkStatusCode(linkPath)
  begin
    parsed_url = URI.parse(linkPath)
    http = Net::HTTP.new(parsed_url.host, parsed_url.port)
    http.read_timeout = 100
    request = Net::HTTP::Get.new(parsed_url.request_uri)
    response = http.request(request)
    $resultView << @counter.to_s+"."+response.code.to_s+linkPath
    @@counter+=1
    query = "INSERT INTO Crawlings (statusCode,link) VALUES ('#{response.code}', '#{linkPath}')"
    Crawling.connection.execute(query);
  rescue => error
     puts "Url parsing Error: " + error.message
  end
 end
end
 

