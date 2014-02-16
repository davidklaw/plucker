#!/usr/bin/env ruby

# Example application to demonstrate some basic Ruby features
# This code loads a given file into an associated application

require 'json'
require 'yaml'
require 'htmlentities'

class Plucker
  
  def initialize app_map 
    @app_map = app_map
    @results = Array.new
    @products = Array.new
  end

  def pluck
    
    json = File.read(@app_map['file1'])
    parsed_json = JSON.parse(json)
    get_products(parsed_json)

    json = File.read(@app_map['file2'])
    parsed_json = JSON.parse(json)
    get_products(parsed_json)

    json = File.read(@app_map['file3'])
    parsed_json = JSON.parse(json)
    get_products(parsed_json)

    print
  end

  def print
    File.open("market-sort.txt", "w") do |file|
      @products.uniq!{ |v| v['title'] || v['name'] }
      @products.sort!{ |a, b| a["marketRank"].to_i == b["marketRank"].to_i ? a["propertyRank"].to_i <=> b["propertyRank"].to_i : a["marketRank"].to_i <=> b["marketRank"].to_i }

      file.write "#{@products.length} results"
      file.write "\n\n"

      @products.each_with_index do |p, i|
        p['title'] ||= p['name']
        file.write "#{i} #{p['title']}\n"
        file.write "marketRank: #{p['marketRank']}\n"
        file.write "productRank: #{p['propertyRank']}\n\n"
      end
      
    end
  end

  def clean(res)
    HTMLEntities.new.decode res
  end

  def get_products(object)
    if object['event']
      object['event'].each do |obj|
        @products << obj
      end
    elsif object['restaurant']
      object['restaurant'].each do |obj|
        @products << obj
      end
    elsif object['thingstodo']
      object['thingstodo'].each do |obj|
        @products << obj
      end
    end
  end
end

if ARGV.empty?
  # Some sort of helpful text output would be nice here
  puts "Oops!"
else
  app_map = {
    'file1' => ARGV[0],
    'file2' => ARGV[1],
    'file3' => ARGV[2]
  }

  plucker = Plucker.new app_map
  plucker.pluck
end