require 'test_helper'

class ConfigTest < MiniTest::Spec
  subject { Representable::Config.new }
  PunkRock = Class.new
  Definition = Representable::Definition

  describe "wrapping" do
    it "returns false per default" do
      assert_equal nil, subject.wrap_for("Punk", nil)
    end

    it "infers a printable class name if set to true" do
      subject.wrap = true
      assert_equal "punk_rock", subject.wrap_for(PunkRock, nil)
    end

    it "can be set explicitely" do
      subject.wrap = "Descendents"
      assert_equal "Descendents", subject.wrap_for(PunkRock, nil)
    end
  end

  # describe "#[]" do
  #   before { subject.add(:title, {:me => true}) }

  #   it { subject[:unknown].must_equal     nil }
  #   it { subject.get(:title)[:me].must_equal  true }
  #   it { subject["title"][:me].must_equal true }
  # end

  # []=
  # []=(... inherit: true)
  # forwarded to Config#definitions
  describe "#add" do
    before { subject.add(:title, {:me => true}) }

    # must be kind of Definition
    it { subject.size.must_equal 1 }
    it { subject.get(:title).name.must_equal "title" }
    it { subject.get(:title)[:me].must_equal true }

    # this is actually tested in context in inherit_test.
    it "overrides former definition" do
      subject.add(:title, {:peer => Module})
      subject.get(:title)[:me].must_equal nil
      subject.get(:title)[:peer].must_equal Module
    end

    describe "inherit: true" do
      before {
        subject.add(:title, {:me => true})
        subject.add(:title, {:peer => Module, :inherit => true})
      }

      it { subject.get(:title)[:me].must_equal true }
      it { subject.get(:title)[:peer].must_equal Module }
    end
  end


  describe "#each" do
    before { subject.add(:title, {:me => true}) }

    it "what" do
      definitions = []
      subject.each { |dfn| definitions << dfn }
      definitions.size.must_equal 1
      definitions[0][:me].must_equal true
    end
  end

  describe "#options" do
    it { subject.options.must_equal({}) }
    it do
      subject.options[:namespacing] = true
      subject.options[:namespacing].must_equal true
    end
  end


  describe "#add" do
    subject { Representable::Config.new.add(:title, {:me => true}) }

    it { subject.must_be_kind_of Representable::Definition }
    it { subject[:me].must_equal true }
  end

  describe "#get" do
    subject       { Representable::Config.new }

    it do
      title  = subject.add(:title, {})
      length = subject.add(:length, {})

      subject.get(:title).must_equal title
      subject.get(:length).must_equal length
    end
  end


  describe "xxx- #inherit!" do
    let (:title)  { Definition.new(:title) }
    let (:length) { Definition.new(:length) }
    let (:stars)  { Definition.new(:stars) }

    it do
      parent = Representable::Config.new
      parent.add(:title, {:alias => "Callname"})
      parent._features[Object] = true
      # DISCUSS: build InheritableHash automatically in options? is there a gem for that?
      parent.options[:additional_features] = Representable::InheritableHash[Object => true]

      subject.inherit!(parent)

      # add to inherited config:
      subject.add(:stars, {})
      subject._features[Module] = true
      subject.options[:additional_features][Module] = true

      subject._features.must_equal({Object => true, Module => true})

      parent.options[:additional_features].must_equal({Object => true})
      subject.options[:additional_features].must_equal({Object => true, Module => true})

      # test Definition interface:

      # definitions.size.must_equal([subject.get(:title), subject.get(:stars)])
      subject.get(:title).object_id.wont_equal parent.get(:title).object_id
      # subject.get(:stars).object_id.must_equal stars.object_id
    end

    it "xx" do
      parent = Representable::Config.new
      parent.options[:links] = Representable::InheritableArray.new
      parent.options[:links] << "//1"

      subject.options[:links] = Representable::InheritableArray.new
      subject.options[:links] << "//2"

      subject.inherit!(parent)
      subject.options[:links].must_equal ["//2", "//1"]
    end
  end

  describe "#features" do
    it do
      subject[:features][Object] = true
      subject[:features][Module] = true

      subject.features.must_equal [Object, Module]
    end
  end
end