# coding: utf-8

require 'thor'
require 'date'
require 'active_support/time'
require 'furik/cli'
require 'fileutils'
require 'erb'

module Furichan
  class CLI < Thor
    default_command :furichan

    desc 'furichan', 'Do the all of week task'
    def furichan
      invoke :init
      invoke :reflection
    end

    desc 'init', 'initialize of week setting'
    def init
      wmonth = get_wmonth
      `git checkout -b #{wmonth}`
      FileUtils.mkdir("#{wmonth}")
      FileUtils.touch("#{wmonth}/README.md")
    end

    desc 'reflection', "write about this week's furik"
    def reflection
      wmonth = get_wmonth
      reflection = write_reflection
      template = File.read(File.expand_path('../templates/template.md.erb', __FILE__))
      md = ERB.new(template).result(binding)
      dest = Pathname(wmonth + '/README.md')
      dest.open('a') { |f| f.puts md }
    end

    private

    def get_wmonth
      Time.now().strftime('%Y-%m-') + week_of_month
    end

    def week_of_month
      today = Date.today()
      beginning_of_month = today.beginning_of_month
      cweek = today.cweek - beginning_of_month.cweek

      # It should be first week.
      # Don't add when begining of month is saturday or sunday
      # ex 2017/07/07(Fri) -> 1
      cweek += 1 unless weekend?(beginning_of_month)

      cweek.to_s
    end

    def weekend?(day)
      day.saturday? or day.sunday?
    end

    def write_reflection
      activity = capture_stdout { furik_init }
      activity.gsub!('7days Activities', '## 7days Activity')
    end

    def furik_init
      week = Date.today.beginning_of_week
      furik = Furik::Cli.new
      furik.options = {
        gh: true,
        ghe: true,
        from: week.to_s,
        to: week.end_of_week.to_s,
        since: 0,
      }
      furik.activity
    end

    def capture_stdout
      out = StringIO.new
      $stdout = out
      yield
      return out.string
    ensure
      $stdout = STDOUT
    end
  end
end
