module Rns
  class << self
    def f(m)
      lambda{|*args| send(m, *args)}
    end

    def assoc!(h, k, v)
      h.tap{|o| o[k] = v}
    end

    def merge_with(f, *hshs)
      merge_values = if (f.is_a? Symbol)
                       if (methods.include? f)
                         #Use Rns-imported method
                         self.f(f)
                       else
                         #Use the left merge object's method
                         lambda{|l,r| l.send(f, r)}
                       end
                     else
                       f
                     end
      merge_entry = lambda do |h, (k,v)|
        if (h.has_key?(k))
          assoc!(h, k, merge_values[h[k], v])
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
      (m, *more) = module_names
      more.reduce(Kernel.const_get(m)){|m, s| m.const_get(s)}
    end

    def module_with(use_spec)
      Module.new.tap {|m| add_methods(m, use_spec) }
    end

    def add_methods(to, use_spec)
      use_spec.to_a.each do |from, sub_spec|
        if (sub_spec.is_a? Hash)
          qualified_specs = sub_spec.map do |k,v|
            {constant_for([from, k].map(&:to_s)) => v}
          end
          add_methods(to, merge_with(:+, *qualified_specs))
        else
          sub_spec.each do |name|
            if (name.is_a? Hash)
              add_methods(to, {from => name})
            else
              to.send(:define_method, name) do |*args|
                from.method(name).call(*args)
              end
            end
          end
        end
      end
    end

    @@_gensym = 1000

    def gensym(prefix = 'G')
      (prefix + (@@_gensym += 1).to_s)
    end

    def using(use_spec, &blk)
      klass = Class.new
      methods.each do |m|
        klass.send(:define_method, m) do |*args|
          lambda{|*args| send(m, *args)}
        end
      end
      add_methods(klass, use_spec)
      klass.new.instance_eval(&blk)
    end
  end
end
