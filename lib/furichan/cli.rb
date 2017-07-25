# coding: utf-8

require 'thor'
require 'fileutils'
require 'erb'
require "furichan/furichan_util"

module Furichan
  class CLI < Thor
    include FurichanUtil

    default_command :furichan

    desc 'furichan', "Create file and write about this week's reflection"
    def furichan
      invoke :init
      invoke :reflection
    end

    desc 'init', 'initialize of week setting'
    def init
      wmonth = get_wmonth
      #`git checkout -b #{wmonth}`
      FileUtils.mkdir("#{wmonth}")
      FileUtils.touch("#{wmonth}/README.md")
    end

    desc 'reflection', "write file about this week's furik"
    def reflection
      wmonth = get_wmonth
      reflection = write_reflection
      template = File.read(File.expand_path('../templates/template.md.erb', __FILE__))
      md = ERB.new(template).result(binding)
      dest = Pathname(wmonth + '/README.md')
      dest.open('a') { |f| f.puts md }
    end

    desc 'furik', "write stdout this week's furik"
    def furik
      init_furik
    end
  end
end
