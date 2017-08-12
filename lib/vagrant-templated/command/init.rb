module Vagrant
  module Templated
    module Command
      class Init < Vagrant.plugin('2', :command)

        def execute
          template, version, options = setup
          return if template.nil?
          @env.ui.info("Template detected: #{template}", color: :yellow)

          version = patch template, version

          template_attributes = Catalog.attributes_for template, version

          vagrantfile_save_path = nil
          berksfile_save_path = nil
          if options[:suffix] != "-"
            vagrantfile_save_path = Pathname.new(['Vagrantfile', options[:suffix]].compact.join('.')).expand_path(@env.cwd)
            vagrantfile_save_path.delete if vagrantfile_save_path.exist? && options[:force]
            raise Vagrant::Templated::Errors::VagrantfileExistsError if vagrantfile_save_path.exist?
            berksfile_save_path = Pathname.new(['Berksfile', options[:suffix]].compact.join('.')).expand_path(@env.cwd)
            berksfile_save_path.delete if berksfile_save_path.exist? && options[:force]
            raise Vagrant::Templated::Errors::BerksfileExistsError if berksfile_save_path.exist?
          end

          vagrantfile = ERB.new File.read(Catalog.root.join 'config/templates/Vagrantfile.erb'), nil, '-'
          berksfile = ERB.new File.read(Catalog.root.join 'config/templates/Berksfile.erb'), nil, '-'

          contents = vagrantfile.result binding
          if vagrantfile_save_path
            begin
              vagrantfile_save_path.open('w+') do |f|
                f.write(contents)
              end
            rescue Errno::EACCES
              raise Vagrant::Templated::Errors::VagrantfileWriteError
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
              raise Vagrant::Templated::Errors::BerksfileWriteError
            end

            @env.ui.info('Templated Berksfile created successfully', prefix: false)
          else
            @env.ui.info('BERKSFILE', prefix: false, color: :green)
            @env.ui.info(contents, prefix: false)
          end
            @env.ui.info('Vagrant Templated finished successfully.', prefix: false, color: :green)
          0
        end

        private

          def patch(template, version)
            if version.nil? || version.empty?
              version = Catalog.max_version_for template
              @env.ui.info("No version detected, using: #{version}", color: :yellow)
            else
              @env.ui.info("Version detected: #{version}", color: :yellow)
            end
            version
          end

          def setup
            options = {}
            opts = OptionParser.new do |o|
              o.banner = 'Usage: vagrant templated init [options] <template> [version]'

              o.separator ''
              o.separator 'Templates and versions availables:'
              o.separator ''
              Catalog.templates.each do |template|
                o.separator "     #{template}: #{Catalog.versions_for(template).join(', ')}"
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
            argv = parse_options opts
            return if !argv
            if !argv || argv.empty? || argv.length > 2
              raise Vagrant::Errors::CLIInvalidUsage,
                help: opts.help.chomp
            end
            template, version = argv
            [template, version, options]
          end
      end
    end
  end
end
