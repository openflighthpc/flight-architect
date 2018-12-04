
require 'underware/commands/render/group'

RSpec.describe Underware::Commands::Render::Group do
  def run_command(*args)
    Underware::AlcesUtils.redirect_std(:stdout) do
      Underware::Utils.run_command(
        Underware::Commands::Render::Group, *args
      )
    end[:stdout].read
  end

  before :each do
    Underware::GroupCache.update do |cache|
      cache.add(test_group_name)
    end
  end

  let :test_group_name { 'testgroup' }

  let :template do
    template_contents = <<~TEMPLATE.strip_heredoc
      Rendered with scope: <%= scope.class %>
      Scope name: <%= scope.name %>
    TEMPLATE

    Tempfile.create.tap { |t| t.write(template_contents) }
  end

  it 'renders template against the given group and outputs result' do
    output = run_command(test_group_name, template.path)

    expect(output).to include "Rendered with scope: Underware::Namespaces::Group\n"
    expect(output).to include "Scope name: #{test_group_name}\n"
  end

  it 'gives error if group cannot be found' do
    expect do
      run_command('unknown_group01', template.path)
    end.to raise_error(
      Underware::InvalidInput, "Could not find group: unknown_group01"
    )
  end
end
