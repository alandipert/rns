module Rns
  class << self
    def constant_for(module_names)
      (m, *more) = module_names.map{|n| n.split("::")}.flatten
      more.reduce(Kernel.const_get(m)){|m, s| m.const_get(s)}
    end

    def module_with(use_spec)
      Module.new.tap {|m| add_methods(m, use_spec) }
    end

    def process_spec_entry(entry)
      (k,v) = entry
      if (v.is_a? Array)
        v.map{|x| process_spec_entry([k,x])}
      elsif (v.is_a? Hash)
        v.map do |x,y|
          process_spec_entry([constant_for([k, x].map(&:to_s)), y])
        end
      else
        [k,v]
      end
    end

    def process_spec(use_spec)
      use_spec.map(&method(:process_spec_entry)).
        flatten.
        each_slice(2).
        to_a
    end

    def add_methods(to, use_spec)
      process_spec(use_spec).each do |from, method|
        to.send(:define_method, method) do |*args|
          from.method(method).call(*args)
        end
        to.send(:private, method)
      end
    end

    def using(use_spec, &blk)
      klass = Class.new
      add_methods(klass, use_spec)
      klass.new.instance_eval(&blk)
    end
  end
end
