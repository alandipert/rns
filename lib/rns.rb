require 'rns/version'

module Kernel
  # Returns an immutable namespace of functions
  #
  # * `imports` can be any number of other namespaces from which to import functions or hashes
  #   specifying which functions to import.
  # * The block contains the functions to be `def`ed for the namespace. Since namespaces are
  #   immutable, instance variable and class variable cannot be set in functions.  In other
  #   words, `@var = :something` will raise an error.
  #
  # Example:
  #
  #     StringManipulation = Rns(SomeOtherNs, AnotherNs => [:alternate_case]) do
  #       def crazify(str)
  #         "#{alternate_case str}!"
  #       end
  #     end
  #
  #     StringManipulation.crazify("whoa") #=> "WhOa!"
  #
  def Rns(*imports, &block)
    klass = Class.new(Rns::Namespace, &block)
    klass.import(imports)
    klass.freeze.send(:new).freeze
  end
end

module Rns
  # Error raised while importing methods
  class ImportError < StandardError
  end

  # An internal class used to support Kernel#Rns in returning namespaces
  class Namespace
    class << self
      # Use Kernel#Rns instead
      private :new

      # Imports methods from objects into this namespace class as private instance methods.
      def import(imports)
        ns_methods = instance_methods()
        @_import_hash = array_to_key_value_tuples(imports).reduce({}) do |h, (obj, methods)|
          if !obj.frozen?
            raise ImportError, "#{obj} cannot be imported into Namespace because it is not frozen"
          elsif !obj.class.frozen?
            raise ImportError, "#{obj} cannot be imported into Namespace because its class is not frozen"
          end

          (methods || obj.public_methods(false)).each do |method|
            if ns_methods.include? method
              raise ImportError, "cannot override #{method} with an import"
            end
            h[method.to_sym] = obj.method(method)
          end

          h
        end

        file, line = import_call_site(caller)
        @_import_hash.each do |method, _|
          # eval is needed because:
          #   * Module#define_method can't delegate to methods that accept blocks
          #   * method_missing can, but then imported methods are available publicly
          module_eval(delegate_to_hash_source(method, :@_import_hash), file, line - 1)
          private method
        end
      end

    private
      # array_to_key_value_tuples([:a, {:b => 1, :c => 2}, :d])
      # #=> [[:a, nil], [:b, 1], [:c, 2], [:d, nil]]
      def array_to_key_value_tuples(array)
        array.reduce([]) do |tuples, elem|
          if elem.is_a? Hash
            tuples + Array(elem)
          else
            tuples << [elem, nil]
          end
        end
      end

      # Delegates all calls to a callable stored in an ivar of the class'es
      def delegate_to_hash_source(method_name, hash_name)
        <<-EOS
          def #{method_name}(*args, &block)
            self.class.instance_variable_get(:#{hash_name}).fetch(:#{method_name}).call(*args, &block)
          end
        EOS
      end

      # Given a backtrace, return the file/line where the user imported a method. Skip frames in
      # Kernel#Rns since the user's import code will be in the frame afterwards.
      def import_call_site(backtrace)
        frame = backtrace.detect {|f| f !~ /in `Rns'$/ }
        file, line = frame.split(':', 2)
        [file, line.to_i]
      end
    end
  end
end