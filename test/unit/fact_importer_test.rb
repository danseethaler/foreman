require 'test_helper'

class FactImporterTest < ActiveSupport::TestCase
  attr_reader :importer
  class CustomFactName < FactName; end
  class CustomImporter < FactImporter
    def fact_name_class
      CustomFactName
    end
  end

  let(:host) { FactoryBot.create(:host) }

  test "default importers" do
    assert_includes FactImporter.importers.keys, 'puppet'
    assert_equal PuppetFactImporter, FactImporter.importer_for(:puppet)
    assert_equal PuppetFactImporter, FactImporter.importer_for('puppet')
    assert_equal PuppetFactImporter, FactImporter.importer_for(:whatever)
    assert_equal PuppetFactImporter, FactImporter.importer_for('whatever')
  end

  test 'importer API defines background processing support' do
    assert FactImporter.respond_to?(:support_background)
  end

  context 'when using a custom importer' do
    setup do
      FactImporter.register_fact_importer :custom_importer, CustomImporter
    end

    test ".register_custom_importer" do
      assert_equal CustomImporter, FactImporter.importer_for(:custom_importer)
    end

    test 'importers without authorized_smart_proxy_features return empty set of features' do
      assert_equal [], FactImporter.importer_for(:custom_importer).authorized_smart_proxy_features
    end

    context 'importing facts' do
      test 'facts of other type do not collide even if they inherit from FactName' do
        assert_nothing_raised do
          custom_import '_timestamp' => '234'
          puppet_import '_timestamp' => '345'
        end
      end

      test 'facts created have the origin attribute set' do
        custom_import('foo' => 'bar')
        imported_fact = FactName.find_by_name('foo').fact_values.first
        assert_equal 'N/A', imported_fact.origin
      end
    end
  end

  describe '#import!' do
    setup do
      FactoryBot.create(:fact_value, :value => '2.6.9',:host => host,
                         :fact_name => FactoryBot.create(:fact_name, :name => 'kernelversion'))
      FactoryBot.create(:fact_value, :value => '10.0.19.33',:host => host,
                         :fact_name => FactoryBot.create(:fact_name, :name => 'ipaddress'))
    end

    test 'importer imports everything as strings' do
      default_import 'kernelversion' => '2.6.9', 'vda_size' => 4242, 'structured' => {'key' => 'value'}
      assert_equal '2.6.9', value('kernelversion')
      assert_equal '4242', value('vda_size')
      assert_equal '{"key"=>"value"}', value('structured')
      refute FactName.find_by_name('structured').compose?
    end

    test 'importer adds new facts' do
      assert_equal '2.6.9', value('kernelversion')
      assert_equal '10.0.19.33', value('ipaddress')
      default_import 'foo' => 'bar', 'kernelversion' => '2.6.9', 'ipaddress' => '10.0.19.33'
      assert_equal 'bar', value('foo')
      assert_equal '2.6.9', value('kernelversion')
      assert_equal 0, importer.counters[:deleted]
      assert_equal 0, importer.counters[:updated]
      assert_equal 1, importer.counters[:added]
    end

    test 'importer removes deleted facts' do
      default_import 'ipaddress' => '10.0.19.33'
      assert_nil value('kernelversion')

      assert_equal 1, importer.counters[:deleted]
      assert_equal 0, importer.counters[:updated]
      assert_equal 0, importer.counters[:added]
    end

    test 'importer updates fact values' do
      assert_equal '2.6.9', value('kernelversion')
      assert_equal '10.0.19.33', value('ipaddress')
      default_import 'kernelversion' => '3.8.11', 'ipaddress' => '10.0.19.33'
      assert_equal '3.8.11', value('kernelversion')

      assert_equal 0, importer.counters[:deleted]
      assert_equal 1, importer.counters[:updated]
      assert_equal 0, importer.counters[:added]
    end

    test "importer shouldn't set nil values" do
      assert_equal '2.6.9', value('kernelversion')
      assert_equal '10.0.19.33', value('ipaddress')
      default_import('kernelversion' => nil, 'ipaddress' => '10.0.19.33')
      assert_nil value('kernelversion')
      assert_equal '10.0.19.33', value('ipaddress')

      assert_equal 1, importer.counters[:deleted]
      assert_equal 0, importer.counters[:updated]
      assert_equal 0, importer.counters[:added]
    end

    test "importer adds, removes and deletes facts" do
      assert_equal '2.6.9', value('kernelversion')
      assert_equal '10.0.19.33', value('ipaddress')
      default_import('kernelversion' => nil, 'ipaddress' => '10.0.19.5', 'uptime' => '1 picosecond')
      assert_nil value('kernelversion')
      assert_equal '10.0.19.5', value('ipaddress')
      assert_equal '1 picosecond', value('uptime')

      assert_equal 1, importer.counters[:deleted]
      assert_equal 1, importer.counters[:updated]
      assert_equal 1, importer.counters[:added]
    end

    test "importer retains 'other' facts" do
      assert_equal '2.6.9', value('kernelversion')
      FactoryBot.create(:fact_value, :value => 'othervalue',:host => host,
                         :fact_name => FactoryBot.create(:fact_name_other, :name => 'otherfact'))
      default_import('ipaddress' => '10.0.19.5', 'uptime' => '1 picosecond')
      assert_equal 'othervalue', value('otherfact')
      assert_nil value('kernelversion')
      assert_equal '10.0.19.5', value('ipaddress')
      assert_equal '1 picosecond', value('uptime')
      assert_equal 1, importer.counters[:deleted]
      assert_equal 1, importer.counters[:updated]
      assert_equal 1, importer.counters[:added]
    end
  end

  def default_import(facts)
    @importer = FactImporter.new(host, facts)
    @importer.stubs(:fact_name_class).returns(FactName)
    @importer.import!
  end

  def custom_import(facts)
    @importer = CustomImporter.new(host, facts)
    @importer.import!
  end

  def puppet_import(facts)
    @importer = PuppetFactImporter.new(host, facts)
    @importer.import!
  end

  def value(fact)
    FactValue.joins(:fact_name).where(:host_id => host.id, :fact_names => { :name => fact }).first.try(:value)
  end
end
