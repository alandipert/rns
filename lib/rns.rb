module Rns
  class << self
    def f(m)
      lambda{|*args| send(m, *args)}
    end

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
        v.map{|x| process_entry([k,x])}
      elsif (v.is_a? Hash)
        v.map do |x,y|
          process_entry([constant_for([k, x].map(&:to_s)), y])
        end
      else
        [k,v]
      end
    end

    def process_spec(use_spec)
      use_spec.map(&method(:process_spec_entry)).flatten.each_slice(2).to_a
    end

    def add_methods(to, use_spec)
      process_spec(use_spec).each do |from, method|
        to.send(:define_method, method) do |*args|
          from.method(method).call(*args)
        end
      end
    end

    def using(use_spec, &blk)
      klass = Class.new
      add_methods(klass, use_spec)
      klass.new.instance_eval(&blk)
    end
  end
end
