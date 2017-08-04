require 'optparse'

module Vagrant
  module Templated
    module Command
      class Init < Vagrant.plugin('2', :command)

        def execute
          defaults = YAML.load_file File.join(File.dirname(File.expand_path(__FILE__)), '../templates/defaults.yml')
          options = {}

          opts = OptionParser.new do |o|
            o.banner = 'Usage: vagrant templated init [options] <template>'

            o.separator ''
            o.separator 'Templates availables: rails'
            o.separator ''
            o.separator '     rails5'
            o.separator '     vagrant-plugin'

            o.separator ''
            o.separator 'Options:'
            o.separator ''

            o.on('-f', '--force', 'Overwrite an existing box if it exists') do |f|
              options[:force] = f
            end

            o.on('-s', '--suffix SUFFIX', String,
                 "Output suffix for Vagrantfile and Bersfile. '-' for stdout") do |suffix|
              options[:suffix] = suffix
            end
          end

          argv = parse_options(opts)
          return if !argv
          if argv.empty? || argv.length > 2
            raise Vagrant::Errors::CLIInvalidUsage,
              help: opts.help.chomp
          end

          template = argv[0]
          if argv.length == 2
            options[:name] = argv[0]
            template = argv[1]
          end

          @env.ui.info("Detected template: #{template}", prefix: false, color: :yellow)
          raise Vagrant::Errors::VagrantTemplatedOptionNotFound unless defaults.keys.include? template

          vagrantfile_save_path = nil
          berksfile_save_path = nil
          if options[:suffix] != "-"
            vagrantfile_save_path = Pathname.new(['Vagrantfile', options[:suffix]].compact.join('.')).expand_path(@env.cwd)
            vagrantfile_save_path.delete if vagrantfile_save_path.exist? && options[:force]
            raise Vagrant::Errors::VagrantfileTemplatedExistsError if vagrantfile_save_path.exist?
            berksfile_save_path = Pathname.new(['Berksfile', options[:suffix]].compact.join('.')).expand_path(@env.cwd)
            berksfile_save_path.delete if berksfile_save_path.exist? && options[:force]
            raise Vagrant::Errors::BerksfileTemplatedExistsError if berksfile_save_path.exist?
          end

          vagrantfile = ERB.new File.read(File.join(File.dirname(__FILE__), '../templates/Vagrantfile.erb')), nil, '-'
          berksfile = ERB.new File.read(File.join(File.dirname(__FILE__), '../templates/Berksfile.erb')), nil, '-'

          contents = vagrantfile.result binding
          if vagrantfile_save_path
            begin
              vagrantfile_save_path.open('w+') do |f|
                f.write(contents)
              end
            rescue Errno::EACCES
              raise Vagrant::Errors::VagrantfileWriteError
            end

            @env.ui.info('Templated Vagranfile created successfully', prefix: false)
          else
            @env.ui.info('VAGRANTFILE', prefix: false, color: :green)
            @env.ui.info(contents, prefix: false)
          end

          contents = berksfile.result binding
          if berksfile_save_path
            begin
              berksfile_save_path.open('w+') do |f|
                f.write(contents)
              end
            rescue Errno::EACCES
              raise Vagrant::Errors::BerksfileWriteError
            end

            @env.ui.info('Templated Berksfile created successfully', prefix: false)
          else
            @env.ui.info('BERKSFILE', prefix: false, color: :green)
            @env.ui.info(contents, prefix: false)
          end
            @env.ui.info('Vagrant Templated finished successfully.', prefix: false, color: :green)
          0
        end
      end
    end
  end
end
