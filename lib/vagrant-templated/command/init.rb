require 'optparse'

module Vagrant
  module Templated
    module Command
      class Init < Vagrant.plugin('2', :command)

        def execute
          root_path = File.expand_path '../../../', File.dirname(File.expand_path(__FILE__))
          templates_attributes = Dir.glob(File.expand_path("config/templates/attributes/*.yml", root_path)).collect do |template|
            YAML.load_file(template)
          end.reduce Hash.new, :merge

          options = {}
          opts = OptionParser.new do |o|
            o.banner = 'Usage: vagrant templated init [options] <template>'

            o.separator ''
            o.separator 'Templates availables:'
            o.separator ''
            templates_attributes.keys.each do |template|
              o.separator "     #{template}"
            end

            o.separator ''
            o.separator 'Options:'
            o.separator ''

            o.on('-s', '--suffix SUFFIX', String,
                 "Output suffix for Vagrantfile and Berksfile. '-' for stdout") do |suffix|
              options[:suffix] = suffix
            end

            o.on('-f', '--force', 'Overwrite an existing box if it exists') do |f|
              options[:force] = f
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
          raise Vagrant::Errors::VagrantTemplatedOptionNotFound unless templates_attributes.keys.include? template
          template_attributes = templates_attributes[template]

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

          vagrantfile = ERB.new File.read(File.expand_path('config/templates/files/Vagrantfile.erb', root_path)), nil, '-'
          berksfile = ERB.new File.read(File.expand_path('config/templates/files/Berksfile.erb', root_path)), nil, '-'

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
