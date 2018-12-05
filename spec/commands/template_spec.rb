
RSpec.describe Underware::Commands::Template do
  def run_command
    Underware::Utils.run_command(described_class)
  end

  def create_template(relative_path)
    path = File.join(Underware::FilePath.templates_dir, relative_path)
    FileUtils.mkdir_p(File.dirname(path))

    # Create minimal template which just includes the platform it was rendered
    # for.
    File.write(path, "platform: <%= alces.platform %>")
  end

  def expect_rendered(path:, for_platform:)
    expect(
      File.read("#{Underware::Constants::RENDERED_PATH}/#{path}")
    ).to include("platform: #{for_platform}")
  end

  before :each do
    # Ensure templates directory is initially empty, so only testing with files
    # setup in individual tests.
    FileUtils.rm_rf(Underware::FilePath.templates_dir)
  end

  it 'correctly renders all platform files for domain' do
    [
      'platform_x/domain/template_1',
      'platform_x/domain/template_2',
      'platform_y/domain/template_1',
    ].each { |template| create_template(template) }

    run_command

    expect_rendered(path: 'platform_x/domain/template_1', for_platform: :platform_x)
    expect_rendered(path: 'platform_x/domain/template_2', for_platform: :platform_x)
    expect_rendered(path: 'platform_y/domain/template_1', for_platform: :platform_y)
  end
end
