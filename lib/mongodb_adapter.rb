require 'rubygems'
require 'dm-core'
require 'dm-core/adapters/abstract_adapter'

require 'mongo'
require 'json'
require 'uuidtools'
require 'pp'

module DataMapper
  module Adapters
    class MongoDBAdapter < AbstractAdapter

      def initialize(name, options)
        super
        
        @hostname   = @options[:hostname] || 'localhost'
        @port       = @options[:port]     || 27017
        @database   = @options[:database] || 'dm-mongodb-test'
        
        @db = Mongo::Connection.new(@hostname, @port).db(@database)
      end
      
      # Create mongodb entry
      def create(resources)
        resources.each do |resource|
          collection = @db.collection(resource.model.storage_name)
          id_hash = {}
          Mongo::ObjectID.create_pk(id_hash)
          initialize_serial(resource, id_hash[:_id].to_s.to_i(16))
          doc = resource.attributes(:field)
          doc[:_id] = id_hash[:_id]
          doc = stringify_bignums(doc)
          doc = stringify_discriminators(doc)
          collection.insert(doc)
        end
      end

      def read(query)
        collection = @db.collection(query.model.storage_name)
        criteria = conditions_to_hash(query.conditions)

        result = []

        cur = collection.find(criteria)
        cur = cur.limit(query.limit) if query.limit
        cur.each do |document|
          document['__bignums'].each do |key|
            document[key] = document[key].to_i
          end
          document['__discriminators'].each do |key|
            document[key] = eval(document[key])
          end
          result << document
        end

        result
      end

      def update(attributes,resources)
        collection = @db.collection(resources[0].model.storage_name)
        resources.each do |resource|
          doc = resource.attributes(:field)
          serial = resource.model.serial(name).get(resource)
          doc[:_id] = Mongo::ObjectID.from_string(serial.to_s(16))
          doc = stringify_bignums(doc)
          doc = stringify_discriminators(doc)
          collection.save(doc)
        end
        resources.length
      end

      def delete(resources)
        collection = @db.collection(resources[0].model.storage_name)
        ids = []
        resources.each do |resource|
          serial = resource.model.serial(name).get(resource)
          ids << Mongo::ObjectID.from_string(serial.to_s(16))
        end
        collection.remove(:_id => {'$in' => ids})
      end
      
      private
        # Generates uuid from mongodb ruby driver
        def generate_id
          UUIDTools::UUID.random_create.to_i
        end

        def stringify_bignums(hash)
          hash['__bignums'] = []

          hash.each do |key, value|
            if value.class == Bignum
              hash[key] = value.to_s
              hash['__bignums'] << key
            end
          end
          hash
        end

        def stringify_discriminators(hash)
          hash['__discriminators'] = []

          hash.each do |key, value|
            if value.class == Class
              hash[key] = value.name
              hash['__discriminators'] << key
            end
          end
          hash
        end

        def conditions_to_hash(conditions, hash = {}, negate = false)
          case conditions
            when DataMapper::Query::Conditions::NotOperation then operation_to_hash(conditions, hash, !negate)
            when DataMapper::Query::Conditions::AbstractOperation then operation_to_hash(conditions, hash, negate)
            when DataMapper::Query::Conditions::AbstractComparison then comparison_to_hash(conditions, hash, negate)
          end
          hash
        end

        def operation_to_hash(operation, hash, negate)
          operation.each do |operand|
            conditions_to_hash(operand, hash, negate)
          end
        end

        def comparison_to_hash(comparison, hash, negate)
          value = nil
          if comparison.slug == :eql
            value = mongify_value(comparison.value,negate)
          elsif [:gt,:gte,:lt,:lte].include?(comparison.slug)
            value = mongify_value(comparison.value,negate)
            value = value.first[1] if value.is_a?(Hash)
            value = {mongify_inequality(comparison.slug, negate) => value}
          elsif comparison.slug == :in
            value = mongify_value(comparison.value,negate)
          elsif comparison.slug == :like
            value = Regexp.new(comparison.value.gsub(/%/, '.*'))
            value = mongify_value(value,negate)
          elsif comparison.slug == :regexp
            value = Regexp.new(comparison.value)
            value = mongify_value(value,negate)
          else
            puts "!!! Not handling #{comparison.slug} !!!"
          end
          hash[comparison.subject.name.to_s] = value
        end

        def mongify_value(value, negate)
          case value
            when Bignum then mongify_value(value.to_s, negate)
            when Class then mongify_value(value.name, negate)
            when Array then {negate ? '$nin' : '$in' => value}
            when Range then mongify_range(value, negate)
            else negate ? {'$ne' => value} : value
          end
        end

        def mongify_range(value, negate)
          first_op = negate ? '$lt' : '$gte'
          if value.exclude_end?
            last_op = negate ? '$gte' : '$lt'
          else
            last_op = negate ? '$gt' : '$lte'
          end
          {first_op => value.first, last_op => value.last}
        end

        def mongify_inequality(slug, negate)
          case slug
            when :gt then negate ? '$lte' : '$gt'
            when :gte then negate ? '$lt' : '$gte'
            when :lt then negate ? '$gte' : '$lt'
            when :lte then negate ? '$gt' : '$lte'
          end
        end
      
    end # class MongodbAdapter

    MongodbAdapter = MongoDBAdapter
  end

  module Types

    class Array < DataMapper::Type
      primitive ::Object
    end

  end

end
