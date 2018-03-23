require 'date'
require 'erb'
require 'fileutils'
require 'furik/cli'
require 'active_support/time'

module FurichanUtil
  private

  def get_wmonth
    Time.now.strftime('%Y-%m-') + week_of_month
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
    day.saturday? || day.sunday?
  end

  def write_reflection
    activity = capture_stdout { init_furik }
    activity.gsub!('7days Activities', '## 7days Activity')
  end

  def init_furik
    week = Date.today.beginning_of_week
    furik = Furik::Cli.new
    furik.options = {
      gh: true,
      ghe: true,
      from: week.to_s,
      to: week.end_of_week.to_s,
      since: 0
    }
    furik.activity
  end

  def capture_stdout
    out = StringIO.new
    $stdout = out
    yield
    out.string
  ensure
    $stdout = STDOUT
  end

  def init_branch
    `git checkout -b #{get_wmonth}`
  end

  def init_file
    wmonth = get_wmonth
    FileUtils.mkdir(wmonth.to_s)
    FileUtils.touch("#{wmonth}/README.md")
  end

  def create_template
    template = File.read(File.expand_path('templates/template.md.erb', __dir__))
    ERB.new(template).result(binding)
  end

  def set_template(result)
    dest = Pathname("#{get_wmonth}/README.md")
    dest.open('a') { |f| f.puts result }
  end
end
