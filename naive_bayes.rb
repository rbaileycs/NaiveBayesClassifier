require 'csv'
require 'set'

# A module is a namespace and prevents name clashes
module Bayes

  #It's just division - Michael Plaisance

  class Trainer

    # Create attribute accessors, similar to get and set in Java
    attr_accessor :training_model, :classes, :category, :text, :total_words_counter,
                  :negative_population, :neutral_population, :positive_population,
                  :negative_polarity, :positive_polarity, :neutral_polarity

    # This function creates a new Hash object and a new Set object.
    # The hash object is for storing the values of the training data
    # along with their keys (which are just their class types).
    # The set object stores the different classes.
    def initialize_attributes
      @training_model = Hash.new { |h, k| h[k] = Hash.new(0) }
      @classes = Set.new
      @total_words_counter = 0
      @negative_population= 0
      @neutral_population = 0
      @positive_population = 0
    end

    # This function handles the initial parsing of the
    # training data.
    def training_parse(file)
      CSV.foreach(file, :encoding => 'iso-8859-1') { |row|
        @category = row[0]
        @text = row[5]
        train @category, @text
      }
      population
    end

    # This function trains the program by creating classes and
    # a hashmap that contains the keys(classes) and
    # values (associated strings).
    def train(category, data)
      @classes << category.to_s
      tokenize(data) { |data| @training_model[data][category.to_sym] += 1 }
    end

    # Tokenize the initial parsing into separate words
    def tokenize(data)
      return if data.nil?
      data = data.split(/\W+/)
      if data.first == ''
        data = data.drop(1)
      end
      (0...data.size).each { |index|
        @total_words_counter += 1
        yield data[index] }
    end

    def population
      @training_model.each_pair { |k, v| k
      @negative_population += v[:'0']
      @positive_population += v[:'4']
      @neutral_population += v[:'2']
      }
    end
  end #end of Trainer class

  class Classifier < Trainer

    attr_accessor :total_positives, :total_negatives, :total_neutrals, :tots

    # This function initializes counters
    def initialize_attributes
      @total_positives = 0
      @total_negatives = 0
      @total_neutrals = 0
      @tots= 0
      super
    end

    def classy_parse(file)
      CSV.foreach(file, :encoding => 'iso-8859-1') { |row|
        @text = row[5]
        classify(@text)
      }
    end

    # This function classifies the test data in context of
    # the training data
    def classify(text)
      positive_value, neutral_value, negative_value = 1
      word = text.split(/\W+/)
      word = word.drop(1) if word.first == ''
      word.each_with_index { |_, i|
        find_instances(word[i])
        positive_value *= ((((positive_polarity.to_f/positive_population.to_f).to_f) *((positive_polarity).to_f))/word_pop)
        negative_value *= ((((negative_polarity.to_f/negative_population.to_f).to_f)*((negative_polarity).to_f))/word_pop)
        neutral_value *= ((((neutral_polarity.to_f/neutral_population.to_f).to_f)*((neutral_polarity).to_f))/word_pop)
      }
      if [positive_value, neutral_value, negative_value].rindex([positive_value, neutral_value, negative_value].max) == 0
        @total_positives +=1
        @tots += 1
        puts "POS: #{total_positives}"
      end
      if [positive_value, neutral_value, negative_value].rindex([positive_value, neutral_value, negative_value].max) == 1
        @total_neutrals += 1
        @tots += 1
        puts "NEU: #{total_neutrals}"
      end
      if [positive_value, neutral_value, negative_value].rindex([positive_value, neutral_value, negative_value].max) == 2
        @total_negatives +=1
        @tots += 1
        puts "NEG: #{total_negatives}"
      end
    rescue => error
      puts error.backtrace
      # puts "#{@total_positives} + #{negOut} + #{@total_neutrals} + #{tots}"
    end

    def find_instances(str)
      (@training_model.detect { |k, _| k== str }[1][:'0'] != 0) ?
          @negative_polarity = @training_model.detect { |k, _| k== str }[1][:'0'] : @negative_polarity = 0.1
      (@training_model.detect { |k, _| k== str }[1][:'2'] != 0) ?
          @neutral_polarity = @training_model.detect { |k, _| k== str }[1][:'2'] : @neutral_polarity = 0.1
      (@training_model.detect { |k, _| k== str }[1][:'4'] != 0) ?
          @positive_polarity = @training_model.detect { |k, _| k== str }[1][:'4'] : @positive_polarity = 0.1
    end

    def word_pop
      (positive_polarity.to_f + negative_polarity.to_f + neutral_polarity.to_f).to_f/total_words_counter
    end
  end #end of Classifier class

  # Main logic goes here
  CLASSIFIER = Classifier.new
  CLASSIFIER.initialize_attributes
  CLASSIFIER.training_parse('training.csv')
  CLASSIFIER.classy_parse('testdata.csv')
  #puts classifier.training_model #.each_pair { |k, v| puts "Key: #{k}, Value: #{v}" }

end #end of Bayes module

