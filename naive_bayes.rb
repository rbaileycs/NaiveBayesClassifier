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
    attr_accessor :training_model, :classes, :category, :text,
                  :negative_population, :neutral_population, :positive_population

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
      tokenize(data) { |data| @training_model[data][category.to_sym] += 1 }
    end

    # This function handles the initial parsing of the
    # training data.
    def training_parse(file)
      CSV.foreach(file, :encoding => 'iso-8859-1') { |row|
        @category = row[0]
        @text = row[5]
        train @category, @text
      }
    end

    def classy_parse(file)
      CSV.foreach(file, :encoding => 'iso-8859-1') { |row|
        @text = row[5]
        data = @text.split(/\W+/)
        classify(data)
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


    puts text










    end

    def find_instances(str)
      x = @training_model.detect {|k,v| k== str}[1]
      @negative_population =x[:'0']
      @neutral_population = x[:'2']
      @positive_population = x[:'4']

    end

  end #end of Naive class

  # Main logic goes here
  classifier = Naive.new
  classifier.initialize_attributes
  classifier.training_parse('testdata.csv')
  classifier.classy_parse('testdata.csv')
  classifier.classify('testdata.csv')
  #classifier.training_model.each_pair { |k, v| puts "Key: #{k}, Value: #{v}" }
  classifier.find_instances('Fuck')


end #end of Bayes module





























