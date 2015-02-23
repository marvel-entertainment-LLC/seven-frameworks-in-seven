#!/usr/bin/env ruby
require 'json'

run_list = {

  # CLI example: ruby curl.rb create
  'create' => lambda {
    # create bookmark with random suffix number for title
    # and 2 random 'test' tags, for sake of variety
    url  = "http://localhost:4567/bookmarks"
    tags = ['test','test'].map { |v| "#{v}#{rand(10)}" }
    form_post = {
      'url'          => 'http://testpost.com',
      'title'        => "test post #{rand(100)}",
      'tagsAsString' => tags.join(',')
    }.map { |k,v| %Q{-F "#{k}=#{v}"} }.join ' '
    exec "curl -X POST #{form_post} #{url}"
  },
  
  # CLI examples:
  # ruby curl.rb fetch test1
  # ruby curl.rb fetch test2/test4
  # ruby curl.rb fetch test1/test3/test6
  'fetch' => lambda {
    # use to fetch by tag(s)
    tags = ARGV.shift
    url  = "http://localhost:4567/bookmarks/#{tags}"
    json = JSON.parse(`curl -s #{url}`)
    puts JSON.pretty_generate(json)
  }
}

cmd = ARGV.shift
run_list[cmd].call unless run_list[cmd].nil?