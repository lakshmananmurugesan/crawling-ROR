class CrawlerController < ApplicationController
  
  #Declarations
  require 'nokogiri'
  require 'open-uri'
  $counter = 1
  @@scrapedUrls = []
  $resultView = ""
  $domainName = ""
  
  #Method to crawl the site
  def crawl_all
    begin
    $resultView = ""
    inputWebsite = params[:crawl]
    if inputWebsite.to_s != ''
    $domainName = getDomainName(inputWebsite)
    puts "domain:"+$domainName
    doc = Nokogiri::HTML(open(inputWebsite))
    @urls = doc.xpath('//a/@href')
    @urls.each do |item|
      if item.to_s.start_with?('/')
          item= inputWebsite.to_s+item
          puts "url->"+item
      end
      if ((!item.to_s.include?"mailto:") && (item.to_s.include?$domainName.to_s))
        crawling(item)
      end
    end
    puts "completed.." 
    puts "Validated urls..."
    puts "No of unique urls crawled:"+@@scrapedUrls.length.to_s
   end
    rescue => error
      puts "Index: " + error.message
    end
  end
  
  #Method for internal crawling of a page
  def crawling(url)
    begin
    if url.to_s.include?$domainName.to_s
    puts "processing:"+url.to_s 
    docs = Nokogiri::HTML(open(url))
    @urlsCrawl = docs.xpath('//a/@href')
    @urlsCrawl.each do |item|
      if item.to_s.start_with?('/')
          item= url.to_s+item
      end
      if ((!item.to_s.include?"mailto:") && (item.to_s.include?$domainName.to_s))
            unless @@scrapedUrls.include?(item.to_s)
            @@scrapedUrls.push(item.to_s)
            checkStatusCode(item.to_s)
            end
      end
    end
    end
    rescue => error
      puts "Parsing: " + error.message
    end
  end
  
 #Method to show up http status code
 def checkStatusCode(linkPath)
  require 'net/http'
  begin
    response = Net::HTTP.get_response(URI.parse(linkPath.to_s))
    puts "status code->"+response.code.to_s
    $resultView << $counter.to_s+")"+response.code.to_s+"->"+linkPath+"\n"
    $counter+=1
    query = "INSERT INTO Crawlings (statusCode,link) VALUES ('#{response.code}', '#{linkPath}')"
    Crawling.connection.execute(query);
  rescue => error
     puts "Url parsing: " + error.message
  end
 end
 
 #Method to get domain name of a site
 def getDomainName(url)
  url = "http://#{url}" if URI.parse(url).scheme.nil?
  host = URI.parse(url).host.downcase
  host.start_with?('www.') ? host[4..-1] : host
  return host.to_s
 end
end
 

