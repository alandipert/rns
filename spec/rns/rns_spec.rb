require File.join(File.dirname(__FILE__), *%w[.. spec_helper.rb])
require 'rns'

module Math
  def self.identity(x); x end

  module Arithmetic
    class << self
      def dec(n) n - one end
      def inc(n) n + one end
      def add(x,y) x + y end
      private
      def one() 1 end
    end
  end

  module Statistics
    def self.avg(arr); arr.reduce(:+).to_f / arr.count end
    module Foo
      def self.blah; :quux end
    end
  end
end

module BlockTakers
  def self.takes_block(&blk); yield; end
end

module Util
  class << self
    def assoc!(h, k, v)
      h.tap{|o| o[k] = v}
    end

    def merge_with(f, *hshs)
      merge_entry = lambda do |h, (k,v)|
        if (h.has_key?(k))
          assoc!(h, k, f[h[k], v])
        else
          assoc!(h, k, v)
        end
      end
      merge2 = lambda do |h1,h2|
        h2.to_a.reduce(h1, &merge_entry)
      end
      ([{}] + hshs).reduce(&merge2)
    end
  end
end

class Thing
  extend Rns.use(Math::Arithmetic => [:inc])
  include Rns.use(Math::Statistics => [:avg])

  def self.inced_one
    inc 1
  end

  def average
    avg [11, 42, 7]
  end
end

describe Rns do
  context 'adding methods to classes' do
    it "works" do
      Thing.new.average.should == 20
    end

    it "works with private module methods" do
      Thing.inced_one.should == 2
    end

    it "should add methods privately" do
      lambda { Thing.new.avg [11, 42, 7] }.should raise_error(NoMethodError)
    end
  end

  context 'adding methods to blocks' do

    it 'computes' do
      Rns::using(Util => [:merge_with],
                 Math::Arithmetic => [:inc, :add]) do

        sum = lambda{|*xs| xs.reduce(:+)}

        merge_with(sum, *(1..10).map{|n| {x: n}})[:x].should == 55
        merge_with(sum,
                   {x: 10, y: 20},
                   {x: 3, z: 30}).should == {x: 13, y: 20, z: 30}

        merge_with(lambda{|l,r| l.send(:+, r)},
                   {:x => [:something]},
                   {:x => [:else]}).should == {:x => [:something, :else]}
      end
    end

    it "works with individual modules" do
      Rns::using(Math::Arithmetic => [:inc],
                 Math::Statistics => [:avg]) do
        avg((1..10).to_a.map(&method(:inc))).should == 6.5
      end
    end

    it "works with nested modules" do
      Rns::using(Math => {:Arithmetic => [:inc],
                          :Statistics => [:avg]}) do
        avg((1..10).to_a.map(&method(:inc))).should == 6.5
      end
    end

    it "works with mix of module declaration styles" do
      Rns::using(Math::Arithmetic => [:inc],
                 Math => [:identity,
                          {:Statistics => [:avg]}]) do
        identity(1).should == 1
        inc(10).should == 11
        avg((1..10).to_a.map(&method(:inc))).should == 6.5
      end
    end

    it "does not modify Object" do
      Rns::using(Math::Arithmetic => [:inc]) do
        # do nothing
      end
      lambda { Object.new.inc 1 }.should raise_error(NoMethodError)
    end

    it "does not modify Class" do
      Rns::using(Math::Arithmetic => [:inc]) do
        # do nothing
      end
      lambda { Class.new.inc 1 }.should raise_error(NoMethodError)
    end

    it "imports a method that takes a block" do
      Rns::using(BlockTakers => [:takes_block]) do
        takes_block do
          :returned_from_block
        end.should == :returned_from_block
      end
    end

    it 'processes specs correctly' do
      Rns::using(Rns => [:process_spec]) do
        process_spec({Math => [:inc, :dec]}).
          should == [[Math, :inc], [Math, :dec]]
      end

      Rns::using(Rns => [:process_spec]) do
        spec = {Math::Arithmetic => [:inc],
                Math => [:identity,
                         {:Statistics => [:avg,
                                          {:Foo => [:blah, :quux]}]}]}
        process_spec(spec).should == [[Math::Arithmetic, :inc],
                                      [Math, :identity],
                                      [Math::Statistics, :avg],
                                      [Math::Statistics::Foo, :blah],
                                      [Math::Statistics::Foo, :quux]]
      end
    end
  end
end
