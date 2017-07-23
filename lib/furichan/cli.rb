# coding: utf-8

require 'thor'
require 'date'
require 'active_support/time'
require 'furik/cli'

module Furichan
  class CLI < Thor
    default_command :furichan

    desc 'furichan', 'Do the all of week task'
    def furichan
      invoke :init
      invoke :furik
    end

    desc 'init', 'initialize of week setting'
    def init
      wmonth = Time.now().strftime('%Y-%m-') + week_of_month
      `git checkout -b #{wmonth}`
      `mkdir -p #{wmonth}`
      `cp template.md #{wmonth}/README.md`
    end

    desc 'furik', 'this week"s furik'
    def furik
      wmonth = Time.now().strftime('%Y-%m-') + week_of_month
      dest = Pathname(wmonth + '/README.md')
      dest.open('w') { |f| f.puts furik_init }
    end

    private

    def week_of_month
      today = Date.today()
      beginning_of_month = today.beginning_of_month
      cweek = today.cweek - beginning_of_month.cweek

      # It should be first week.
      # Don't add when begining of month is saturday or sunday
      # ex 2017/07/07(Fri) -> 1
      unless beginning_of_month.saturday? or beginning_of_month.sunday?
        cweek += 1
      end

      cweek.to_s
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
      activity = capture_stdout { furik.activity }
      activity.gsub!('7days Activities', '## 7days Activity')
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
