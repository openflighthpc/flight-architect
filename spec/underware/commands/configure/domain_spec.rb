
# frozen_string_literal: true


RSpec.describe Underware::Commands::Configure::Domain do
  def run_configure_domain
    Underware::Utils.run_command(
      Underware::Commands::Configure::Domain
    )
  end

  before :each do
    FileSystem.setup(&:with_minimal_configure_file)
  end

  it 'creates correct configurator' do
    expect(Underware::Configurator).to receive(:new).with(
      instance_of(Underware::Namespaces::Alces),
      questions_section: :domain
    ).and_call_original

    run_configure_domain
  end
end
