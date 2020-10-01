require 'pry'
class Dog

    attr_accessor :id, :name, :breed

    def initialize(name:, breed:, id: nil)
        @id = id
        @name = name
        @breed = breed
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
        sql = <<-SQL
        DROP TABLE IF EXISTS dogs
        SQL

        DB[:conn].execute(sql)
    end

    def self.new_from_db(row)
        dog = Dog.new(name: row[1], breed: row[2], id: row[0])
        dog
    end

    def self.create(hash)
        dog = Dog.new(name: hash[:name], breed: hash[:breed])
        dog.save
    end

    def save
        if self.id
            self.update
        else
            sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?,?)
            SQL

            DB[:conn].execute(sql, self.name, self.breed)

            self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
        self
    end

    def self.find_by_id(id)
        sql = <<-SQL
        SELECT * 
        FROM dogs
        WHERE id = ?
        SQL
        
        row = DB[:conn].execute(sql, id)[0]

        Dog.new_from_db(row)
    end

    def self.find_by_name(name)
        sql = <<-SQL
        SELECT * 
        FROM dogs
        WHERE name = ?
        SQL
        
        row = DB[:conn].execute(sql, name)[0]

        Dog.new_from_db(row)
    end

    def self.find_or_create_by(name:, breed:)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
        if !dog.empty?
          dog_row = dog[0]
          dog = self.new_from_db(dog_row)
        else
          dog = self.create(name: name, breed: breed)
        end
        dog
      end

    def update
        sql = <<-SQL
        UPDATE dogs
        SET name = ?, breed = ? 
        WHERE id = ?
        SQL

        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end



end