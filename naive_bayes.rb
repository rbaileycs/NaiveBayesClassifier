require 'csv'
require 'set'

# A module is a namespace and prevents name clashes
module Bayes

  #It's just division - Michael Plaisance

  class Trainer

    # Create attribute accessors, similar to get and set in Java
    attr_accessor :training_model, :classes, :category, :text, :total_words_counter,
                  :negative_population, :neutral_population, :positive_population,
                  :negative_polarity, :positive_polarity, :neutral_polarity, :training_negatives, :training_neutrals, :training_positives

    # This function creates a new Hash object and a new Set object.
    # The hash object is for storing the values of the training data
    # along with their keys (which are just their class types).
    # The set object stores the different classes.
    def initialize_attributes
      @training_model = Hash.new { |h, k| h[k] = Hash.new(0) }
      @classes = Set.new
      @total_words_counter = 0
      @negative_population = 0
      @neutral_population = 0
      @positive_population = 0
      @training_negatives = 0
      @training_neutrals = 0
      @training_positives = 0
    end

    # This function handles the initial parsing of the
    # training data.
    def training_parse(file)
      CSV.foreach(file, :encoding => 'iso-8859-1') { |row|
        @category = row[0]
        if @category == '0'
          @training_negatives += 1
        elsif @category == '2'
          @training_neutrals += 1
        else
          @training_positives += 1
        end
        @text = row[5]
        train @category, @text
      }
      population
    end

    # This function trains the program by creating classes and
    # a hashmap that contains the keys(classes) and
    # values (associated strings).
    def train(category, data)
      tokenize(data) { |data| @training_model[data][category.to_sym] += 1 }
    end

    def population
      @training_model.each_pair { |k, v| k
      @negative_population += v[:'0']
      @neutral_population += v[:'2']
      @positive_population += v[:'4']
      }
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

  end #end of Trainer class

  class Classifier < Trainer

    attr_accessor :total_positives,
                  :total_negatives,
                  :total_neutrals

    # This function initializes counters
    def initialize_attributes
      @total_positives = 0
      @total_negatives = 0
      @total_neutrals = 0
      super
    end

    # This function parses for strings to classify
    def classy_parse(file)
      CSV.foreach(file, :encoding => 'iso-8859-1') { |row|
        classify(row[5])
      }
    end

    # This function classifies the test data in context of
    # the training data
    def classify(text)
      positive_value = 1
      neutral_value = 1
      negative_value = 1

      word = text.split(/\W+/)
      word = word.drop(1) if word.first == ''
      word.each_with_index { |_, i|
        find_instances(word[i])
        positive_value *= ((((positive_polarity.to_f/positive_population.to_f).to_f) * ((positive_polarity).to_f))/word_pop)
        negative_value *= ((((negative_polarity.to_f/negative_population.to_f).to_f) * ((negative_polarity).to_f))/word_pop)
        neutral_value *= ((((neutral_polarity.to_f/neutral_population.to_f).to_f) * ((neutral_polarity).to_f))/word_pop)
      }
      total_counter(negative_value, neutral_value, positive_value)

    rescue => error
      puts error.backtrace

    end

    # This functions finds instances of each word within
    # the training model to detect polarity of words
    def find_instances(str)
      if @training_model[str][0] == nil
        @training_model[str][0] = 0
      end

      (@training_model.detect { |k, _| k== str }[1][:'0'] != 0) ?
          @negative_polarity = @training_model.detect { |k, _| k== str }[1][:'0'] :  @negative_polarity = 0.1
      (@training_model.detect { |k, _| k== str }[1][:'2'] != 0) ?
          @neutral_polarity = @training_model.detect { |k, _| k== str }[1][:'2'] :  @neutral_polarity = 0.1
      (@training_model.detect { |k, _| k== str }[1][:'4'] != 0) ?
          @positive_polarity = @training_model.detect { |k, _| k== str }[1][:'4'] : @positive_polarity = 0.1
    end

      # This function counts the number of words based on polarity
      def total_counter(negative_value, neutral_value, positive_value)
        if [positive_value, neutral_value, negative_value].rindex([positive_value, neutral_value, negative_value].max) == 0
          @total_positives +=1
        elsif [positive_value, neutral_value, negative_value].rindex([positive_value, neutral_value, negative_value].max) == 1
          @total_neutrals += 1
        else
          @total_negatives +=1
        end
    end

    def word_pop
      (positive_polarity.to_f + negative_polarity.to_f + neutral_polarity.to_f).to_f/total_words_counter
    end
  end #end of Classifier class

  # Main logic goes here
  CLASSIFIER = Classifier.new
  CLASSIFIER.initialize_attributes
  CLASSIFIER.training_parse('training14.csv')
  CLASSIFIER.classy_parse('testing14.csv')
  x = (CLASSIFIER.total_positives.to_f-CLASSIFIER.training_positives.to_f).abs/CLASSIFIER.training_positives.to_f
  y = (CLASSIFIER.total_negatives.to_f-CLASSIFIER.training_negatives.to_f).abs/CLASSIFIER.training_negatives.to_f
  z = (CLASSIFIER.total_neutrals.to_f-CLASSIFIER.training_neutrals.to_f).abs/CLASSIFIER.training_neutrals.to_f

  puts 'Classification complete with %.2f percent error' % ((x*y*z).round(3)*100)
  puts 'Or %.2f percent accuracy' % (100-(x*y*z).round(3) * 100)

end #end of Bayes module

