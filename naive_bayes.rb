require 'csv'
require 'set'

# A module is a namespace and prevents name clashes
module Bayes

  # class Base #this is where the parser should go
  #
  #   attr_accessor :polarity, :text, :container_array
  #
  #   def initialize_attributes
  #
  #   end
  #
  #   #end terminates the class
  #
  #
  # end

# Naive extends Base
  class Naive #< Bayes::Base

    # Create attribute accessors, similar to get and set in Java
    attr_accessor :training_model, :classes

    def initialize_attributes
      # creates a new Hash object, where the hash value and key
      # value are used in the invocation of a block
      @training_model = Hash.new { |h, k| h[k] = Hash.new(0) }
      @classes = Set.new
      #super # super call to class Bayes initialize_attributes
    end

    # This function trains the program by creating classes and
    # a hashmap that contains the keys(classes) and
    # values (associated strings).
    def train(category, data)
      @classes << category.to_sym
      tokenize(data) { |data| @training_model[category.to_sym][data] += 1 }
    end

    # This function handles the initial parsing of the
    # training data.
    def training_parse(file)
      CSV.foreach(file, :encoding =>'iso-8859-1') { |row|
        category = row[0]
        text = row[5] # discard the label
        train category, text
      }
    end

    # Tokenize the initial parsing into separate words
    def tokenize(data)
        data = data.split(/\W+/)
        if data.first == ''
          data = data.drop(1)
        end
        (0...data.size).each { |index| yield data[index] }
    end

    def classify(text)

    end
  end

  # Main logic goes here
  classifier = Naive.new
  classifier.initialize_attributes
  classifier.training_parse('path/to/training/file')
  classifier.classify('path/to/testing/file')
    #puts classifier.training_model.each_pair { |k, v| puts "Key: #{k}, Value: #{v}" }

end

