require "rubygems"
require "ruby-prof"
require "mongoid"

class Person < Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Versioning
  field :birth_date, :type => Date
  has_one :name
  has_many :addresses
  has_many :phones
end

class Name < Mongoid::Document
  include Mongoid::Timestamps
  field :given
  field :family
  field :middle
  belongs_to :person, :inverse_of => :name
end

class Address < Mongoid::Document
  include Mongoid::Timestamps
  field :street
  field :city
  field :state
  field :post_code
  field :type
  belongs_to :person, :inverse_of => :addresses
end

class Phone < Mongoid::Document
  include Mongoid::Timestamps
  field :country_code, :type => Integer
  field :number
  field :type
  belongs_to :person, :inverse_of => :phones
end

connection = Mongo::Connection.new
Mongoid.database = connection.db("mongoid_perf_test")

Mongoid.database.collection("people").drop

RubyProf.start

puts "Starting benchmark..."

1000.times do |n|
  person = Person.new(:birth_date => Date.new(1970, 1, 1))
  name = Name.new(:given => "James", :family => "Kirk", :middle => "Tiberius")
  address = Address.new(
    :street => "1 Starfleet Command Way",
    :city => "San Francisco",
    :state => "CA",
    :post_code => "94133",
    :type => "Work"
  )
  phone = Phone.new(:country_code => 1, :number => "415-555-1212", :type => "Mobile")
  person.name = name
  person.addresses << address
  person.phones << phone
  person.save
end

result = RubyProf.stop
printer = RubyProf::FlatPrinter.new(result)
printer.print(STDOUT, 0)

Mongoid.database.collection("people").drop
