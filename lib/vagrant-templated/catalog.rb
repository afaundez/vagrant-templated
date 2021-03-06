require 'yaml'
require 'erb'

module Vagrant
  module Templated
    module Catalog
      class << self

        def vagrantfile_for(template, version)
          template_attributes = attributes_for template, version
          vagrantfile_template = File.read(Catalog.root.join 'config/templates/Vagrantfile.erb')
          ERB.new(vagrantfile_template, nil, '-').result binding
        end

        def berksfile_for(template, version)
          template_attributes = attributes_for template, version
          berksfile_template = File.read(Catalog.root.join 'config/templates/Berksfile.erb')
          ERB.new(berksfile_template, nil, '-').result binding
        end

        def patch(template, version)
          max_version_for(template)
        end

        def templates
          attributes.keys
        end

        def attributes_for(template, version)
          raise Vagrant::Templated::Errors::VersionNotFound unless versions_for(template).include? version
          attributes[template][version]
        end

        def max_version_for(template)
          versions_for(template).max do |a, b|
            Gem::Version.new(a) <=> Gem::Version.new(b)
          end
        end

        def versions_for(template)
          raise Vagrant::Templated::Errors::TemplateNotFound unless attributes.include? template
          attributes[template].keys
        end

        def root
          @root ||= Pathname.new File.expand_path '../..', File.dirname(File.expand_path(__FILE__))
        end

        private

          def attributes
            @attributes ||= load_attributes_files
          end

          def load_attributes_files
            attributes = {}
            attributes_filelist.each do |attributes_file|
              template = File.basename File.dirname(attributes_file)
              version = File.basename(attributes_file, '.yml')
              attributes[template] ||= {}
              attributes[template][version] ||= YAML.load_file(attributes_file)
            end
            attributes
          end

          def attributes_filelist
            Dir.glob(root.join 'config/attributes/**/*.yml')
          end
      end
    end
  end
end
