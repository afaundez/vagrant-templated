require_relative 'spec_helper'
require 'stringio'

describe Vagrant::Templated::Command::Init do

  before :context do
    @tmp = File.join File.dirname(__FILE__), 'tmp'
  end

  before :example do
    @cwd = File.join @tmp, SecureRandom.urlsafe_base64
    FileUtils.mkdir_p @cwd
    @env = Vagrant::Environment.new cwd: @cwd
    @vagrantfile = File.join @cwd, 'Vagrantfile'
    @berksfile = File.join @cwd, 'Berksfile'
  end

  after :example do
    FileUtils.rm_rf @cwd
  end

  it 'should have a version number' do
    expect(::Vagrant::Templated::VERSION).to be_truthy
  end

  it 'should display help whitout any argument' do
    expect{
      described_class.new([], @env).execute
    }.to raise_error Vagrant::Errors::CLIInvalidUsage
  end

  context 'when asking for help' do

    it 'should display usage' do
      usage = /Usage: vagrant templated init \[options\] <template>/
      expect{
        described_class.new(['-h'], @env).execute
      }.to output(usage).to_stdout_from_any_process
    end

  end

  context 'when using a valid template' do

    let(:vagrantfile_header) {
      ERB.new "# vagrant-templated vagrantfile for <%= template %> <%= version %>\n"\
      '# check https://github.com/afaundez/vagrant-templated for more options'
    }
    let(:berksfile_header) {
      ERB.new "# vagrant-templated berksfile for <%= template %> <%= version %>\n"\
      '# check https://github.com/afaundez/vagrant-templated for more options'
    }

    it 'should raise error if Vagrantfile exists' do
      FileUtils.touch @vagrantfile
      expect{
        described_class.new(['rails'], @env).execute
      }.to raise_error Vagrant::Templated::Errors::VagrantfileExistsError
    end

    it 'should raise error if Berksfile exists' do
      FileUtils.touch @berksfile
      expect{
        described_class.new(['rails'], @env).execute
      }.to raise_error Vagrant::Templated::Errors::BerksfileExistsError
    end

    it 'should create Vagrantfile and Berksfile if both do not exist using template base' do
      template = 'base'
      version = '1.0'
      expect{
        described_class.new([template], @env).execute
      }.to_not raise_error
      expect(File.open(@vagrantfile).read).to include(vagrantfile_header.result binding)
      expect(File.open(@berksfile).read).to include(berksfile_header.result binding)
    end

    it 'should create Vagrantfile and Berksfile if both do not exist using template vagrant-plugin' do
      template = 'vagrant-plugin'
      version = '1.9'
      expect{
        described_class.new([template], @env).execute
      }.to_not raise_error
      expect(File.open(@vagrantfile).read).to include(vagrantfile_header.result binding)
      expect(File.open(@berksfile).read).to include(berksfile_header.result binding)
    end


    it 'should create Vagrantfile and Berksfile if both do not exist using template django' do
      template = 'django'
      version = '1.11'
      expect{
        described_class.new([template], @env).execute
      }.to_not raise_error
      expect(File.open(@vagrantfile).read).to include(vagrantfile_header.result binding)
      expect(File.open(@berksfile).read).to include(berksfile_header.result binding)
    end


    it 'should create Vagrantfile and Berksfile if both do not exist using template rails' do
      template = 'rails'
      version = '5.1'
      expect{
        described_class.new([template], @env).execute
      }.to_not raise_error
      expect(File.open(@vagrantfile).read).to include(vagrantfile_header.result binding)
      expect(File.open(@berksfile).read).to include(berksfile_header.result binding)
    end


    it 'should create Vagrantfile and Berksfile if both do not exist using template nodejs' do
      template = 'nodejs'
      version = '6.11'
      expect{
        described_class.new([template], @env).execute
      }.to_not raise_error
      expect(File.open(@vagrantfile).read).to include(vagrantfile_header.result binding)
      expect(File.open(@berksfile).read).to include(berksfile_header.result binding)
    end

    context 'and using and output' do

      before :example do
        @cwd = File.join @tmp, SecureRandom.urlsafe_base64
        FileUtils.mkdir_p @cwd
        @env = Vagrant::Environment.new cwd: @cwd
        @output = 'output'
        FileUtils.mkdir_p File.join(@cwd, @output)
        @vagrantfile = File.join @cwd, @output, 'Vagrantfile'
        @berksfile = File.join @cwd, @output, 'Berksfile'
      end

      it 'should create Vagrantfile and Berksfile if both do not exist' do
        template = 'rails'
        version = '5.1'
        expect{
          described_class.new([template, '--output',  @output], @env).execute
        }.to_not raise_error
        expect(File.open(@vagrantfile).read).to include(vagrantfile_header.result binding)
        expect(File.open(@berksfile).read).to include(berksfile_header.result binding)
      end

    end

    context 'and forcing' do

      it 'should replace existing Vagrantfile' do
        template = 'rails'
        version = '5.1'
        FileUtils.touch File.join(@cwd, 'Vagrantfile')
        args = [template, '--force']
        expect{
          described_class.new(args, @env).execute
        }.to_not raise_error
        expect(File.open(@vagrantfile).read).to include(vagrantfile_header.result binding)
        expect(File.open(@berksfile).read).to include(berksfile_header.result binding)
      end

      it 'should replace existing Berksfile' do
        template = 'rails'
        version = '5.1'
        FileUtils.touch File.join(@cwd, 'Berksfile')
        args = [template, '--force']
        expect{
          described_class.new(args, @env).execute
        }.to_not raise_error
        expect(File.open(@vagrantfile).read).to include(vagrantfile_header.result binding)
        expect(File.open(@berksfile).read).to include(berksfile_header.result binding)
      end

      it 'should replace existing Vagrantfile and Berksfile' do
        template = 'rails'
        version = '5.1'
        FileUtils.touch File.join(@cwd, 'Vagrantfile')
        FileUtils.touch File.join(@cwd, 'Berksfile')
        args = [template, '--force']
        expect{
          described_class.new(args, @env).execute
        }.to_not raise_error
        expect(File.open(@vagrantfile).read).to include(vagrantfile_header.result binding)
        expect(File.open(@berksfile).read).to include(berksfile_header.result binding)
      end

    end

  end

  context 'when using a invalid template' do

    it 'should raise an error' do
      expect{
        described_class.new(['fake-template'], @env).execute
      }.to raise_error Vagrant::Templated::Errors::TemplateNotFound
    end

  end

end
