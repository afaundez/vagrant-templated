module Vagrant
  module Templated
    module Command
      class Init < Vagrant.plugin('2', :command)

        def execute
          template, version, options = setup
          return if template.nil?
          @env.ui.info "vagrant-templated detected #{template} template", new_line: true
          if version.nil? || version.empty?
            version = Catalog.patch template, version
            @env.ui.info "vagrant-templated didn't received a version, using largest available #{version}"
          else
            @env.ui.info "vagrant-templated detected #{version} version"
          end

          vagrantfile = Catalog.vagrantfile_for template, version
          berksfile = Catalog.berksfile_for template, version

          if options[:cat]
            @env.ui.output vagrantfile
            @env.ui.output berksfile
          else
            files_root = @env.cwd
            if options[:output]
              @env.ui.info "vagrant-templated received output path #{options[:output]}"
              output_path = Pathname.new options[:output]
              files_root =  if output_path.relative?
                output_path.expand_path files_root
              else
                output_path
              end
              @env.ui.info "vagrant-templated will write the files in: #{files_root}"
            end

            vagrantfile_save_path = Pathname.new('Vagrantfile').expand_path files_root
            vagrantfile_save_path.delete if vagrantfile_save_path.exist? && options[:force]
            raise Vagrant::Templated::Errors::VagrantfileExistsError if vagrantfile_save_path.exist?

            berksfile_save_path = Pathname.new('Berksfile').expand_path files_root
            berksfile_save_path.delete if berksfile_save_path.exist? && options[:force]
            raise Vagrant::Templated::Errors::BerksfileExistsError if berksfile_save_path.exist?

            begin
              vagrantfile_save_path.open('w+') do |f|
                f.write vagrantfile
              end
              @env.ui.info "vagrant-templated created #{vagrantfile_save_path}"
            rescue Errno::EACCES
              raise Vagrant::Templated::Errors::VagrantfileWriteError
            end

            begin
              berksfile_save_path.open('w+') do |f|
                f.write berksfile
              end
              @env.ui.info "vagrant-templated created #{berksfile_save_path}"
            rescue Errno::EACCES
              raise Vagrant::Templated::Errors::BerksfileWriteError
            end
          end

          @env.ui.success 'vagrant-templated finished successfully'
          0
        end

        private

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

              o.on('-o', '--output OUTPUT', String, 'Output path for files. Default to `.`') do |o|
                options[:output] = o
              end

              o.on('-c', '--cat', 'Output Vagrantfile and Berksfile to stdout') do |c|
                options[:cat] = c
              end

              o.on('-f', '--force', 'Overwrite existing Vagrantfile and Berksfile if they exists') do |f|
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
