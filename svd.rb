class Array
  def dot_product(other)
    self.zip(other).inject(0){ |sum, curr_pair| sum + curr_pair[0] * curr_pair[1] }
  end
end

class Svd
  # `rows` is an array of hashes, where keys are column indices and values are the value of the matrix in that (row, column) pair. For example, `rows[5][18] = 3` means that the matrix contains a 3 in row 5, column 18.
  # Note: the matrix can have missing values (missing values are, after all, part of the motivation for gradient SVD).
  def initialize(rows, row_names, col_names)
    @rows = rows
    @row_names = row_names
    @col_names = col_names
    
    @row_vectors = Array.new(@row_names.size) { [] }
    @col_vectors = Array.new(@col_names.size) { [] }
    
    @num_entries = @rows.inject(0){ |sum, row| sum + row.size }
    @log = []
  end
  
  # Given an array of documents, turn each document into a binary word vector.
  # Place these vectors into a matrix, and perform an SVD on the matrix.
  # Note: this method does not remove stop words or perform any stemming.
  # Note: a more sophisticated approach would be to replace binary word indicators with tf-idf scores.
  def self.lsi(documents, partial = false)    
    words = documents.map{ |document| document.strip.split }.flatten.uniq
    word_cols = {}
    words.each_with_index{ |word, i| word_cols[word] = i }
    
    rows = []
    documents.each_with_index do |document, i|
      rows[i] = Hash.new(0)
      
      if !partial
        words.each do |word|
          word_col = word_cols[word]
          rows[i][word_col] ||= 0
        end
      end
            
      document.split.each do |word|
        word_col = word_cols[word]
        rows[i][word_col] += 1
      end
    end
    
    Svd.new(rows, documents, words)
  end
  
  # Compute the SVD. Use the `print` method to print out the row and column vectors.
  # Note: singular values have been collapsed into the row and column vectors. If you want to compute singular values, normalize the rows and columns to have norm 1.
  def compute(options = {})    
    options = {:num_features => 2,
              :min_epochs => 10,
              :max_epochs => 50000,
              :initial_learning_rate => 0.005,
              :annealing_rate => 1000,
              :regularization => 0,
              :min_improvement => 0.00000,
              :feature_init => 0.01}.merge(options)
                
    0.upto(options[:num_features] - 1) do |feature|
      @log << "# Feature #{feature}"
      
      # Initialize the new feature.
      (@row_vectors + @col_vectors).each{ |vector| vector << Svd.gaussian_rand * options[:feature_init] }
      
      # In each epoch...
      rmse_prev = 1.0 / 0
      0.upto(options[:max_epochs] - 1) do |epoch|
        learning_rate = options[:initial_learning_rate] / (1.0 + epoch.to_f / options[:annealing_rate])
        
        # ...we go through each example...
        ss_errors = 0
        @rows.each_with_index do |row, i|
          row.each_pair do |col, value|
            # ...compute the error in our prediction...
            prediction = @row_vectors[i].dot_product(@col_vectors[col])
            error = value - prediction
            ss_errors += error * error
            
            # ...and update the weight vectors in the correct direction.
            row_feature = @row_vectors[i][feature]
            col_feature = @col_vectors[col][feature]
            @row_vectors[i][feature] += learning_rate * (error * col_feature - options[:regularization] * row_feature)
            @col_vectors[col][feature] += learning_rate * (error * row_feature - options[:regularization] * col_feature)
          end
        end
        
        rmse = Math.sqrt(ss_errors / @num_entries)
        @log << "Epoch #{epoch}: rmse = #{rmse}"
        
        # See if we want to stop early (if we're not making enough improvement).
        if (epoch >= options[:min_epochs] and (rmse - rmse_prev).abs / (rmse.abs + rmse_prev.abs) < options[:min_improvement])
          @log << "Converged in epoch #{epoch}."          
          break
        end
        
        rmse_prev = rmse
      end    
    end
  end
  
  def print(rows_filename, cols_filename, log_filename)
    File.open(rows_filename, "w") do |f|
      @col_names.zip(@col_vectors).each do |name, vector|
        f.puts [name, vector.join("\t")].join("\t")
      end
    end
    
    File.open(cols_filename, "w") do |f|
      @row_names.zip(@row_vectors).each do |name, vector|
        f.puts [name, vector.join("\t")].join("\t")
      end
    end

    File.open(log_filename, "w") do |f|
      f.puts @log.join("\n")      
    end
  end
  
  def self.gaussian_rand 
     u1 = u2 = w = g1 = g2 = 0  # declare
     begin
       u1 = 2 * rand - 1
       u2 = 2 * rand - 1
       w = u1 * u1 + u2 * u2
     end while w >= 1

     w = Math::sqrt( ( -2 * Math::log(w)) / w )
     g2 = u1 * w
     g1 = u2 * w
     g1
  end
  
  def normalize

  end
end