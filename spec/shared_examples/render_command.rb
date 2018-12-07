
RSpec.shared_examples 'render command' do |args|
  def run_command(*args)
    Underware::AlcesUtils.redirect_std(:stdout) do
      Underware::Utils.run_command(
        described_class, *args
      )
    end[:stdout].read
  end

  let :template do
    template_contents = <<~TEMPLATE.strip_heredoc
      Rendered with scope: <%= scope.class %>
      #{'Scope name: <%= scope.name %>' unless described_class == Underware::Commands::Render::Domain}
      Platform config value: <%= config.platform_config_key %>
    TEMPLATE

    Tempfile.create.tap { |t| t.write(template_contents) }
  end

  # Below tests are very similar for all `render` commands, so can live here
  # while remaining clear. Other tests which vary more between commands have
  # been left in their respective files to avoid over-abstracting and confusing
  # things.
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

      output = run_command(*command_args, platform: :test_platform)

      expect(output).to include "Platform config value: platform_config_value\n"
    end

    it 'gives error if no config exists for platform' do
      expect do
        run_command(*command_args, platform: :test_platform)
      end.to raise_error(
        Underware::InvalidInput,
        "Unknown platform: test_platform (#{platform_config_path} does not exist)"
      )
    end
  end
end
