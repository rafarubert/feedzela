#!/usr/bin/env ruby 
require "rubygems"
require "open-uri"
require "nokogiri"
require "date"
require "active_record"

ActiveRecord::Base.establish_connection(
  :adapter => "postgresql",
  :host => "localhost",
  :username => "ruby",
  :password => "ruby",
  :database => "valorize_production"
)
class News
  def create
    feeds = open("http://rss.terra.com.br/0,,EI8140,00.xml")
    document = Nokogiri::XML(feeds)
    document.children.css("item").each do |post|
      if Date.parse(post.css("pubDate").text) == Date.today
        item = NewsItem.new
        item.title = post.css("title").text
        item.body = post.css("description").text
        item.external_url = post.css("link").text
        item.publish_date = Date.parse(post.css("pubDate").text)
        item.save
      end
    end
  end
end
class  NewsItem < ActiveRecord::Base
  after_create :add_translation
  def add_translation
    attributes = self.attributes
    ["id","image_id","publish_date", "created_at", "updated_at"].each{|attribute| attributes.delete(attribute)}
    item =  NewsItemTranslation.new
    attributes.each_pair do |attribute , value|
      eval "item.#{attribute} = '#{value.gsub("'", "")}'"
    end
    item.locale = "pt-BR"
    item.news_item_id = self.id
    item.save
  end
end
class  NewsItemTranslation < ActiveRecord::Base
end
news = News.new
news.create∂