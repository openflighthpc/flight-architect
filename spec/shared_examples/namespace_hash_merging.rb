
RSpec.shared_examples 'namespace_hash_merging' do |args|
  description = args.fetch(:description)
  expected_hash_merger_input = args.fetch(:expected_hash_merger_input)

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
