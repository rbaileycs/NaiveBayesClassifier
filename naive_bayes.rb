require 'csv'
require 'set'

# A module is a namespace and prevents name clashes
module Bayes

  #It's just division - Michael Plaisance

  class Trainer

    # Create attribute accessors, similar to get and set in Java
    attr_accessor :training_model, :classes, :category, :text,
                  :negative_population, :neutral_population, :positive_population,
                  :negative_polarity, :positive_polarity, :neutral_polarity,
                  :total_words_counter

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
      @classes << category.to_sym
      tokenize(data) { |data| @training_model[data][category.to_sym] += 1 }
    end

    # Tokenize the initial parsing into separate words
    def tokenize(data)
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

  end #end of Train class


  class Classifier < Trainer

    attr_accessor :total_positives, :total_negatives, :total_neutrals, :tots

    # This function
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
      word.each_with_index { |v, i|
        find_instances(word[i])
        positive_value *= ((((positive_polarity.to_f/positive_population.to_f).to_f) *((positive_polarity).to_f))/word_pop)
        negative_value *= ((((negative_polarity.to_f/negative_population.to_f).to_f)*((negative_polarity).to_f))/word_pop)
        neutral_value *= ((((neutral_polarity.to_f/neutral_population.to_f).to_f)*((neutral_polarity).to_f))/word_pop)
      }

      if [positive_value, neutral_value, negative_value].rindex([positive_value, neutral_value, negative_value].max()) == 0
        puts "That shit is positive yo"
        @total_positives +=1
        @tots += 1
      end
      if [positive_value, neutral_value, negative_value].rindex([positive_value, neutral_value, negative_value].max()) == 1
        puts "Shit, Bro I cant decide"
        @total_neutrals += 1
        @tots += 1
      end
      if [positive_value, neutral_value, negative_value].rindex([positive_value, neutral_value, negative_value].max()) == 2
        puts "Thats negative as Fuck man...."
        @total_negatives +=1
        @tots += 1
      end
    rescue
      1
      # puts "#{@total_positives} + #{negOut} + #{@total_neutrals} + #{tots}"
    end

    def find_instances(str)
      if @training_model.detect { |k, v| k== str }[1][:'0'] != 0
        @negative_polarity = @training_model.detect { |k, v| k== str }[1][:'0']
      else
        @negative_polarity = 0.1
      end
      if @training_model.detect { |k, v| k== str }[1][:'2'] != 0
        @neutral_polarity = @training_model.detect { |k, v| k== str }[1][:'2']
      else
        @neutral_polarity = 0.1
      end
      if @training_model.detect { |k, v| k== str }[1][:'4'] != 0
        @positive_polarity = @training_model.detect { |k, v| k== str }[1][:'4']
      else
        @positive_polarity = 0.1
      end
    end

    def word_pop
      (positive_polarity + negative_polarity + neutral_polarity).to_f/total_words_counter
    end

  end

  # Main logic goes here
  CLASSIFIER = Classifier.new
  CLASSIFIER.initialize_attributes
  CLASSIFIER.training_parse('/Users/dev/Documents/School/CS354/Ruby/training.csv')
  CLASSIFIER.classy_parse('/Users/dev/Documents/School/CS354/Ruby/testdata.csv')
  #puts classifier.training_model #.each_pair { |k, v| puts "Key: #{k}, Value: #{v}" }

end #end of Bayes module

