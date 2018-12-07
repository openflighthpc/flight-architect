
RSpec.describe Underware::Commands::Template do
  def run_command
    Underware::Utils.run_command(described_class)
  end

  def create_template(relative_path)
    path = File.join(Underware::FilePath.templates_dir, relative_path)

    # Create minimal template which just includes things we want to assert
    # presence of in `expect_rendered`.
    template = <<~TEMPLATE
      platform: <%= alces.platform %>
      scope_type: <%= alces.scope.scope_type %>
      scope_name: <%= alces.scope.name if alces.scope.respond_to?(:name) %>
    TEMPLATE

    Underware::Utils.create_file(path, content: template)
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

    # To render templates for nodes we need to be able to call this and have an
    # array of nodes returned; stub this out so don't need to care about this
    # when not explicitly testing rendering for nodes.
    allow(Underware::NodeattrInterface).to receive(:all_nodes).and_return([])
  end

  it 'correctly renders all platform files for domain' do
    [
      'platform_x/domain/some/path/template_1',
      'platform_x/domain/some/path/template_2',
      'platform_y/domain/some/path/template_1',
    ].each { |template| create_template(template) }

    run_command

    expect_rendered(
      path: 'platform_x/domain/some/path/template_1',
      for_platform: :platform_x,
      for_scope_type: :domain
    )
    expect_rendered(
      path: 'platform_x/domain/some/path/template_2',
      for_platform: :platform_x,
      for_scope_type: :domain
    )
    expect_rendered(
      path: 'platform_y/domain/some/path/template_1',
      for_platform: :platform_y,
      for_scope_type: :domain
    )
  end

  it 'correctly renders all content files for domain, for each platform' do
    create_template 'content/domain/some/path/shared_template'

    run_command

    expect_rendered(
      path: 'platform_x/domain/some/path/shared_template',
      for_platform: :platform_x,
      for_scope_type: :domain
    )
    expect_rendered(
      path: 'platform_y/domain/some/path/shared_template',
      for_platform: :platform_y,
      for_scope_type: :domain
    )
  end

  it 'correctly renders all platform files for each group (including orphan group)' do
    Underware::GroupCache.update { |cache| cache.add(:user_configured_group) }
    create_template 'platform_x/group/some/path/x_template'
    create_template 'platform_y/group/some/path/y_template'

    run_command

    expect_rendered(
      path: 'platform_x/group/user_configured_group/some/path/x_template',
      for_platform: :platform_x,
      for_scope_type: :group,
      for_scope_name: 'user_configured_group'
    )
    expect_rendered(
      path: 'platform_x/group/orphan/some/path/x_template',
      for_platform: :platform_x,
      for_scope_type: :group,
      for_scope_name: 'orphan'
    )
    expect_rendered(
      path: 'platform_y/group/user_configured_group/some/path/y_template',
      for_platform: :platform_y,
      for_scope_type: :group,
      for_scope_name: 'user_configured_group'
    )
    expect_rendered(
      path: 'platform_y/group/orphan/some/path/y_template',
      for_platform: :platform_y,
      for_scope_type: :group,
      for_scope_name: 'orphan'
    )
  end

  it 'correctly renders all content files for each group, for each platform' do
    Underware::GroupCache.update { |cache| cache.add(:user_configured_group) }
    create_template 'content/group/some/path/shared_template'

    run_command

    expect_rendered(
      path: 'platform_x/group/user_configured_group/some/path/shared_template',
      for_platform: :platform_x,
      for_scope_type: :group,
      for_scope_name: 'user_configured_group'
    )
    expect_rendered(
      path: 'platform_x/group/orphan/some/path/shared_template',
      for_platform: :platform_x,
      for_scope_type: :group,
      for_scope_name: 'orphan'
    )
    expect_rendered(
      path: 'platform_y/group/user_configured_group/some/path/shared_template',
      for_platform: :platform_y,
      for_scope_type: :group,
      for_scope_name: 'user_configured_group'
    )
    expect_rendered(
      path: 'platform_y/group/orphan/some/path/shared_template',
      for_platform: :platform_y,
      for_scope_type: :group,
      for_scope_name: 'orphan'
    )
  end

  it 'correctly renders all platform files for each node' do
    allow(Underware::NodeattrInterface).to receive(:all_nodes).and_return(['some_node'])
    create_template 'platform_x/node/some/path/x_template'
    create_template 'platform_y/node/some/path/y_template'

    run_command

    expect_rendered(
      path: 'platform_x/node/some_node/some/path/x_template',
      for_platform: :platform_x,
      for_scope_type: :node,
      for_scope_name: 'some_node'
    )
    expect_rendered(
      path: 'platform_y/node/some_node/some/path/y_template',
      for_platform: :platform_y,
      for_scope_type: :node,
      for_scope_name: 'some_node'
    )
  end

  it 'correctly renders all content files for each node, for each platform' do
    allow(Underware::NodeattrInterface).to receive(:all_nodes).and_return(['some_node'])
    create_template 'content/node/some/path/shared_template'

    run_command

    expect_rendered(
      path: 'platform_x/node/some_node/some/path/shared_template',
      for_platform: :platform_x,
      for_scope_type: :node,
      for_scope_name: 'some_node'
    )
    expect_rendered(
      path: 'platform_y/node/some_node/some/path/shared_template',
      for_platform: :platform_y,
      for_scope_type: :node,
      for_scope_name: 'some_node'
    )
  end

  it 'does not render any files for platform without a config file' do
    create_template('unknown_platform/domain/some_template')

    run_command

    expect_not_rendered(path: 'unknown_platform/domain/some_template')
  end

  it 'clears out pre-existing files from rendered files directory' do
    previously_rendered_file_path = File.join(
      Underware::Constants::RENDERED_PATH,
      'some_platform/node/some_node/some_template'
    )
    Underware::Utils.create_file(previously_rendered_file_path)

    run_command

    expect(File.exists?(previously_rendered_file_path)).not_to be true
  end

  # Do not clear previously rendered system files to preserve rendered genders
  # file, as well as any possible other future rendered system filess.
  it 'does not clear out pre-existing files in rendered system files directory' do
    previously_rendered_file_path = File.join(
      Underware::Constants::RENDERED_PATH,
      'system/some_file'
    )
    Underware::Utils.create_file(previously_rendered_file_path)

    run_command

    expect(File.exists?(previously_rendered_file_path)).to be true
  end
end
