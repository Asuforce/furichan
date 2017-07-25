require 'thor'
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
      init_branch
      init_file
    end

    desc 'reflection', "write file about this week's furik"
    def reflection
      set_template(create_template)
    end

    desc 'furik', "write stdout this week's furik"
    def furik
      init_furik
    end
  end
end
