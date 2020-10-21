# frozen_string_literal: true

require 'objspace'
class Class
  def direct_subclasses # this method gets the direct subclasses. its inherited by all classes as it is in class Class
    ret = ObjectSpace.each_object(::Class).select do |klass|
      klass < self if klass.superclass == self
    end # gives only direct subclasses whos superclass is the class itself
    ret
  end
end
def merge_sort(array) # standard merge sort implementation for ruby
  if array.length <= 1
    array
  else
    mid = (array.length / 2).floor
    left = merge_sort(array[0..mid - 1])
    right = merge_sort(array[mid..array.length])
    merge(left, right)
  end
end

def merge(left, right)
  if left.empty?
    right
  elsif right.empty?
    left
  elsif left[0] < right[0]
    [left[0]] + merge(left[1..left.length], right)
  else
    [right[0]] + merge(left, right[1..right.length])
  end
end

def class_exists?(class_name) # checks if a string classname is really a class, handles a NameError returned by const_get
  klass = Object.const_get(class_name.to_s)
  klass.is_a?(Class)
rescue NameError
  false
end

# below three methods handle 2 lists, to store the previous and next classes
def change_class(history, current)
  history.shift if history.length == 3
  history.push(current)
  puts 'History' + history.to_s
end

def backward(history, future, current)
  future.shift if future.length == 3
  future.push(current)
  puts 'Future' + future.to_s
  if history.empty?
    puts 'No more history to go backwards'
  else
    history.pop
  end
end

def forward(history, future, current)
  history.shift if history.length == 3
  history.push(current)
  puts 'History' + history.to_s
  if future.empty?
    puts 'Nothing in forward list'
  else
    future.pop
  end
end
puts 'Welcome to the ruby class browser by Krunal'
something = ''
classname = 'Class'
history = []
future = []
while something != 'q'
  # puts ObjectSpace.each_object(Class).select { |klass| klass < Class }
  puts 'Name: ' + Object.const_get(classname).name
  puts 'Superclass: ' + Object.const_get(classname).superclass.to_s
  puts 'Subclasses: '
  subclasses = Object.const_get(classname).direct_subclasses
  subclasses = merge_sort(subclasses) # this is the only thing that doesnt work for me :(
  subclasses.each_with_index do |subclass, index|
    puts "#{index + 1}: #{subclass}"
  end
  puts 'Instance Methods: '
  methods = Object.const_get(classname).instance_methods(false)
  methods = merge_sort(methods)
  methods.each_with_index do |method, index|
    puts "#{index + 1}: #{method}"
  end
  puts 'Say something to class browser'
  puts 'Options:'
  puts 's: go to the superclass of this class'
  puts 'u <n>: go to the nth subclass'
  puts 'v: print all instance variables of this class'
  puts 'c <classname>: Change class to the name provided'
  puts 'b: go back one class in the history list'
  puts 'f: go forward one class (undo of b)'
  puts 'q: Quit'
  something = gets.chomp
  case something.partition(' ').first # takes the first word in the input
  when 's' || 'S'
    new_classname = Object.const_get(classname).superclass
    if new_classname.nil?
      puts 'There is no superclass. You have reached the very top!'
    else
      change_class(history, classname)
      classname = new_classname.to_s
    end
  when 'c' || 'C'
    new_classname = something.partition(' ').last # takes the second word in the input (argument)
    if class_exists?(new_classname)
      change_class(history, classname)
      classname = new_classname.to_s
    else
      puts 'This class does not exist in Ruby'
    end
  when 'v' || 'V'
    puts 'Instance Variables: '
    temp = Object.const_get(classname).new
    puts temp.instance_variables # instance variables only show using this method if the class initializes them. most classes do not do that
  when 'b' || 'B'
    prev_class = backward(history, future, classname)
    puts prev_class
    if prev_class.nil?
    else
      classname = prev_class.to_s
    end
  when 'f' || 'F'
    future_class = forward(history, future, classname)
    puts future_class
    if future_class.nil?
    else
      classname = future_class.to_s
    end
  when 'u' || 'U'
    index = something.partition(' ').last
    subclass_name = subclasses[index.to_i - 1]
    if subclass_name.nil?
      puts 'Array out of bounds. Enter something in range of Subclass list'
    elsif class_exists?(subclass_name)
      change_class(history, classname)
      classname = subclass_name.to_s
    else
      puts 'This class does not exist in Ruby'
    end
  when 'q' || 'Q'
    puts 'Bye'
  else
    puts 'I dont understand that command'
  end
end
