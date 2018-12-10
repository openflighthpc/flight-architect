
# frozen_string_literal: true

require 'underware/managed_file'

RSpec.describe Underware::ManagedFile do
  describe '#content' do
    let :managed_file { Tempfile.new }
    let :rendered_content { 'content' }

    before :each do
      # Want to read and write real temporary files.
      FakeFS.deactivate!
    end

    RSpec.shared_examples 'includes managed file markers' do |comment_char|
      marker_comment_regex = /#{comment_char}{3,}/

      it "includes start marker with `#{comment_char}` as comment character" do
        expect(subject).to match(
          /#{marker_comment_regex} UNDERWARE_START #{marker_comment_regex}/
        )
      end

      it "includes end marker with `#{comment_char}` as comment character" do
        expect(subject).to match(
          /#{marker_comment_regex} UNDERWARE_END #{marker_comment_regex}/
        )
      end

      it "includes managed file info with `#{comment_char}` as comment character" do
        expect(subject).to include(
          "#{comment_char} This section of this file is managed by Alces Underware"
        )
      end

      it "ensures file ends with a newline" do
        expect(subject).to end_with("\n")
      end
    end

    context 'when no `comment_char` option passed' do
      subject do
        described_class.content(managed_file, rendered_content)
      end

      it_behaves_like 'includes managed file markers', '#'
    end

    context "when `comment_char: ';'` option passed" do
      subject do
        described_class.content(
          managed_file,
          rendered_content,
          comment_char: ';'
        )
      end

      it_behaves_like 'includes managed file markers', ';'
    end

    context 'on repeated runs with same rendered content' do
      RSpec.shared_examples 'gives same result on repeated runs' do
        before :each do
          managed_file.write(initial_content)
          managed_file.flush
          managed_file.seek(0)
        end

        it 'gives same result on repeated runs' do
          first_result = described_class.content(managed_file, rendered_content)
          # Need to write the first result to the managed file so that second
          # result is using file containing this rather than the initial
          # content (even though these should be the same).
          managed_file.write(first_result)
          managed_file.flush

          second_result = described_class.content(managed_file, rendered_content)

          expect(first_result).to eq(initial_content)
          expect(second_result).to eq(first_result)
        end

      end

      context 'when initial file just contains managed section' do
        let :initial_content do
          described_class.content(managed_file, rendered_content)
        end

        it_behaves_like 'gives same result on repeated runs'
      end

      context 'when initial file contains content around managed section' do
        let :initial_content do
          managed_section = described_class.content(managed_file, rendered_content)
          "\nbefore\n#{managed_section}\nafter\n"
        end

        it_behaves_like 'gives same result on repeated runs'
      end
    end
  end
end
