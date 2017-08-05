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

    it 'should raise error if Vagrantfile exists' do
      FileUtils.touch @vagrantfile
      expect{
        described_class.new(['rails5'], @env).execute
      }.to raise_error Vagrant::Errors::VagrantfileTemplatedExistsError
    end

    let(:vagrantfile_tag) { '# Vagrantfile generated with ' \
      'https://github.com/afaundez/vagrant-templated'
    }
    let(:berksfile_tag) { '# Berksfile generated with ' \
      'https://github.com/afaundez/vagrant-templated'
    }

    it 'should raise error if Berksfile exists' do
      FileUtils.touch @berksfile
      expect{
        described_class.new(['rails5'], @env).execute
      }.to raise_error Vagrant::Errors::BerksfileTemplatedExistsError
    end

    it 'should create Vagrantfile and Berksfile if both do not exist using template base' do
      expect{
        described_class.new(['base'], @env).execute
      }.to_not raise_error
      expect(File.open(@vagrantfile).read).to include(vagrantfile_tag)
      expect(File.open(@berksfile).read).to include(berksfile_tag)
    end

    it 'should create Vagrantfile and Berksfile if both do not exist using template vagrant-plugin' do
      expect{
        described_class.new(['vagrant-plugin'], @env).execute
      }.to_not raise_error
      expect(File.open(@vagrantfile).read).to include(vagrantfile_tag)
      expect(File.open(@berksfile).read).to include(berksfile_tag)
    end

    it 'should create Vagrantfile and Berksfile if both do not exist using template django1.11' do
      expect{
        described_class.new(['django1.11'], @env).execute
      }.to_not raise_error
      expect(File.open(@vagrantfile).read).to include(vagrantfile_tag)
      expect(File.open(@berksfile).read).to include(berksfile_tag)
    end

    it 'should create Vagrantfile and Berksfile if both do not exist using template rails5' do
      expect{
        described_class.new(['rails5'], @env).execute
      }.to_not raise_error
      expect(File.open(@vagrantfile).read).to include(vagrantfile_tag)
      expect(File.open(@berksfile).read).to include(berksfile_tag)
    end

    context 'and using a suffix' do

      it 'should create Vagrantfile and Berksfile if both do not exist' do
        suffix = 'custom-sufix'
        expect{
          described_class.new(['rails5', '--suffix',  suffix], @env).execute
        }.to_not raise_error
        tag_vagrantfile = [@vagrantfile, suffix].join('.')
        expect(File.open(tag_vagrantfile).read).to include(vagrantfile_tag)
        tag_berksfile = [@berksfile, suffix].join('.')
        expect(File.open(tag_berksfile).read).to include(berksfile_tag)
      end

    end

    context 'and forcing' do

      it 'should replace existing Vagrantfile' do
        FileUtils.touch File.join(@cwd, 'Vagrantfile')
        args = ['rails5', '--force']
        expect{
          described_class.new(args, @env).execute
        }.to_not raise_error
        expect(File.open(@vagrantfile).read).to include(vagrantfile_tag)
        expect(File.open(@berksfile).read).to include(berksfile_tag)
      end

      it 'should replace existing Berksfile' do
        FileUtils.touch File.join(@cwd, 'Berksfile')
        args = ['rails5', '--force']
        expect{
          described_class.new(args, @env).execute
        }.to_not raise_error
        expect(File.open(@vagrantfile).read).to include(vagrantfile_tag)
        expect(File.open(@berksfile).read).to include(berksfile_tag)
      end

      it 'should replace existing Vagrantfile and Berksfile' do
        FileUtils.touch File.join(@cwd, 'Vagrantfile')
        FileUtils.touch File.join(@cwd, 'Berksfile')
        args = ['rails5', '--force']
        expect{
          described_class.new(args, @env).execute
        }.to_not raise_error
        expect(File.open(@vagrantfile).read).to include(vagrantfile_tag)
        expect(File.open(@berksfile).read).to include(berksfile_tag)
      end

    end

  end

  context 'when using a invalid template' do

    it 'should raise an error' do
      expect{
        described_class.new(['fake-template'], @env).execute
      }.to raise_error Vagrant::Errors::VagrantTemplatedOptionNotFound
    end

  end

end
