#! /usr/bin/env ruby

require 'csv'
require 'httparty'
require 'json'

class JSONObject
  def initialize(filename)
    hash = JSON.load(File.new(filename))
    hash.each do |k,v|
      self.instance_variable_set("@#{k}", v)
      self.class.send(:define_method, k, proc{self.instance_variable_get("@#{k}")})
      self.class.send(:define_method, "#{k}=", proc{|v| self.instance_variable_set("@#{k}", v)})
    end
  end
end

class Fetcher
  def initialize(config, users)
    @config = JSONObject.new(config)
    @users = JSON.load(File.new(users))
  end

  def getData(token, endpoint, fields)
    HTTParty.get(@config.api_host + endpoint, {
      :query => {
        :access_token => token,
        :fields       => fields.keys.join(','),
        :limit        => 5000
      }
    })
  end

  def writeData(user, endpoint, fields, data)
    columns = fields.keys
    CSV.open(filename(user, endpoint), 'w', :col_sep => "\t") do |tsv|
      tsv << columns.map{|col| fields[col]}.unshift('Name')
      data.each do |datum|
        tsv << columns.map{|col| datum[col]}.unshift(user)
      end
    end
  end

  def filename(user, endpoint)
    filename = "out/#{user}-#{endpoint[1..-1].gsub('/','-')}.tsv"
  end

  def run
    @users.each do |user, token|
      @config.data.each do |endpoint, fields|
        puts "Getting #{user} #{endpoint}"
        data = getData(token, endpoint, fields)
        writeData(user, endpoint, fields, data)
      end
    end
  end
end

Fetcher.new('config.json', 'users.json').run
