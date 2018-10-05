
# frozen_string_literal: true

require 'staging'
require 'alces_utils'

RSpec.describe Metalware::Staging do
  include AlcesUtils

  def manifest
    Metalware::Staging.manifest
  end

  def update(&b)
    Metalware::Staging.update(&b)
  end

  it 'loads a blank file list if the manifest is missing' do
    expect(manifest[:files]).to be_a(Hash)
    expect(manifest[:files]).to be_empty
  end

  describe '#push_file' do
    let(:test_content) { 'I am a test file' }
    let(:test_sync) { '/etc/some-random-location' }
    let(:test_staging) { File.join('/var/lib/metalware/staging', test_sync) }

    before do
      update { |staging| staging.push_file(test_sync, test_content) }
    end

    it 'writes the file to the correct location' do
      expect(File.exist?(test_staging)).to eq(true)
    end

    it 'writes the correct content' do
      expect(File.read(test_staging)).to eq(test_content)
    end

    it 'saves the default options' do
      expect(manifest[:files].first[1][:managed]).to eq(false)
      expect(manifest[:files].first[1][:validator]).to eq(nil)
    end

    it 'updates the manifest' do
      expect(manifest[:files][test_sync]).not_to be_empty
    end

    it 'can push more files' do
      update do |staging|
        staging.push_file('second', '')
        staging.push_file('third', '')
      end
      keys = manifest[:files].keys
      expect(manifest[:files].length).to eq(3)
      expect(keys[1]).to eq('second')
      expect(keys[2]).to eq('third')
    end

    it 'saves the additional options' do
      update do |staging|
        staging.push_file('other', '', managed: true, validator: 'validate')
      end
      key = manifest[:files].keys.last
      expect(manifest[:files][key][:managed]).to eq(true)
      expect(manifest[:files][key][:validator]).to eq('validate')
    end
  end
end
