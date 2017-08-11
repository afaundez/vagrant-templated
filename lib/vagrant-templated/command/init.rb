require 'optparse'

module Vagrant
  module Templated
    module Command
      class Init < Vagrant.plugin('2', :command)

        def execute
          plugin_root = File.expand_path '../../../', File.dirname(File.expand_path(__FILE__))

          templates_attributes = Hash.new {}
          Dir.glob(File.expand_path("config/attributes/**/*.yml", plugin_root)).each do |attributes_path|
            template = File.basename File.dirname(attributes_path)
            templates_attributes[template] ||= Hash.new {}
            version = Gem::Version.new File.basename(attributes_path, '.yml')
            templates_attributes[template][version] = YAML.load_file(attributes_path)
          end

          options = {}
          opts = OptionParser.new do |o|
            o.banner = 'Usage: vagrant templated init [options] <template> [version]'

            o.separator ''
            o.separator 'Templates and versions availables:'
            o.separator ''
            templates_attributes.each do |template, versions|
              o.separator "     #{template}: #{versions.keys.join(', ')}"
            end
            o.separator ''
            o.separator 'If no version is provided, larger version will be used.'

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
          @env.ui.info("Template detected: #{template}", prefix: false, color: :yellow)
          template_attributes_versions = templates_attributes[template] or raise Vagrant::Errors::VagrantTemplatedOptionNotFound
          if argv.length == 2
            version = Gem::Version.new(argv[1]) or raise Vagrant::Errors::VagrantTemplatedInvalidVersion
            @env.ui.info("Version detected: #{Gem::Version.new(argv[1])}", prefix: false, color: :yellow)
          else
            version = template_attributes_versions.keys.max
            @env.ui.info("No version detected, using: #{version}", prefix: false, color: :yellow)
          end
          template_attributes = template_attributes_versions[version] or raise Vagrant::Errors::VagrantTemplatedOptionNotFound


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

          vagrantfile = ERB.new File.read(File.expand_path('config/templates/Vagrantfile.erb', plugin_root)), nil, '-'
          berksfile = ERB.new File.read(File.expand_path('config/templates/Berksfile.erb', plugin_root)), nil, '-'

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
