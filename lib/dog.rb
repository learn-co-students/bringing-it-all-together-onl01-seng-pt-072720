require 'pry'

class Dog
    
    attr_accessor :name, :breed, :id

    def attributes(name:, breed:, id:)
        @name = name
        @breed = breed
        @id = id
    end

    def initialize(attributes)
        attributes.each {|key, value| self.send(("#{key}="), value)} # Is there another way to do this?
        self.id ? self : nil
    end

    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
            id INTEGER PRIMARY KEY, 
            name TEXT, 
            breed TEXT
            )
            SQL

        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = 'DROP TABLE dogs'
        DB[:conn].execute(sql)
    end

    def save
        sql = 'INSERT INTO dogs (name, breed) VALUES (?, ?);'
        DB[:conn].execute(sql, self.name, self.breed)
        # binding.pry
        @id = DB[:conn].execute('SELECT last_insert_rowid() FROM dogs;')[0][0]
        self
    end

    def self.create(attributes)
        dog = self.new(attributes)
        dog.save
    end

    def self.new_from_db(row)
        attribute_hash = {
            :id => row[0], #Is this matching up the key with the value of the first element of the argument's array?
            :name => row[1],
            :breed => row[2]
        }
        self.new(attribute_hash)
    end 

    def self.find_by_id(id)
        sql = "SELECT id FROM dogs WHERE id = ?"
        
        DB[:conn].execute(sql, id).map do |row|
            self.new_from_db(row)
        end.first #Why "first"?
    end

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
          SELECT * FROM dogs
          WHERE name = ? AND breed = ?
          SQL
    
          dog = DB[:conn].execute(sql, name, breed).first

          if dog
            new_dog = self.new_from_db(dog)
          else
            new_dog = self.create({:name => name, :breed => breed})
          end
          new_dog #Why do I have to return? Just to see that there is a result?
      end

    def self.find_by_name(name)
        sql = "SELECT * FROM dogs WHERE name = ?"
        
        DB[:conn].execute(sql, name).map do |row|
            self.new_from_db(row)
        end.first #Why "first"?
    end

    def update
        sql = 'UPDATE dogs SET name = ?, breed = ? WHERE id = ?'

        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

end 