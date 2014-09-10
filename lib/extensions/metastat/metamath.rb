
# Author::    Jason Wijegooneratne  (mailto:code@jwije.com)
# Copyright:: Copyright (c) 2014 Jason Wijegooneratne
# License::   MIT. See LICENSE.md distributed with the source code for more information.

# MetaMath is a base class for developing statistics routines for use with the Metastat LEWT extension
# It provides some convienience methods for developing new routines, as well as acting as a container
# for common mathematical proceedures.

class MetaMath
  
  # Takes an array of numeric values and returns there mean.
  # ar:: Array of values
  def mean(ar)
    raise TypeError "Expected an array" if not ar.kind_of?(Array)
    total = ar.reduce(0) { |sum, x| x + sum }
    Float(total) / Float(ar.length)
  end
  
  # Takes an array of values and returns there mode.
  # ar:: Array of values
  def mode(ar)
    raise TypeError "Expected an array" if not ar.kind_of?(Array)
    freq = ar.inject(Hash.new(0)) { |h,v| h[v] += 1; h }
    return ar.max_by { |v| freq[v] }
  end
  
  # Takes an array of values and returns the median
  # ar:: Array of values
  def median(ar)
    raise TypeError "Expected an array" if not ar.kind_of?(Array)
    mid = ar.length / 2
    return (mid % 1 != 0) ? mean( [ ar[(mid).floor], ar[(mid).round ]] ) : ar[mid]
  end

  # Return the descriptive statistics for an array of values [mean, media, mode]
  # ar:: Array of values
  def descriptive_stats(ar)
    raise TypeError "Expected an array" if not ar.kind_of?(Array)
    return {
      :mean => mean(ar),
      :median => median(ar),
      :mode => mode(ar)
    }
  end

end

# This subclass performs a Pearson Correlation analysis on an x/y dataset.
class PearsonR < MetaMath
  
  def initialize (xs, ys)
    raise Exception "_x & _y datasets must be of equal length" if xs.length != ys.length
    @xs, @ys = xs, ys
  end
  
  # Returns a Pearson Correlation R value
  # xs:: The x series array of values
  # ys:: The y series array of values
  def correlate(xs = @xs, ys = @ys)
    x_mean = mean(@xs)
    y_mean = mean(@ys)

    numerator = (0...@xs.length).reduce(0) do |sum, i|
      sum + ((@xs[i] - x_mean) * (@ys[i] - y_mean))
    end

    denominator = @xs.reduce(0) do |sum, x|
      sum + ((x - x_mean) ** 2)
    end
 
    (numerator / Math.sqrt(denominator))
  end

end


# This class performas a simple regression on an x/y dataset
class SimpleRegression < MetaMath

  def initialize (xs, ys)
    raise Exception "_x & _y datasets must be of equal length" if xs.length != ys.length
    @xs, @ys = xs, ys
  end

  def y_intercept
    mean(@ys) - (slope * mean(@xs))
  end
    
  def slope
    x_mean = mean(@xs)
    y_mean = mean(@ys)
 
    numerator = (0...@xs.length).reduce(0) do |sum, i|
      sum + ((@xs[i] - x_mean) * (@ys[i] - y_mean))
    end
 
    denominator = @xs.reduce(0) do |sum, x|
      sum + ((x - x_mean) ** 2)
    end
 
    (numerator / denominator)
  end


end
