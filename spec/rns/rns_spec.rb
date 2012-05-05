require File.join(File.dirname(__FILE__), *%w[.. spec_helper.rb])
require 'rns'

module Math
  def self.identity(x); x end

  module Arithmetic
    class << self
      def dec(n) n - one end
      def inc(n) n + one end
      private
      def one() 1 end
    end
  end

  module Statistics
    def self.avg(arr); arr.reduce(:+).to_f / arr.count end
  end
end

class Thing
  include Rns

  extend_specified Math::Arithmetic => [:inc]
  include_specified Math::Statistics => [:avg]

  def inced_one
    self.class.inc 1
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
  end
end
