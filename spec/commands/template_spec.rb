
RSpec.describe Underware::Commands::Template do
  def run_command
    Underware::Utils.run_command(described_class)
  end

  def create_template(relative_path)
    path = File.join(Underware::FilePath.templates_dir, relative_path)
    FileUtils.mkdir_p(File.dirname(path))

    # Create minimal template which just includes things we want to assert
    # presence of in `expect_rendered`.
    template = <<~TEMPLATE
      platform: <%= alces.platform %>
      scope_type: <%= alces.scope.class.to_s.downcase.split('::').last %>
      scope_name: <%= alces.scope.name if alces.scope.respond_to?(:name) %>
    TEMPLATE
    File.write(path, template)
  end

  def expect_rendered(path:, for_platform:, for_scope_type:, for_scope_name: nil)
    rendered_template = File.read("#{Underware::Constants::RENDERED_PATH}/#{path}")

    expect(rendered_template).to include("platform: #{for_platform}")
    expect(rendered_template).to include("scope_type: #{for_scope_type}")
    if for_scope_name
      expect(rendered_template).to include("scope_name: #{for_scope_name}")
    end
  end

  def expect_not_rendered(path:)
    expect(
      File.exists?("#{Underware::Constants::RENDERED_PATH}/#{path}")
    ).to be false
  end

  before :each do
    # Ensure templates directory is initially empty, so only testing with files
    # setup in individual tests.
    FileUtils.rm_rf(Underware::FilePath.templates_dir)

    FileUtils.touch(Underware::FilePath.platform_config(:platform_x))
    FileUtils.touch(Underware::FilePath.platform_config(:platform_y))
  end

  it 'correctly renders all platform files for domain' do
    [
      'platform_x/domain/template_1',
      'platform_x/domain/template_2',
      'platform_y/domain/template_1',
    ].each { |template| create_template(template) }

    run_command

    expect_rendered(
      path: 'platform_x/domain/template_1',
      for_platform: :platform_x,
      for_scope_type: :domain
    )
    expect_rendered(
      path: 'platform_x/domain/template_2',
      for_platform: :platform_x,
      for_scope_type: :domain
    )
    expect_rendered(
      path: 'platform_y/domain/template_1',
      for_platform: :platform_y,
      for_scope_type: :domain
    )
  end

  it 'correctly renders all content files for domain, for each platform' do
    create_template 'content/domain/shared_template'

    run_command

    expect_rendered(
      path: 'platform_x/domain/shared_template',
      for_platform: :platform_x,
      for_scope_type: :domain
    )
    expect_rendered(
      path: 'platform_y/domain/shared_template',
      for_platform: :platform_y,
      for_scope_type: :domain
    )
  end

  it 'correctly renders all platform files for each group (including orphan group)' do
    Underware::GroupCache.update { |cache| cache.add(:user_configured_group) }
    create_template 'platform_x/group/x_template'
    create_template 'platform_y/group/y_template'

    run_command

    expect_rendered(
      path: 'platform_x/group/user_configured_group/x_template',
      for_platform: :platform_x,
      for_scope_type: :group,
      for_scope_name: 'user_configured_group'
    )
    expect_rendered(
      path: 'platform_x/group/orphan/x_template',
      for_platform: :platform_x,
      for_scope_type: :group,
      for_scope_name: 'orphan'
    )
    expect_rendered(
      path: 'platform_y/group/user_configured_group/y_template',
      for_platform: :platform_y,
      for_scope_type: :group,
      for_scope_name: 'user_configured_group'
    )
    expect_rendered(
      path: 'platform_y/group/orphan/y_template',
      for_platform: :platform_y,
      for_scope_type: :group,
      for_scope_name: 'orphan'
    )
  end

  it 'correctly renders all content files for each group, for each platform' do
    Underware::GroupCache.update { |cache| cache.add(:user_configured_group) }
    create_template 'content/group/shared_template'

    run_command

    expect_rendered(
      path: 'platform_x/group/user_configured_group/shared_template',
      for_platform: :platform_x,
      for_scope_type: :group,
      for_scope_name: 'user_configured_group'
    )
    expect_rendered(
      path: 'platform_x/group/orphan/shared_template',
      for_platform: :platform_x,
      for_scope_type: :group,
      for_scope_name: 'orphan'
    )
    expect_rendered(
      path: 'platform_y/group/user_configured_group/shared_template',
      for_platform: :platform_y,
      for_scope_type: :group,
      for_scope_name: 'user_configured_group'
    )
    expect_rendered(
      path: 'platform_y/group/orphan/shared_template',
      for_platform: :platform_y,
      for_scope_type: :group,
      for_scope_name: 'orphan'
    )
  end

  it 'does not render any files for platform without a config file' do
    create_template('unknown_platform/domain/some_template')

    run_command

    expect_not_rendered(path: 'unknown_platform/domain/some_template')
  end
end
