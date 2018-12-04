
RSpec.shared_examples 'namespace_hash_merging' do |args|
  base_description = args.fetch(:description)
  base_expected_hash_merger_input = args.fetch(:expected_hash_merger_input)

  shared_examples 'calls hash mergers correctly' do |local_args|
    description = local_args.fetch(:description)

    let :expected_hash_merger_input do
      local_args.fetch(:expected_hash_merger_input)
    end

    it "#{description}, to Config HashMerger" do
      expect(alces.hash_mergers.config).to receive(:merge).with(
        expected_hash_merger_input
      )

      subject.config
    end

    it "#{description}, to Answer HashMerger" do
      expect(alces.hash_mergers.answer).to receive(:merge).with(
        expected_hash_merger_input
      )

      subject.answer
    end
  end

  context 'when no platform passed' do
    let :platform { nil }

    include_examples 'calls hash mergers correctly',
      description: base_description,
      expected_hash_merger_input: base_expected_hash_merger_input
  end

  context 'when platform passed' do
    let :platform { 'my_platform' }

    include_examples 'calls hash mergers correctly',
      description: "#{base_description}, with platform as a symbol",
      expected_hash_merger_input:
        base_expected_hash_merger_input.merge(platform: :my_platform)
  end
end
