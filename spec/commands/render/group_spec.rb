
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
      Platform config value: <%= config.platform_config_key %>
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

  describe 'with `--platform` option passed' do
    let :platform_config_path do
      Underware::FilePath.platform_config(:test_platform)
    end

    it 'includes config for given platform when forming namespace' do
      Underware::Data.dump(
        platform_config_path,
        platform_config_key: 'platform_config_value'
      )
      File.read Underware::FilePath.platform_config(:test_platform)

      output = run_command(test_group_name, template.path, platform: :test_platform)

      expect(output).to include "Platform config value: platform_config_value\n"
    end

    it 'gives error if no config exists for platform' do
      expect do
        run_command(test_group_name, template.path, platform: :test_platform)
      end.to raise_error(
        Underware::InvalidInput,
        "Unknown platform: test_platform (#{platform_config_path} does not exist)"
      )
    end
  end
end
