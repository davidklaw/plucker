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
  end

  def pluck
    json = File.read(@app_map['file'])
    parsed_json = JSON.parse(json)
    recursive_find('name', parsed_json)

    print
  end

  def print
    if @app_map['output']
      File.open(@app_map['output'], "w") do |file|
        file.write @results.join("\n")
      end
    else
      puts @results
    end
  end

  def clean(res)
    HTMLEntities.new.decode res
  end

  def recursive_find(key, object)
    case object
    when Array
      object.each do |el|
        if el.is_a?(Hash) || el.is_a?(Array)
          res = recursive_find( key, el )
          @results << clean(res) if res
        end
      end
    when Hash
      return object[key] if object.has_key?( key )
      object.each do |k,v|
        if v.is_a?(Hash) || v.is_a?(Array)
          res = recursive_find( key, v )
          @results << clean(res) if res
        end
      end
    end
    nil
  end
end

if ARGV.empty?
  puts "Oops!"
else
  app_map = {
    'file' => ARGV[0],
    'output' => ARGV[1],
    'key' => ARGV[2]
  }

  plucker = Plucker.new app_map
  plucker.pluck
end