
# frozen_string_literal: true

require 'underware/namespaces/alces'
require 'underware/hash_mergers'
require 'underware/spec/alces_utils'

RSpec.describe Underware::Namespaces::Alces do
  # TODO: The Alces class should not be tested with the rampant, convoluted
  # mocking of itself provided by AlcesUtils; we should remove all usage of
  # this and try to test it with as little mocking as possible, and only mock
  # individual functions (and never mock the Alces class itself) as needed.

  let :alces do
    described_class.new
  end

  describe '#render_string' do
    Underware::AlcesUtils.mock self, :each do
      define_method_testing do
        Underware::HashMergers::UnderwareRecursiveOpenStruct.new(
          {
            key: 'value',
            embedded_key: '<%= alces.testing.key %>',
            infinite_value1: '<%= alces.testing.infinite_value2 %>',
            infinite_value2: '<%= alces.testing.infinite_value1 %>',
            false_key: false
          },
          eager_render: alces.eager_render
        ) do |template_string|
          alces.render_string(template_string)
        end
      end
    end

    it 'can template a simple value' do
      expect(alces.render_string('<%= alces.testing.key %>')).to eq('value')
    end

    it 'can do a single erb replacement' do
      rendered = alces.render_string('<%= alces.testing.embedded_key %>')
      expect(rendered).to eq('value')
    end

    it 'errors if recursion depth is exceeded' do
      expect do
        output = alces.render_string('<%= alces.testing.infinite_value1 %>')
        STDERR.puts "Template output: #{output}"
      end.to raise_error(Underware::RecursiveConfigDepthExceededError)
    end

    it 'evalutes the false string as Falsey' do
      template = '<%= alces.testing.false_key ? "true" : "false" %>'
      expect(alces.render_string(template)).to eq(false)
    end

    context 'with a delay whilst rendering templates' do
      let(:template) { '<% sleep 0.2 %><%= key %>' }
      let(:long_sleep) { '<% sleep 0.3 %>' }

      def render_delay_template_in_thread
        Thread.new do
          rendered = alces.render_string(template, key: 'correct')
          expect(rendered).to eq('correct')
        end
      end

      it 'preserve the scope when threaded' do
        t = render_delay_template_in_thread
        sleep 0.1
        alces.render_string(long_sleep, key: 'incorrect scope')
        t.join
      end
    end
  end

  describe '#render_file' do
    def write_template(content)
      template_file = Tempfile.new.tap do |f|
        f.write(content)
      end

      template_file.path
    end

    it 'loads given template file and renders against namespace' do
      template = write_template('<%= 5 + 5 %>')

      result = alces.render_file(template)

      expect(result).to eq(10)
    end

    it 'can be passed dynamic namespace to use when rendering' do
      template = write_template('<%= foo %>')

      result = alces.render_file(template, foo: 'bar')

      expect(result).to eq('bar')
    end

    it 'includes template path in error if render fails' do
      template = write_template('<% raise StandardError, "something went wrong" %>')

      expect do
        alces.render_file(template)
      end.to raise_error(
        /Failed to render template: #{template}\nsomething went wrong/
      )
    end
  end

  # NOTE: Trailing/ (leading) white space should be ignored for the
  # conversion. Hence why some of the strings have spaces
  describe 'parses the rendered results' do
    it 'converts the true string' do
      expect(alces.render_string(' true')).to be_a(TrueClass)
    end

    it 'converts the false string' do
      expect(alces.render_string('false ')).to be_a(FalseClass)
    end

    it 'converts the nil string' do
      expect(alces.render_string('nil')).to be_a(NilClass)
    end

    it 'converts integers' do
      expect(alces.render_string(' 1234 ')).to eq(1234)
    end
  end

  describe 'default template namespace' do
    let(:domain_config) { { key: 'domain' } }

    Underware::AlcesUtils.mock self, :each do
      config(alces.domain, domain_config)
    end

    it 'templates against domain if no config is specified' do
      expect(alces.render_string('<%= config.key %>')).to eq('domain')
    end
  end

  describe '#build_interface' do
    before :each do
      allow(Underware::Network)
        .to receive(:available_interfaces)
        .and_return(['eth2', 'eth4'])
    end

    it 'gives answer to configured_build_interface question if present' do
      Underware::Data.dump(
        Underware::FilePath.domain_answers,
        configured_build_interface: 'eth4'
      )

      expect(alces.build_interface).to eq('eth4')
    end

    it 'gives first available network interface if answer not present' do
      # Guarantee no answers present.
      Underware::Data.dump(Underware::FilePath.domain_answers, {})

      expect(alces.build_interface).to eq('eth2')
    end
  end

  describe '#data' do
    it 'provides access to data in corresponding data directory file' do
      data_file_path = Underware::FilePath.namespace_data_file('mydata')
      Underware::Data.dump(data_file_path, foo: { bar: 'baz' })

      expect(alces.data.mydata.foo.bar).to eq('baz')
      expect(alces.data.mydata.non_existent).to be nil
      expect(alces.data.mydata).to be_a(Hashie::Mash)
    end

    it 'gives useful error when try to access data for non-existent file' do
      data_file_path = Underware::FilePath.namespace_data_file('non_existent')

      expect do
        alces.data.non_existent.foo
      end.to raise_error(
        Underware::UserUnderwareError,
        "Requested data file doesn't exist: #{data_file_path}"
      )
    end

    it 'appropriately handles respond_to? as whether data file exists' do
      existent_path = Underware::FilePath.namespace_data_file('existent')
      FileUtils.touch(existent_path)

      expect(alces.data).to respond_to(:existent)
      expect(alces.data).not_to respond_to(:non_existent)
    end
  end

  context 'when a template returns nil' do
    let(:underware_log) { instance_spy(Underware::UnderwareLog) }

    Underware::AlcesUtils.mock(self, :each) do
      allow(Underware::UnderwareLog).to \
        receive(:underware_log).and_return(underware_log)
      config(alces.domain, nil: nil)
    end

    it 'templates have nil detection' do
      alces.render_string('<%= domain.config.nil %>')
      expect(underware_log).to \
        have_received(:warn).once.with(/.*domain.config.nil\Z/)
    end
  end

  # Note scope is tested by rendering a template containing alces.scope
  # This allows the dynamic namespace to be set as if it was rendering a real
  # template
  describe '#scope' do
    let(:scope_template) { '<%= alces.scope.class %>' }
    let(:node_class) { Underware::Namespaces::Node }
    let(:group_class) { Underware::Namespaces::Group }
    let(:node_double) do
      instance_double(node_class, class: node_class)
    end
    let(:group_double) do
      instance_double(group_class, class: group_class)
    end

    def render_scope_template(**dynamic)
      alces.render_string(scope_template, **dynamic).constantize
    end

    it 'defaults to the Domain namespace' do
      expect(render_scope_template).to eq(alces.domain.class)
    end

    it 'errors if a group and node are both in scope' do
      expect do
        render_scope_template(node: node_double, group: group_double)
      end.to raise_error(Underware::ScopeError)
    end

    it 'can set a node as the scope' do
      expect(render_scope_template(node: node_double)).to eq(node_class)
    end

    it 'can set a group as the scope' do
      expect(render_scope_template(group: group_double)).to eq(group_class)
    end
  end

  shared_examples 'scope method tests' do |scope_class|
    let(:scope_str) { scope_class.to_s }
    let(:test_h) { instance_double(OpenStruct, test: scope_str) }

    let(:scope) do
      d = instance_double(scope_class, class: scope_str, config: test_h, answer: test_h)
      d.define_singleton_method(:is_a?) do |input|
        input == scope_class
      end
      d
    end

    before do
      # XXX We shouldn't stub the System Under Test here (see
      # https://robots.thoughtbot.com/don-t-stub-the-system-under-test).
      allow(alces).to receive(:scope).and_return(scope)
    end

    describe '#domain' do
      it 'returns the domain namespace' do
        domain_class = Underware::Namespaces::Domain.to_s
        expect(alces.render_string('<%= alces.domain.class %>')).to eq(domain_class)
      end
    end

    describe '#config' do
      it 'uses the scope to obtain the config' do
        expect(alces.render_string('<%= alces.config.test %>')).to eq(scope_str)
      end
    end

    describe '#answer' do
      it 'uses the scope to obtain the config' do
        expect(alces.render_string('<%= alces.answer.test %>')).to eq(scope_str)
      end
    end
  end

  shared_examples '#node errors' do
    describe '#node' do
      it 'errors' do
        expect { alces.node }.to raise_error(Underware::ScopeError)
      end
    end
  end

  shared_examples '#group errors' do
    describe '#group' do
      it 'errors' do
        expect { alces.group }.to raise_error(Underware::ScopeError)
      end
    end
  end

  context 'with a Domain scope' do
    include_examples 'scope method tests', Underware::Namespaces::Domain
    include_examples '#node errors'
    include_examples '#group errors'
  end

  context 'with a Node in scope' do
    include_examples 'scope method tests', Underware::Namespaces::Node
    include_examples '#group errors'

    describe '#node' do
      it 'returns a Node' do
        expect(alces.node.class).to eq(Underware::Namespaces::Node.to_s)
      end
    end
  end

  context 'with a Group in scope' do
    include_examples 'scope method tests', Underware::Namespaces::Group
    include_examples '#node errors'

    describe '#group' do
      it 'returns a Group' do
        expect(alces.group.class).to eq(Underware::Namespaces::Group.to_s)
      end
    end
  end
