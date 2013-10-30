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
    recursive_find(@app_map['key'], parsed_json)

    print
  end

  def print
    File.open(@app_map['file'] + ".txt", "w") do |file|
      file.write "#{@results.uniq.count} results"
      file.write "\n\n"
      file.write @results.uniq.join("\n")
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
  # Some sort of helpful text output would be nice here
  puts "Oops!"
else
  app_map = {
    'file' => ARGV[0],
    'key' => ARGV[1]
  }

  plucker = Plucker.new app_map
  plucker.pluck
end