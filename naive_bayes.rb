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

    # This function creates a new Hash object and a new Set object.
    # The hash object is for storing the values of the training data
    # along with their keys (which are just their class types).
    # The set object stores the different classes.
    def initialize_attributes
      @training_model = Hash.new { |h, k| h[k] = Hash.new(0) }
      @classes = Set.new
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

    # This function classifies the test data in context of
    # the training data
    def classify(text)
      # Logic for the classify class goes here
    end

  end  #end of Naive class

  # Main logic goes here
  classifier = Naive.new
  classifier.initialize_attributes
  classifier.training_parse('path/to/training/file')
  classifier.classify('path/to/testing/file')
    #puts classifier.training_model.each_pair { |k, v| puts "Key: #{k}, Value: #{v}" }

end #end of Bayes module

