require 'pry'

class Dog
    
    attr_accessor :name, :breed, :id

    def attributes(name:, breed:, id:=nil)
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

    # def new_from_db
    #     attributes
    # end 

    # def save
    #     sql = 'INSERT INTO dogs (name, breed) VALUES (?, ?);'
    #     DB[:conn].execute(sql, self.name, self.breed)
    #     # binding.pry
    #     DB[:conn].execute('SELECT last_insert_rowid() FROM dogs;')[0]
    #     self
    # end



 
    
    # table_check_sql <<=SQL
    # "SELECT tbl_name 
    # FROM sqlite_master 
    # WHERE type='table' 
    # AND tbl_name='dogs';"
    # SQL
end