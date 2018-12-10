
# frozen_string_literal: true

require 'underware/group_cache'

RSpec.describe Underware::Commands::Configure::Node do
  def run_configure_node(node)
    Underware::Utils.run_command(
      Underware::Commands::Configure::Node, node
    )
  end

  let(:alces) { Underware::Namespaces::Alces.new }

  let(:test_group) do
    Underware::Namespaces::Group.new(initial_alces, 'testnodes', index: 1)
  end

  let(:filesystem) do
    FileSystem.setup do |fs|
      fs.with_minimal_configure_file
      fs.dump(Underware::FilePath.domain_answers, {})
      fs.dump(Underware::FilePath.group_answers('testnodes'), {})
    end
  end

  before do
    use_mock_genders
    mock_validate_genders_success
    allow(Underware::Namespaces::Alces).to receive(:new).and_return(alces)
  end

  it 'creates correct configurator' do
    filesystem.test do
      expect(Underware::Configurator).to receive(:new).with(
        instance_of(Underware::Namespaces::Alces),
        questions_section: :node,
        name: 'testnode01'
      ).and_call_original

      run_configure_node 'testnode01'
    end
  end
end
