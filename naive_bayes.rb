require 'csv'
require 'set'


#puts "POLARITY : #{polarity} TEXT : #{text}"

# CSV.foreach('testdata.csv') do |row|
#   @polarity = row[0]
#   @text = row[5]
#
# end


# A module is a namespace and prevents name clashes
module Bayes

  class Base #this is where the parser should go

    attr_accessor :polarity, :text, :container_array

    def initialize_attributes

    end

    #end terminates the class

    def tokenize(data)
      data = data.split(/\W+/)
      if data.first == ""
        data = data.drop(1)
      end
      for index in 0...data.size
        yield data[index]
      end
    end
  end

# Naive extends Base
  class Naive < Bayes::Base

    # Create attribute accessors, similar to get and set in Java
    attr_accessor :training_model, :classes

    def initialize_attributes
      # creates a new Hash object, where the hash value and key
      # value are used in the invocation of a block
      @training_model = Hash.new { |h, k| h[k] = Hash.new(0) }
      @classes = Set.new
      super # super call to class Bayes initialize_attributes
    end

    def train(category, data)
      @classes << category.to_sym
      tokenize(data) do |data|
        @training_model[category.to_sym][data] += 1
      end

    end

    classifier = Naive.new
    classifier.initialize_attributes

    CSV.foreach('testdata.csv') do |row|
      category = row[0]
      text = row[5] # discard the label
      classifier.train category, text

    end
    puts classifier.training_model.each_pair{|k, v| puts "Key: #{k}, Value: #{v}"}
  end
end

