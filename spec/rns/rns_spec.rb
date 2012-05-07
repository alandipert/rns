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
  end
end


class Thing
  extend Rns.module_with(Math::Arithmetic => [:inc])
  include Rns.module_with(Math::Statistics => [:avg])

  def inced_one
    self.class.inc 1
  end

  def average
    avg [11, 42, 7]
  end
end

describe Rns do
  # describe 'helper functions' do
  #   Rns::using(Rns => [:merge_with],
  #              Math::Arithmetic => [:inc, :add]) do

  #     sum = lambda{|*xs| xs.reduce(:+)}

  #     context 'merge_with' do
  #       it 'merges with a proc' do
  #         merge_with(sum, *(1..10).map{|n| {x: n}})[:x].should == 55
  #         merge_with(sum,
  #                    {x: 10, y: 20},
  #                    {x: 3, z: 30}).should == {x: 13, y: 20, z: 30}
  #       end

  #       it 'merges with a symbol representing an Rns import' do
  #         merge_with(:add, {a: 10}, {a: 20}).should == {a: 30}
  #       end

  #       it "uses the merge object's method if passed a symbol not imported with Rns" do
  #         merge_with(:+,
  #                    {:x => [:something]},
  #                    {:x => [:else]}).should == {:x => [:something, :else]}

  #         merge_with(:+, {x: 10}, {x: 20}).should == {x: 30}
  #       end
  #     end
  #   end
  # end

  context 'adding methods to classes' do
    it "works" do
      Thing.new.average.should == 20
    end

    it "works with private module methods" do
      Thing.new.inced_one.should == 2
    end
  end

  context 'adding methods to blocks' do
    it "works with individual modules" do
      Rns::using(Math::Arithmetic => [:inc],
                 Math::Statistics => [:avg]) do
        avg((1..10).to_a.map(&method(:inc))).should == 6.5
      end
    end

    # it "works with nested modules" do
    #   Rns::using(Math => {:Arithmetic => [:inc],
    #                       :Statistics => [:avg]}) do
    #     avg((1..10).to_a.map(&method(:inc))).should == 6.5
    #   end
    # end

    # it "works with mix of module declaration styles" do
    #   Rns::using(Math::Arithmetic => [:inc],
    #              Math => [:identity,
    #                       {:Statistics => [:avg]}]) do
    #     identity(1).should == 1
    #     inc(10).should == 11
    #     avg((1..10).to_a.map(&method(:inc))).should == 6.5
    #   end
    # end

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

  end
end