end

RSpec.describe Underware::Namespaces::Alces do
  # These tests were formerly tests of the `Underware::Templater` class, but
  # are no longer applicable to that now rendering has been moved to the
  # namespaces. They have been moved here (and slightly tweaked to still work),
  # since I think they may still have some value as they test additional things
  # to the above like the availability of config values when templating.
  # Keeping these in a separate `describe` for now to avoid
  # conflicts/interactions with the above, and since we may just end up
  # deleting/refactoring these away at some point.
  describe 'old Templater tests' do
    include Underware::AlcesUtils

    before :each do
      FileSystem.setup do |fs|
        fs.write template_path, template.strip_heredoc
      end
    end

    # XXX Could adjust tests using this to only use template with parts they
    # need, to make them simpler and less dependent on changes to this or each
    # other.
    let(:template) do
      <<-EOF
        This is a test template
        some_passed_value: <%= domain.config.some_passed_value %>
        some_config_value: <%= domain.config.some_config_value %>
        erb_config_value: <%= domain.config.erb_config_value %>
        very_recursive_erb_config_value: <%= domain.config.very_recursive_erb_config_value %>
        nested.config_value: <%= domain.config.nested ? domain.config.nested.config_value : nil %>
      EOF
    end

    let(:template_path) { '/template' }

    def expect_renders(template_parameters, expected)
      # Strip trailing spaces from rendered output to make comparisons less
      # brittle.
      rendered = alces.render_file(
        template_path, template_parameters
      ).gsub(/\s+\n/, "\n")

      expect(rendered).to eq(expected.strip_heredoc)
    end

    describe '#render_file' do
      context 'without config specifying parameters' do
        it 'renders template with no extra parameters' do
          expected = <<-EOF
            This is a test template
            some_passed_value:
            some_config_value:
            erb_config_value:
            very_recursive_erb_config_value:
            nested.config_value:
          EOF

          expect_renders({}, expected)
        end
      end

      context 'with config specifying parameters' do
        before :each do
          FileSystem.setup do |fs|
            fs.with_fixtures('repo/config', at: Underware::FilePath.config_dir)
          end
        end

        it 'renders template with config parameters' do
          expected = <<-EOF
            This is a test template
            some_passed_value:
            some_config_value: config_value
            erb_config_value: config_value
            very_recursive_erb_config_value: config_value
            nested.config_value: nested_config_value
          EOF

          expect_renders({}, expected)
        end

        context 'when template uses property of unset parameter' do
          let(:template) do
            'unset.parameter: <%= unset.parameter %>'
          end

          it 'raises' do
            expect do
              described_class.render_file(template_path, {})
            end.to raise_error NameError
          end
        end
      end
    end
  end
end
