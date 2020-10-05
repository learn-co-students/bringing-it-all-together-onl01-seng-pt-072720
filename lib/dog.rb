class Dog
    # - **`#attributes`**

    # The first test is concerned solely with making sure that our dogs have all the
    # required attributes and that they are readable and writable.
    
    # The `#initialize` method accepts a hash or keyword argument value with key-value
    # pairs as an argument. key-value pairs need to contain id, name, and breed.
    
    attr_accessor :name, :breed
    attr_reader :id

    def initialize (id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end
    #Look-up what are keyword arguments. What is a keyword. What is the sytnax and what is it useful for? (Hashes?)

    # - **`::create_table`**

# Your task  here is to define a class method on Dog that will execute the correct
# SQL to create a dogs table.

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
        sql =  <<-SQL
        DROP TABLE dogs
        SQL

        DB[:conn].execute(sql)
    end

    def save
        sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?,?)
        SQL

        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs") [0][0]
        self
    end

    def self.create(dog_attributes)
        wonder_dog = Dog.new(dog_attributes)
        wonder_dog.save
        wonder_dog
    end

    def self.new_from_db(row)
        attributes_hash = { :id => row[0], :name => row[1], :breed => row[2]}
        self.new(attributes_hash)
    end

    def self.find_by_id(id)
        sql = <<-SQL
        SELECT * 
        FROM dogs
        WHERE id = ?
        SQL
        
        DB[:conn].execute(sql, id).map do |row|
            self.new_from_db(row)
        end.first
    end

        def self.find_by_name(name)
            sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE name = ?
            SQL

            DB[:conn].execute(sql, name).map do |row|
                self.new_from_db(row)
            end.first
        end

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
        SELECT * 
        FROM dogs
        WHERE name = ?
        AND breed = ?
        SQL

        dog = DB[:conn].execute(sql, name, breed).first

        if dog
            new_dog = self.new_from_db(dog)
        else
            new_dog = self.create({:name => name, :breed => breed})
        end
        new_dog
    end

#     - **`#update`**

# This spec will create and insert a dog, and afterwards, it will change the name
# of the dog instance and call update. The expectations are that after this
# operation, there is no dog left in the database with the old name. If we query
# the database for a dog with the new name, we should find that dog and the ID of
# that dog should be the same as the original, signifying this is the same dog,
# they just changed their name.

    def update
        sql = <<-SQL
        UPDATE dogs
        SET name = ?,
        breed = ?
        WHERE id = ?
        SQL

        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end


        
    




end
