require "open3"
require 'logger'

LOG_LEVEL = ENV.has_key?('LOG_LEVEL') ? ENV['LOG_LEVEL'].upcase : 'INFO'
ROOT = File.dirname(__FILE__)

Console = Logger.new(STDOUT)
Console.level = Logger.const_get(LOG_LEVEL)
Console.formatter = proc do |level, datetime, progname, msg|
  msg + "\n"
end

module CommandLineHelper
  def self.help
    <<-EOF
Help Message.
    EOF
  end

  def self.error
    <<-EOF
Please choose one option.
    EOF
  end

  def self.invalid
    <<-EOF
Supplied option is invalid.
    EOF
  end
end

module Steps
  def self.valid?(step_name)
    self.valid_steps.include?(step_name)
  end

  def self.execute(step_name)
    @install_steps = []
    @config_steps  = []
    @failed_steps  = []

    if step_name === 'all'
      enqueue_all
    else
      enqueue(step_name)
    end

    execute!
    Console.info "#{@install_steps.length} steps selected, #{@failed_steps.length} failed."

    unless @failed_steps.empty?
      Console.error "Failed steps: #{@failed_steps.join(", ")}"
    end
  end

  def self.valid_steps
    @valid_steps ||= ['all'] +
      Dir.entries(ROOT+"/steps").reject{|x| x[0] == '.' || x[0] == '_' }
  end

  def self.enqueue_all
    enqueue('_pre_install')
    valid_steps.each{|s| enqueue(s)}
    enqueue('_post-install')
  end

  def self.enqueue(step_name)
    @install_steps << step_name
    @config_steps  << step_name
  end

  def self.execute!
    @install_steps.each do |step|
      script = parse_script(step, 'install')

      unless script
        Console.warn "No install step for #{step}"
        return
      end

      Console.info "Installing #{step}"
      response, status = Open3.capture2("/bin/sh", script)
      response.split("\n").each {|s| Console.debug "#{step}: #{s}"}

      unless status.success?
        @failed_steps << step
        Console.error "Failed #{step} install."
      end
    end

    @config_steps.each do |step|
      if @failed_steps.include?(step)
        Console.debug "Skipped #{step} config, due to presence in failed steps"
        return
      end

      script = parse_script(step, 'config')

      unless script
        Console.warn "No config step for #{script}"
        return
      end

      Console.info "Configuring #{step}"
      response, status = Open3.capture2("/bin/sh", script)
      response.split("\n").each {|s| Console.debug "#{step}: #{s}"}

      unless status.success?
        Console.error "Failed #{step} configure."
      end
    end
  end

  def self.parse_script(step, script_name)
    dir = File.join(ROOT, "steps", step)
    file = File.join(dir, "#{script_name}.sh")

    if File.exist?(file)
      file
    else
      false
    end
  end
end

if %x{whoami}.chomp != "root"
  abort "Must be root to execute commands"
end

case ARGV.length
when 0
  Console.fatal CommandLineHelper.help
when 1
  if Steps.valid?(ARGV[0])
    Steps.execute(ARGV[0])
  else
    Console.fatal CommandLineHelper.invalid
    Console.fatal CommandLineHelper.help
  end
else
  Console.fatal CommandLineHelper.error
  Console.fatal CommandLineHelper.help
end
